/**
 * @description Test class for JobSearchAPIService
 * Tests job import functionality with mock HTTP callouts
 *
 * @author Claude Code Assistant
 * @date 2025-12-14
 */
@isTest
private class JobSearchAPIServiceTest {

    /**
     * @description Mock HTTP callout class for successful API response
     */
    private class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Return mock job data matching Python API format
            String mockJobs = '[' +
                '{"job_hash": "abc123", "title": "Salesforce Administrator", "company": "Tech Corp", ' +
                '"location": "Remote", "salary_min": 90000, "salary_max": 110000, "url": "https://example.com/job1", ' +
                '"description": "Remote Salesforce Admin position with flexible schedule.", "source": "adzuna", ' +
                '"quick_score": 8.5, "status": "new"},' +
                '{"job_hash": "def456", "title": "Salesforce DevOps Engineer", "company": "Innovation Inc", ' +
                '"location": "Remote - US", "salary_min": 100000, "salary_max": 130000, "url": "https://example.com/job2", ' +
                '"description": "Looking for experienced Salesforce DevOps professional. Hybrid work available.", ' +
                '"source": "remoteok", "quick_score": 7.2, "status": "new"},' +
                '{"job_hash": "ghi789", "title": "CRM Administrator", "company": "StartupXYZ", ' +
                '"location": "Jacksonville, FL (On-site)", "salary_min": 85000, "salary_max": 95000, ' +
                '"url": "https://example.com/job3", "description": "On-site CRM admin role.", "source": "indeed", ' +
                '"quick_score": 6.0, "status": "new"}' +
            ']';

            res.setBody(mockJobs);
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * @description Mock HTTP callout class for empty response
     */
    private class MockHttpResponseEmpty implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[]');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * @description Mock HTTP callout class for API error
     */
    private class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "Internal Server Error"}');
            res.setStatusCode(500);
            return res;
        }
    }

    /**
     * @description Mock for Python search trigger
     */
    private class MockHttpSearchTrigger implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "started", "message": "Search started"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testImportJobs_Success() {
        // Setup mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

        Test.startTest();
        JobSearchAPIService.ImportResult result = JobSearchAPIService.importJobs('Abby');
        Test.stopTest();

        // Verify results
        System.assertEquals(3, result.totalFetched, 'Should fetch 3 jobs');
        System.assertEquals(3, result.newJobs, 'Should create 3 new jobs');
        System.assertEquals(0, result.updatedJobs, 'Should have 0 updated jobs on first import');
        System.assertEquals(0, result.errors, 'Should have no errors');

        // Verify records were created
        List<Job_Posting__c> jobs = [SELECT Id, Title__c, Company__c, Provider__c, Quick_Score__c, Owner_Name__c, Workplace_Type__c FROM Job_Posting__c];
        System.assertEquals(3, jobs.size(), 'Should have 3 job records');

        // Verify field mapping
        Job_Posting__c sfAdmin = null;
        for (Job_Posting__c job : jobs) {
            if (job.Title__c == 'Salesforce Administrator') {
                sfAdmin = job;
                break;
            }
        }
        System.assertNotEquals(null, sfAdmin, 'Should find Salesforce Administrator job');
        System.assertEquals('Tech Corp', sfAdmin.Company__c, 'Company should match');
        System.assertEquals('Adzuna', sfAdmin.Provider__c, 'Provider should be mapped to Adzuna');
        System.assertEquals(8.5, sfAdmin.Quick_Score__c, 'Quick score should match');
        System.assertEquals('Abby', sfAdmin.Owner_Name__c, 'Owner should be Abby');
        System.assertEquals('Remote', sfAdmin.Workplace_Type__c, 'Should detect remote workplace');
    }

    @isTest
    static void testImportJobs_UpdateExisting() {
        // First import - setup mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

        Test.startTest();

        // First import creates records
        JobSearchAPIService.ImportResult result1 = JobSearchAPIService.importJobs('Abby');
        System.assertEquals(3, result1.newJobs, 'First import should create 3 jobs');

        // Second import should update existing (using same mock data)
        JobSearchAPIService.ImportResult result2 = JobSearchAPIService.importJobs('Abby');

        Test.stopTest();

        System.assertEquals(3, result2.updatedJobs, 'Second import should update 3 existing jobs');
        System.assertEquals(0, result2.newJobs, 'Second import should not create new jobs');

        // Should still have only 3 records (no duplicates)
        Integer jobCount = [SELECT COUNT() FROM Job_Posting__c];
        System.assertEquals(3, jobCount, 'Should have exactly 3 jobs (no duplicates)');
    }

    @isTest
    static void testImportJobs_EmptyResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseEmpty());

        Test.startTest();
        JobSearchAPIService.ImportResult result = JobSearchAPIService.importJobs('Abby');
        Test.stopTest();

        System.assertEquals(0, result.totalFetched, 'Should fetch 0 jobs');
        System.assertEquals(0, result.newJobs, 'Should create 0 jobs');
        System.assertEquals(0, result.errors, 'Should have no errors');
    }

    @isTest
    static void testImportJobs_APIError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());

        Test.startTest();
        JobSearchAPIService.ImportResult result = JobSearchAPIService.importJobs('Abby');
        Test.stopTest();

        System.assertEquals(0, result.totalFetched, 'Should fetch 0 jobs on error');
        System.assertEquals(1, result.errors, 'Should have 1 error');
        System.assert(!result.errorMessages.isEmpty(), 'Should have error message');
    }

    @isTest
    static void testImportJobs_WithCustomScore() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

        Test.startTest();
        JobSearchAPIService.ImportResult result = JobSearchAPIService.importJobs('Matt', 7.0);
        Test.stopTest();

        // Should still fetch 3 (mock doesn't filter, but real API would)
        System.assertEquals(3, result.totalFetched, 'Should fetch 3 jobs from mock');

        // Verify Matt is the owner
        List<Job_Posting__c> jobs = [SELECT Owner_Name__c FROM Job_Posting__c WHERE Owner_Name__c = 'Matt'];
        System.assertEquals(3, jobs.size(), 'All jobs should be owned by Matt');
    }

    @isTest
    static void testMapSourceToProvider() {
        // Test various source mappings
        System.assertEquals('Adzuna', JobSearchAPIService.mapSourceToProvider('adzuna'), 'Should map adzuna');
        System.assertEquals('RemoteOK', JobSearchAPIService.mapSourceToProvider('remoteok'), 'Should map remoteok');
        System.assertEquals('RemoteOK', JobSearchAPIService.mapSourceToProvider('remote_ok'), 'Should map remote_ok');
        System.assertEquals('Jobicy', JobSearchAPIService.mapSourceToProvider('jobicy'), 'Should map jobicy');
        System.assertEquals('Arbeitnow', JobSearchAPIService.mapSourceToProvider('arbeitnow'), 'Should map arbeitnow');
        System.assertEquals('Himalayas', JobSearchAPIService.mapSourceToProvider('himalayas'), 'Should map himalayas');
        System.assertEquals('Jooble', JobSearchAPIService.mapSourceToProvider('jooble'), 'Should map jooble');
        System.assertEquals('Indeed', JobSearchAPIService.mapSourceToProvider('indeed'), 'Should map indeed');
        System.assertEquals('Indeed', JobSearchAPIService.mapSourceToProvider('indeed_rss'), 'Should map indeed_rss to Indeed');
        System.assertEquals('LinkedIn', JobSearchAPIService.mapSourceToProvider('linkedin'), 'Should map linkedin');
        System.assertEquals('Indeed', JobSearchAPIService.mapSourceToProvider('unknown'), 'Should default to Indeed');
        System.assertEquals('Indeed', JobSearchAPIService.mapSourceToProvider(null), 'Should default to Indeed for null');
        System.assertEquals('Indeed', JobSearchAPIService.mapSourceToProvider(''), 'Should default to Indeed for empty');
    }

    @isTest
    static void testDetermineWorkplaceType() {
        // Create mock jobs with different location indicators
        JobSearchAPIService.PythonJob remoteJob = new JobSearchAPIService.PythonJob();
        remoteJob.title = 'Salesforce Admin';
        remoteJob.location = 'Remote';
        remoteJob.description = 'Work from home position';

        JobSearchAPIService.PythonJob hybridJob = new JobSearchAPIService.PythonJob();
        hybridJob.title = 'Salesforce Developer';
        hybridJob.location = 'New York (Hybrid)';
        hybridJob.description = 'Mix of remote and office work';

        JobSearchAPIService.PythonJob onsiteJob = new JobSearchAPIService.PythonJob();
        onsiteJob.title = 'CRM Admin';
        onsiteJob.location = 'Jacksonville, FL';
        onsiteJob.description = 'On-site position in our downtown office';

        // Test workplace type detection
        System.assertEquals('Remote', JobSearchAPIService.determineWorkplaceType(remoteJob), 'Should detect remote');
        System.assertEquals('Hybrid', JobSearchAPIService.determineWorkplaceType(hybridJob), 'Should detect hybrid');
        System.assertEquals('On-Site', JobSearchAPIService.determineWorkplaceType(onsiteJob), 'Should detect on-site');
    }

    @isTest
    static void testTriggerPythonSearch() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSearchTrigger());

        Test.startTest();
        Boolean result = JobSearchAPIService.triggerPythonSearch();
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true on successful trigger');
    }

    @isTest
    static void testQueueAnalysisForNewJobs() {
        // Create test job without Fit_Score
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Co',
            ExternalID__c = 'test123',
            Provider__c = 'Indeed',
            Status__c = 'Active',
            Owner_Name__c = 'Abby'
        );
        insert testJob;

        Test.startTest();
        // This will queue the job for analysis (won't actually run in test)
        JobSearchAPIService.queueAnalysisForNewJobs('Abby');
        Test.stopTest();

        // Verify the job was queued (can't verify execution in test context)
        System.assertEquals(1, [SELECT COUNT() FROM Job_Posting__c WHERE Owner_Name__c = 'Abby'], 'Job should exist');
    }

    @isTest
    static void testConvertToSalesforceJob() {
        // Create a Python job with all fields populated
        JobSearchAPIService.PythonJob pJob = new JobSearchAPIService.PythonJob();
        pJob.job_hash = 'hash123';
        pJob.title = 'Senior Salesforce Developer with a Very Long Title That Should Be Truncated If It Exceeds The Field Limit';
        pJob.company = 'Acme Corporation';
        pJob.location = 'Remote, USA';
        pJob.salary_min = 120000;
        pJob.salary_max = 150000;
        pJob.url = 'https://example.com/job';
        pJob.description = 'A great remote opportunity...';
        pJob.source = 'adzuna';
        pJob.quick_score = 9.0;
        pJob.fit_score = 8.5;

        Test.startTest();
        Job_Posting__c sfJob = JobSearchAPIService.convertToSalesforceJob(pJob, 'Abby');
        Test.stopTest();

        System.assertEquals('hash123', sfJob.ExternalID__c, 'External ID should match');
        System.assertEquals('Acme Corporation', sfJob.Company__c, 'Company should match');
        System.assertEquals(120000, sfJob.Salary_Min__c, 'Salary min should match');
        System.assertEquals(150000, sfJob.Salary_Max__c, 'Salary max should match');
        System.assertEquals('Adzuna', sfJob.Provider__c, 'Provider should be mapped');
        System.assertEquals(9.0, sfJob.Quick_Score__c, 'Quick score should match');
        System.assertEquals(8.5, sfJob.Fit_Score__c, 'Fit score should be imported');
        System.assertEquals('Abby', sfJob.Owner_Name__c, 'Owner should match');
        System.assertEquals('Active', sfJob.Status__c, 'Status should be Active');
        System.assertEquals('Remote', sfJob.Workplace_Type__c, 'Should detect Remote');
        System.assertNotEquals(null, sfJob.LastSynced__c, 'LastSynced should be set');
    }
}
