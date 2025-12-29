public with sharing class TableauAuthController {
    /*
     * Controller to support LWC embedding of Tableau via Embedding API v3.
     * - Retrieves an access token from TableauTokenProvider (via secure token proxy Named Credential).
     * - Optionally forwards Salesforce context (e.g., recordId, user info) to help build RLS claims or filters at the proxy.
     */

    public class InitResponse {
        @AuraEnabled public String accessToken;
        @AuraEnabled public String tableauBaseUrl;   // e.g., https://us-east-1a.online.tableau.com/t/yourSite
        @AuraEnabled public String vizPath;          // e.g., /views/YourWorkbook/YourView
        @AuraEnabled public Integer expiresIn;
    }

    @AuraEnabled(cacheable=false)
    public static InitResponse initForEmbed(String tableauBaseUrl, String vizPath, String recordId, Map<String, Object> extraContext) {
        // Build a minimal context JSON for the proxy/RLS claims
        Map<String, Object> ctx = new Map<String, Object>();
        if (String.isNotBlank(recordId)) {
            ctx.put('recordId', recordId);
        }
        ctx.put('userId', UserInfo.getUserId());
        ctx.put('username', UserInfo.getUserName());
        ctx.put('email', UserInfo.getUserEmail());
        if (extraContext != null) {
            ctx.put('extra', extraContext);
        }

        String contextJson = JSON.serialize(ctx);

        TableauTokenProvider.TokenResponse tr = TableauTokenProvider.getAccessToken(contextJson);

        InitResponse out = new InitResponse();
        out.accessToken = tr.access_token;
        out.expiresIn = tr.expires_in;
        out.tableauBaseUrl = tableauBaseUrl;
        out.vizPath = vizPath;
        return out;
    }
}
