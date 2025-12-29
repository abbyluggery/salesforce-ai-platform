public with sharing class JobIngestionScheduler {
    
    @future(callout=true)
    public static void runIngestion() {
        // Start the batch job
        Id jobId = Database.executeBatch(new JobIngestionBatch(), 200);
        System.debug('Started job ingestion batch with ID: ' + jobId);
    }
}
