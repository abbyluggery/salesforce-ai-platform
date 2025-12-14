/**
 * @description Test class for ScheduledJobSearch
 * Tests scheduling functionality and job import orchestration
 *
 * @author Claude Code Assistant
 * @date 2025-12-14
 */
@isTest
private class ScheduledJobSearchTest {

    /**
     * @description Mock HTTP callout for successful import
     */
    private class MockHttpSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Check which endpoint is being called
            if (req.getEndpoint().contains('/api/search')) {
                // Search trigger endpoint
                res.setBody('{"status": "started"}');
            } else {
                // Jobs endpoint - return mock jobs
                res.setBody('[{"job_hash": "test1", "title": "Salesforce Admin", "company": "Test Co", ' +
                    '"location": "Remote", "salary_min": 90000, "salary_max": 110000, ' +
                    '"url": "https://example.com/job", "description": "Remote Salesforce Admin role", ' +
                    '"source": "adzuna", "quick_score": 8.0, "status": "new"}]');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testScheduledJobSearch_Execute() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Create scheduler and execute
        ScheduledJobSearch scheduler = new ScheduledJobSearch('Abby');
        String jobId = System.schedule('Test Job Import', '0 0 8 * * ?', scheduler);

        Test.stopTest();

        // Verify job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 8 * * ?', ct.CronExpression, 'Cron expression should match');

        // Clean up
        System.abortJob(jobId);
    }

    @isTest
    static void testScheduledJobSearch_DefaultConstructor() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        ScheduledJobSearch scheduler = new ScheduledJobSearch();
        String jobId = System.schedule('Test Default Import', '0 0 9 * * ?', scheduler);

        Test.stopTest();

        // Verify scheduled
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, ct, 'Job should be scheduled');

        System.abortJob(jobId);
    }

    @isTest
    static void testScheduledJobSearch_FullConstructor() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Use full constructor with all parameters
        ScheduledJobSearch scheduler = new ScheduledJobSearch('Matt', 7.0, true, true);
        String jobId = System.schedule('Test Full Config Import', '0 0 10 * * ?', scheduler);

        Test.stopTest();

        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, ct, 'Job should be scheduled');

        System.abortJob(jobId);
    }

    @isTest
    static void testScheduleDailyImport() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        String jobId = ScheduledJobSearch.scheduleDailyImport('Abby');

        Test.stopTest();

        // Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Should return job ID');

        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE '%Abby%'];
        System.assertEquals(1, jobs.size(), 'Should have one scheduled job for Abby');

        // Clean up
        System.abortJob(jobId);
    }

    @isTest
    static void testScheduleDailyImport_Reschedule() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Schedule first time
        String jobId1 = ScheduledJobSearch.scheduleDailyImport('Abby');

        // Schedule again - should abort old and create new
        String jobId2 = ScheduledJobSearch.scheduleDailyImport('Abby');

        Test.stopTest();

        // Should only have one job (old one was aborted)
        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE '%Daily Job Import - Abby%'];
        System.assertEquals(1, jobs.size(), 'Should have exactly one scheduled job');

        System.abortJob(jobId2);
    }

    @isTest
    static void testScheduleEveryFourHours() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        String jobId = ScheduledJobSearch.scheduleEveryFourHours('Matt');

        Test.stopTest();

        CronTrigger ct = [SELECT CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0/4 * * ?', ct.CronExpression, 'Should be every 4 hours');

        System.abortJob(jobId);
    }

    @isTest
    static void testRunNow() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // This will enqueue the job
        ScheduledJobSearch.runNow('Abby');

        Test.stopTest();

        // Verify a job was created (from the queueable execution)
        List<Job_Posting__c> jobs = [SELECT Id, Owner_Name__c FROM Job_Posting__c];
        System.assertEquals(1, jobs.size(), 'Should have imported 1 job');
        System.assertEquals('Abby', jobs[0].Owner_Name__c, 'Owner should be Abby');
    }

    @isTest
    static void testGetScheduledJobs() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Schedule some jobs
        String jobId1 = ScheduledJobSearch.scheduleDailyImport('Abby');
        String jobId2 = ScheduledJobSearch.scheduleEveryFourHours('Matt');

        // Get scheduled jobs
        List<CronTrigger> jobs = ScheduledJobSearch.getScheduledJobs();

        Test.stopTest();

        System.assertEquals(2, jobs.size(), 'Should have 2 scheduled jobs');

        // Clean up
        System.abortJob(jobId1);
        System.abortJob(jobId2);
    }

    @isTest
    static void testCancelAllScheduledJobs() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Schedule some jobs
        ScheduledJobSearch.scheduleDailyImport('Abby');
        ScheduledJobSearch.scheduleEveryFourHours('Matt');

        // Cancel all
        ScheduledJobSearch.cancelAllScheduledJobs();

        Test.stopTest();

        // Verify all cancelled
        List<CronTrigger> jobs = ScheduledJobSearch.getScheduledJobs();
        System.assertEquals(0, jobs.size(), 'All jobs should be cancelled');
    }

    @isTest
    static void testJobImportQueueable_WithAIAnalysis() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Create queueable with AI analysis enabled
        ScheduledJobSearch.JobImportQueueable queueable = new ScheduledJobSearch.JobImportQueueable(
            'Abby',
            6.0,
            false,
            true // Run AI analysis
        );
        System.enqueueJob(queueable);

        Test.stopTest();

        // Job should be imported
        List<Job_Posting__c> jobs = [SELECT Id, Title__c FROM Job_Posting__c];
        System.assertEquals(1, jobs.size(), 'Should have imported 1 job');
    }

    @isTest
    static void testJobImportQueueable_WithSearchTrigger() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Create queueable that triggers Python search first
        ScheduledJobSearch.JobImportQueueable queueable = new ScheduledJobSearch.JobImportQueueable(
            'Matt',
            7.0,
            true, // Trigger search first
            false
        );
        System.enqueueJob(queueable);

        Test.stopTest();

        // Job should be imported for Matt
        List<Job_Posting__c> jobs = [SELECT Owner_Name__c FROM Job_Posting__c];
        System.assertEquals(1, jobs.size(), 'Should have imported 1 job');
        System.assertEquals('Matt', jobs[0].Owner_Name__c, 'Owner should be Matt');
    }

    @isTest
    static void testJobImportQueueable_NullOwner() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();

        // Create queueable with null owner - should default to Abby
        ScheduledJobSearch.JobImportQueueable queueable = new ScheduledJobSearch.JobImportQueueable(
            null,
            6.0,
            false,
            false
        );
        System.enqueueJob(queueable);

        Test.stopTest();

        // Job should be imported with default owner
        List<Job_Posting__c> jobs = [SELECT Owner_Name__c FROM Job_Posting__c];
        System.assertEquals(1, jobs.size(), 'Should have imported 1 job');
        System.assertEquals('Abby', jobs[0].Owner_Name__c, 'Default owner should be Abby');
    }
}
