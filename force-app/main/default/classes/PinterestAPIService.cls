/**
 * PinterestAPIService
 *
 * Integrates with Pinterest API v5 for automated marketing content posting.
 * Automatically creates Pins when new journal products are created.
 * Tracks Pinterest performance metrics (impressions, clicks, saves).
 *
 * API Documentation: https://developers.pinterest.com/docs/api/v5/
 *
 * Setup Required:
 * 1. Create Pinterest Business Account
 * 2. Generate Pinterest API Access Token (OAuth 2.0)
 * 3. Store Access Token in Custom Metadata Type: Pinterest_API_Settings__mdt
 * 4. Configure Remote Site Settings for api.pinterest.com
 * 5. Get Board ID from Pinterest account
 *
 * Part of the Journal Business module.
 */
public class PinterestAPIService {

    // Pinterest API v5 endpoints
    private static final String BASE_URL = 'https://api.pinterest.com/v5';
    private static final String PINS_ENDPOINT = BASE_URL + '/pins';
    private static final String BOARDS_ENDPOINT = BASE_URL + '/boards';

    /**
     * Create a Pinterest Pin for a new journal product
     * @param productId - Journal_Product__c record ID
     * @return Pinterest Pin ID if successful
     */
    @future(callout=true)
    public static void createProductPin(Id productId) {
        try {
            // Get product details
            Journal_Product__c product = [
                SELECT Id, Name, Description__c, Category__c,
                       Product_SKU__c, Base_Price__c, Product_Tier__c,
                       Cover_Image_URL__c, Trim_Size__c, Binding_Type__c,
                       Key_Features__c
                FROM Journal_Product__c
                WHERE Id = :productId
                LIMIT 1
            ];

            // Get Pinterest settings
            Pinterest_API_Settings__mdt settings = getPinterestSettings();

            // Build Pin request
            Map<String, Object> pinRequest = buildPinRequest(product, settings.Board_ID__c);

            // Call Pinterest API
            HttpRequest req = new HttpRequest();
            req.setEndpoint(PINS_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + settings.Access_Token__c);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(pinRequest));
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            // Handle response
            if (res.getStatusCode() == 201) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String pinId = (String) responseBody.get('id');

                // Create Marketing_Content__c record
                Marketing_Content__c content = new Marketing_Content__c(
                    Journal_Product__c = productId,
                    Content_Type__c = 'Pinterest Pin',
                    Pinterest_Post_ID__c = pinId,
                    Posted_Date__c = System.now(),
                    Status__c = 'Published',
                    Title__c = product.Name,
                    Description__c = product.Description__c
                );
                insert content;

                System.debug('Successfully created Pinterest Pin: ' + pinId);

            } else {
                throw new PinterestAPIException('Pinterest API error: ' + res.getStatusCode() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error creating Pinterest Pin: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * Get Pinterest Pin analytics
     * @param pinId - Pinterest Pin ID
     * @return Analytics data
     */
    public static PinAnalytics getPinAnalytics(String pinId) {
        try {
            Pinterest_API_Settings__mdt settings = getPinterestSettings();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(PINS_ENDPOINT + '/' + pinId + '/analytics?metric_types=IMPRESSION,SAVE,PIN_CLICK');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + settings.Access_Token__c);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                return parsePinAnalytics(res.getBody());
            } else {
                throw new PinterestAPIException('Failed to get Pin analytics: ' + res.getStatusCode() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error getting Pinterest analytics: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * Sync analytics for all published Pinterest Pins
     * Called by scheduled Apex daily
     */
    @future(callout=true)
    public static void syncAllPinAnalytics() {
        List<Marketing_Content__c> pins = [
            SELECT Id, Pinterest_Post_ID__c, Impressions__c, Clicks__c, Saves__c
            FROM Marketing_Content__c
            WHERE Content_Type__c = 'Pinterest Pin'
            AND Status__c = 'Published'
            AND Pinterest_Post_ID__c != null
            LIMIT 50
        ];

        List<Marketing_Content__c> pinsToUpdate = new List<Marketing_Content__c>();

        for (Marketing_Content__c pin : pins) {
            try {
                PinAnalytics analytics = getPinAnalytics(pin.Pinterest_Post_ID__c);

                // Update if analytics changed
                if (analytics.impressions != pin.Impressions__c ||
                    analytics.clicks != pin.Clicks__c ||
                    analytics.saves != pin.Saves__c) {

                    pin.Impressions__c = analytics.impressions;
                    pin.Clicks__c = analytics.clicks;
                    pin.Saves__c = analytics.saves;
                    pin.Last_Analytics_Update__c = System.now();
                    pinsToUpdate.add(pin);
                }

            } catch (Exception e) {
                System.debug('Error syncing analytics for Pin ' + pin.Pinterest_Post_ID__c + ': ' + e.getMessage());
            }
        }

        if (!pinsToUpdate.isEmpty()) {
            update pinsToUpdate;
            System.debug('Updated analytics for ' + pinsToUpdate.size() + ' Pins');
        }
    }

    /**
     * Create multiple Pins for a product (different categories/boards)
     * @param productId - Journal_Product__c record ID
     * @param boardIds - List of Pinterest Board IDs to post to
     */
    @future(callout=true)
    public static void createMultiplePins(Id productId, List<String> boardIds) {
        for (String boardId : boardIds) {
            try {
                // Similar to createProductPin but with custom board ID
                Journal_Product__c product = [
                    SELECT Id, Name, Description__c, Category__c,
                           Product_SKU__c, Base_Price__c, Cover_Image_URL__c
                    FROM Journal_Product__c
                    WHERE Id = :productId
                    LIMIT 1
                ];

                Pinterest_API_Settings__mdt settings = getPinterestSettings();

                Map<String, Object> pinRequest = buildPinRequest(product, boardId);

                HttpRequest req = new HttpRequest();
                req.setEndpoint(PINS_ENDPOINT);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + settings.Access_Token__c);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(pinRequest));
                req.setTimeout(120000);

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 201) {
                    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    String pinId = (String) responseBody.get('id');

                    Marketing_Content__c content = new Marketing_Content__c(
                        Journal_Product__c = productId,
                        Content_Type__c = 'Pinterest Pin',
                        Pinterest_Post_ID__c = pinId,
                        Posted_Date__c = System.now(),
                        Status__c = 'Published',
                        Title__c = product.Name,
                        Pinterest_Board_ID__c = boardId
                    );
                    insert content;
                }

            } catch (Exception e) {
                System.debug('Error creating Pin for board ' + boardId + ': ' + e.getMessage());
            }
        }
    }

    /**
     * Build Pinterest Pin request payload
     */
    private static Map<String, Object> buildPinRequest(Journal_Product__c product, String boardId) {
        Map<String, Object> request = new Map<String, Object>();

        // Board ID
        request.put('board_id', boardId);

        // Title (max 100 characters)
        String title = product.Name;
        if (title.length() > 100) {
            title = title.substring(0, 97) + '...';
        }
        request.put('title', title);

        // Description (max 500 characters) - includes price and category
        String description = product.Description__c + '\n\n';
        description += '✨ Category: ' + product.Category__c + '\n';
        description += '💰 Price: $' + product.Base_Price__c + '\n';

        if (String.isNotBlank(product.Key_Features__c)) {
            description += '\nFeatures: ' + product.Key_Features__c.replace(',', ', ') + '\n';
        }

        description += '\n🛒 Shop now at abbyluggery.com';

        if (description.length() > 500) {
            description = description.substring(0, 497) + '...';
        }
        request.put('description', description);

        // Link to product page (will need to be updated with actual storefront URL)
        String productUrl = 'https://abbyluggery.com/products/' + product.Product_SKU__c;
        request.put('link', productUrl);

        // Media source
        Map<String, Object> mediaSource = new Map<String, Object>();
        if (String.isNotBlank(product.Cover_Image_URL__c)) {
            // Use existing image URL
            mediaSource.put('source_type', 'image_url');
            mediaSource.put('url', product.Cover_Image_URL__c);
        } else {
            // Placeholder - will need actual image URL
            mediaSource.put('source_type', 'image_url');
            mediaSource.put('url', 'https://abbyluggery.com/images/placeholder.jpg');
        }
        request.put('media_source', mediaSource);

        return request;
    }

    /**
     * Parse Pinterest analytics response
     */
    private static PinAnalytics parsePinAnalytics(String responseBody) {
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        PinAnalytics analytics = new PinAnalytics();
        analytics.impressions = 0;
        analytics.clicks = 0;
        analytics.saves = 0;

        // Pinterest returns metrics in an array
        List<Object> metricsArray = (List<Object>) response.get('all');
        if (metricsArray != null && !metricsArray.isEmpty()) {
            Map<String, Object> metrics = (Map<String, Object>) metricsArray[0];

            Map<String, Object> dataPoints = (Map<String, Object>) metrics.get('data_points');
            if (dataPoints != null) {
                analytics.impressions = getMetricValue(dataPoints, 'IMPRESSION');
                analytics.clicks = getMetricValue(dataPoints, 'PIN_CLICK');
                analytics.saves = getMetricValue(dataPoints, 'SAVE');
            }
        }

        return analytics;
    }

    /**
     * Extract metric value from Pinterest analytics data
     */
    private static Integer getMetricValue(Map<String, Object> dataPoints, String metricType) {
        if (dataPoints.containsKey(metricType)) {
            Object metricValue = dataPoints.get(metricType);
            if (metricValue != null) {
                return Integer.valueOf(metricValue);
            }
        }
        return 0;
    }

    /**
     * Get Pinterest API settings from Custom Metadata
     */
    private static Pinterest_API_Settings__mdt getPinterestSettings() {
        Pinterest_API_Settings__mdt settings = [
            SELECT Access_Token__c, Board_ID__c
            FROM Pinterest_API_Settings__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
        return settings;
    }

    /**
     * Wrapper class for Pinterest Pin analytics
     */
    public class PinAnalytics {
        public Integer impressions;
        public Integer clicks;
        public Integer saves;
    }

    /**
     * Custom exception for Pinterest API errors
     */
    public class PinterestAPIException extends Exception {}
}
