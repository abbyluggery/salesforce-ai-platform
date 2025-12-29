public with sharing class TableauTokenProvider {
    /*
     * Token Provider for Tableau Connected Apps (JWT bearer).
     *
     * Overview:
     * - Signs a JWT assertion with a private key and exchanges it with Tableau Cloud for a short-lived access token.
     * - This class is intentionally scaffolded to use a Named Credential for secure storage of secrets and endpoint configuration.
     *
     * Admin prerequisites:
     * 1) In Tableau Cloud:
     *    - Settings → Authentication → Connected Apps → Create Connected App.
     *    - Configure Allowed Domains to include your Salesforce Lightning domain(s).
     *    - Generate a key pair (or upload your public key) and record:
     *      * Client ID (iss/aud details often required depending on Tableau doc).
     *      * JWKS / public key info.
     *      * Token endpoint and embed configuration.
     * 2) In Salesforce:
     *    - Create a Named Credential (e.g., Named Credential label: Tableau_ConnectedApp, API Name: Tableau_ConnectedApp)
     *      Type: OAuth 2.0 JWT Bearer flow is not directly supported as a click-config; we call the token endpoint via Http using the Named Credential's URL and store secrets in Protected Custom Metadata or Named Credential's "Password"/"Client Secret" if using a proxy.
     *    - Recommended pattern:
     *      a) Host a lightweight token-exchange service you control (preferred), and set the Named Credential to that service URL.
     *         The service performs private key signing server-side and returns a Tableau access token JSON. This avoids storing private keys in Salesforce.
     *      b) If you must sign in Salesforce, store the private key material in a Protected Custom Setting/Metadata or Named Credential (not in code) and implement JWT signing using Crypto classes.
     *
     * This scaffold implements option (a) by default: call a secure token proxy via Named Credential.
     * Replace TOKEN_PROXY_PATH and response parsing as per your proxy contract.
     */

    public class TokenResponse {
        @AuraEnabled public String access_token;
        @AuraEnabled public String token_type;
        @AuraEnabled public Integer expires_in;
        @AuraEnabled public String scope;
        // Add other fields as returned by your proxy/Tableau
    }

    @TestVisible private static final String NC_NAME = 'Tableau_ConnectedApp'; // Named Credential API Name
    @TestVisible private static final String TOKEN_PROXY_PATH = '/tableau/token'; // Path on your token proxy that returns a Tableau access token JSON

    /**
     * Retrieves a short-lived Tableau access token from your secure token proxy.
     * Optionally accepts context info (e.g., recordId, user attributes) to include in RLS claims at the proxy side.
     */
    @AuraEnabled(cacheable=false)
    public static TokenResponse getAccessToken(String contextJson) {
        HttpRequest req = new HttpRequest();
        // Use Named Credential for host + auth; the system injects base URL and auth headers.
        req.setEndpoint('callout:' + NC_NAME + TOKEN_PROXY_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Send optional context that your proxy can use when building claims
        if (String.isBlank(contextJson)) {
            contextJson = '{}';
        }
        req.setBody(contextJson);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            System.debug('Tableau token proxy error: ' + res.getStatusCode() + ' body=' + res.getBody());
            throw new AuraHandledException('Failed to retrieve Tableau token. Please contact your administrator.');
        }

        TokenResponse tr;
        try {
            tr = (TokenResponse) System.JSON.deserialize(res.getBody(), TokenResponse.class);
        } catch (Exception e) {
            System.debug('Token JSON parse error: ' + e.getMessage() + ' body=' + res.getBody());
            throw new AuraHandledException('Invalid token response from proxy.');
        }

        if (String.isBlank(tr.access_token)) {
            throw new AuraHandledException('Proxy did not return an access token.');
        }
        return tr;
    }
}
