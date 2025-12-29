/**
 * LuluAPIService
 *
 * Integrates with Lulu Print API for automated print-on-demand fulfillment.
 * Handles OAuth 2.0 authentication, order submission, and status tracking.
 *
 * API Documentation: https://developers.lulu.com/
 *
 * Setup Required:
 * 1. Create Named Credential: Lulu_API
 * 2. Store Client ID and Client Secret in Custom Metadata Type: Lulu_API_Settings__mdt
 * 3. Configure Remote Site Settings for api.lulu.com
 *
 * Part of the Journal Business module.
 */
public class LuluAPIService {

    // Lulu API endpoints
    private static final String AUTH_ENDPOINT = 'https://api.lulu.com/auth/realms/glasstree/protocol/openid-connect/token';
    private static final String PRINT_JOBS_ENDPOINT = 'https://api.lulu.com/print-jobs/';

    /**
     * Submit a print job to Lulu for a Journal Sale
     * @param saleId - Journal_Sale__c record ID
     * @return Lulu Job ID if successful, null if failed
     */
    @future(callout=true)
    public static void createPrintJob(Id saleId) {
        try {
            // Get sale details with product and customer info
            Journal_Sale__c sale = [
                SELECT Id, Order_ID__c, Quantity__c,
                       Journal_Product__c, Journal_Product__r.Lulu_Product_ID__c,
                       Journal_Product__r.Name, Journal_Product__r.Product_SKU__c,
                       Journal_Customer__c, Journal_Customer__r.First_Name__c,
                       Journal_Customer__r.Last_Name__c, Journal_Customer__r.Email__c,
                       Shipping_Address_Line_1__c, Shipping_Address_Line_2__c,
                       Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c,
                       Shipping_Country__c
                FROM Journal_Sale__c
                WHERE Id = :saleId
                LIMIT 1
            ];

            // Validate Lulu Product ID exists
            if (String.isBlank(sale.Journal_Product__r.Lulu_Product_ID__c)) {
                throw new LuluAPIException('Product does not have Lulu_Product_ID__c: ' + sale.Journal_Product__r.Name);
            }

            // Get OAuth token
            String accessToken = getAccessToken();

            // Build print job request
            Map<String, Object> printJobRequest = buildPrintJobRequest(sale);

            // Submit to Lulu API
            HttpRequest req = new HttpRequest();
            req.setEndpoint(PRINT_JOBS_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(printJobRequest));
            req.setTimeout(120000); // 2 minutes

            Http http = new Http();
            HttpResponse res = http.send(req);

            // Handle response
            if (res.getStatusCode() == 201) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String luluJobId = (String) responseBody.get('id');

                // Update sale with Lulu Job ID
                sale.Lulu_Job_ID__c = luluJobId;
                sale.Fulfillment_Status__c = 'Submitted to Lulu';
                sale.Lulu_Submission_Date__c = System.now();
                update sale;

                System.debug('Successfully submitted Lulu print job: ' + luluJobId);
            } else {
                throw new LuluAPIException('Lulu API error: ' + res.getStatusCode() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error creating Lulu print job: ' + e.getMessage());

            // Update sale with error
            Journal_Sale__c errorSale = new Journal_Sale__c(
                Id = saleId,
                Fulfillment_Status__c = 'Lulu Error',
                Lulu_Error_Message__c = e.getMessage().left(255)
            );
            update errorSale;

            throw e;
        }
    }

    /**
     * Get order status from Lulu
     * @param luluJobId - Lulu print job ID
     * @return Status object with tracking info
     */
    public static LuluOrderStatus getOrderStatus(String luluJobId) {
        try {
            String accessToken = getAccessToken();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(PRINT_JOBS_ENDPOINT + luluJobId + '/');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                return parseLuluOrderStatus(res.getBody());
            } else {
                throw new LuluAPIException('Failed to get order status: ' + res.getStatusCode() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error getting Lulu order status: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * Sync order statuses for all pending Lulu jobs
     * Called by scheduled Apex or Flow
     */
    @future(callout=true)
    public static void syncPendingOrders() {
        List<Journal_Sale__c> pendingSales = [
            SELECT Id, Lulu_Job_ID__c, Fulfillment_Status__c
            FROM Journal_Sale__c
            WHERE Lulu_Job_ID__c != null
            AND Fulfillment_Status__c IN ('Submitted to Lulu', 'In Production', 'In Transit')
            LIMIT 50
        ];

        List<Journal_Sale__c> salesToUpdate = new List<Journal_Sale__c>();

        for (Journal_Sale__c sale : pendingSales) {
            try {
                LuluOrderStatus status = getOrderStatus(sale.Lulu_Job_ID__c);

                // Update sale if status changed
                if (status.status != sale.Fulfillment_Status__c) {
                    sale.Fulfillment_Status__c = status.status;
                    sale.Tracking_Number__c = status.trackingNumber;
                    sale.Tracking_URL__c = status.trackingUrl;
                    salesToUpdate.add(sale);
                }

            } catch (Exception e) {
                System.debug('Error syncing order ' + sale.Lulu_Job_ID__c + ': ' + e.getMessage());
            }
        }

        if (!salesToUpdate.isEmpty()) {
            update salesToUpdate;
            System.debug('Updated ' + salesToUpdate.size() + ' order statuses from Lulu');
        }
    }

    /**
     * Get OAuth 2.0 access token from Lulu
     * @return Access token
     */
    private static String getAccessToken() {
        // Get credentials from Custom Metadata
        Lulu_API_Settings__mdt settings = [
            SELECT Client_ID__c, Client_Secret__c
            FROM Lulu_API_Settings__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];

        HttpRequest req = new HttpRequest();
        req.setEndpoint(AUTH_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=client_credentials' +
                      '&client_id=' + EncodingUtil.urlEncode(settings.Client_ID__c, 'UTF-8') +
                      '&client_secret=' + EncodingUtil.urlEncode(settings.Client_Secret__c, 'UTF-8');
        req.setBody(body);
        req.setTimeout(60000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) authResponse.get('access_token');
        } else {
            throw new LuluAPIException('Failed to get Lulu access token: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }

    /**
     * Build Lulu print job request payload
     */
    private static Map<String, Object> buildPrintJobRequest(Journal_Sale__c sale) {
        Map<String, Object> request = new Map<String, Object>();

        // Line items
        List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
        Map<String, Object> lineItem = new Map<String, Object>{
            'external_id' => sale.Order_ID__c,
            'printable_normalization' => new Map<String, Object>{
                'pod_package_id' => sale.Journal_Product__r.Lulu_Product_ID__c
            },
            'quantity' => Integer.valueOf(sale.Quantity__c)
        };
        lineItems.add(lineItem);
        request.put('line_items', lineItems);

        // Shipping address
        Map<String, Object> shippingAddress = new Map<String, Object>{
            'name' => sale.Journal_Customer__r.First_Name__c + ' ' + sale.Journal_Customer__r.Last_Name__c,
            'street1' => sale.Shipping_Address_Line_1__c,
            'city' => sale.Shipping_City__c,
            'state_code' => sale.Shipping_State__c,
            'postcode' => sale.Shipping_Postal_Code__c,
            'country_code' => sale.Shipping_Country__c,
            'email' => sale.Journal_Customer__r.Email__c
        };

        if (String.isNotBlank(sale.Shipping_Address_Line_2__c)) {
            shippingAddress.put('street2', sale.Shipping_Address_Line_2__c);
        }

        request.put('shipping_address', shippingAddress);

        // Shipping level (standard)
        request.put('shipping_level', 'MAIL');

        // Contact email
        request.put('contact_email', sale.Journal_Customer__r.Email__c);

        // Production delay (0 = immediate)
        request.put('production_delay', 0);

        return request;
    }

    /**
     * Parse Lulu order status response
     */
    private static LuluOrderStatus parseLuluOrderStatus(String responseBody) {
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        LuluOrderStatus status = new LuluOrderStatus();
        status.jobId = (String) response.get('id');
        status.status = mapLuluStatusToSalesforce((String) response.get('status'));

        // Get tracking info if available
        Map<String, Object> shipping = (Map<String, Object>) response.get('shipping');
        if (shipping != null) {
            status.trackingNumber = (String) shipping.get('tracking_id');
            status.trackingUrl = (String) shipping.get('tracking_url');
        }

        return status;
    }

    /**
     * Map Lulu API status to Salesforce picklist values
     */
    private static String mapLuluStatusToSalesforce(String luluStatus) {
        // Lulu statuses: CREATED, IN_PRODUCTION, SHIPPED, CANCELED, ERROR
        Map<String, String> statusMap = new Map<String, String>{
            'CREATED' => 'Submitted to Lulu',
            'IN_PRODUCTION' => 'In Production',
            'SHIPPED' => 'Shipped',
            'CANCELED' => 'Canceled',
            'ERROR' => 'Lulu Error'
        };

        return statusMap.containsKey(luluStatus) ? statusMap.get(luluStatus) : luluStatus;
    }

    /**
     * Wrapper class for Lulu order status
     */
    public class LuluOrderStatus {
        public String jobId;
        public String status;
        public String trackingNumber;
        public String trackingUrl;
    }

    /**
     * Custom exception for Lulu API errors
     */
    public class LuluAPIException extends Exception {}
}
