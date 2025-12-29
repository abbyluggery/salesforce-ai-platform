public with sharing class MarketingIntegrationUtil {
    
    public class MarketingIntegrationException extends Exception {}
    
    /**
     * Syncs data to both HubSpot and GitHub integrations
     * @param recordId The ID of the record to sync
     * @param objectType The type of object being synced
     * @param data The data to sync
     * @return True if both integrations were successful, false otherwise
     */
    public static Boolean syncToAllIntegrations(Id recordId, String objectType, Map<String, Object> data) {
        Boolean hubSpotSuccess = false;
        Boolean gitHubSuccess = false;
        
        try {
            hubSpotSuccess = HubSpotIntegrationService.integrateWithHubSpot(recordId, objectType, data);
        } catch (HubSpotIntegrationService.HubSpotIntegrationException e) {
            System.debug('HubSpot integration failed: ' + e.getMessage());
        }
        
        try {
            gitHubSuccess = GitHubIntegrationService.integrateWithGitHub(recordId, objectType, data);
        } catch (GitHubIntegrationService.GitHubIntegrationException e) {
            System.debug('GitHub integration failed: ' + e.getMessage());
        }
        
        return hubSpotSuccess && gitHubSuccess;
    }
    
    /**
     * Syncs data to HubSpot only
     * @param recordId The ID of the record to sync
     * @param objectType The type of object being synced
     * @param data The data to sync
     * @return True if integration was successful, false otherwise
     */
    public static Boolean syncToHubSpot(Id recordId, String objectType, Map<String, Object> data) {
        try {
            return HubSpotIntegrationService.integrateWithHubSpot(recordId, objectType, data);
        } catch (HubSpotIntegrationService.HubSpotIntegrationException e) {
            System.debug('HubSpot integration failed: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * Syncs data to GitHub only
     * @param recordId The ID of the record to sync
     * @param objectType The type of object being synced
     * @param data The data to sync
     * @return True if integration was successful, false otherwise
     */
    public static Boolean syncToGitHub(Id recordId, String objectType, Map<String, Object> data) {
        try {
            return GitHubIntegrationService.integrateWithGitHub(recordId, objectType, data);
        } catch (GitHubIntegrationService.GitHubIntegrationException e) {
            System.debug('GitHub integration failed: ' + e.getMessage());
            return false;
        }
    }
}
