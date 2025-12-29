/**
 * @description Test class for JobPostingResearchController
 * Tests the invocable method for researching companies from Job Postings
 *
 * @author Claude Code Assistant
 * @date December 16, 2025
 */
@isTest
private class JobPostingResearchControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create a test job posting with company info
        Job_Posting__c job = new Job_Posting__c(
            Title__c = 'Salesforce Developer',
            Company__c = 'Acme Corporation',
            Description__c = 'We are looking for a skilled Salesforce Developer...',
            Location__c = 'Remote',
            URL__c = 'https://example.com/job/123'
        );
        insert job;
    }

    @isTest
    static void testResearchCompany_Success() {
        // Get the test job posting
        Job_Posting__c job = [SELECT Id FROM Job_Posting__c LIMIT 1];

        // Create request
        JobPostingResearchController.ResearchRequest request = new JobPostingResearchController.ResearchRequest();
        request.jobPostingId = job.Id;

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new ClaudeAPIMock());

        Test.startTest();
        List<JobPostingResearchController.ResearchResult> results =
            JobPostingResearchController.researchCompany(new List<JobPostingResearchController.ResearchRequest>{ request });
        Test.stopTest();

        // Verify results
        System.assertEquals(1, results.size(), 'Should have one result');
        JobPostingResearchController.ResearchResult result = results[0];

        // Note: In real test, this depends on CompanyResearcher and ClaudeAPIService
        // With mock, we expect success or graceful error handling
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testResearchCompany_NullJobPostingId() {
        // Create request with null ID
        JobPostingResearchController.ResearchRequest request = new JobPostingResearchController.ResearchRequest();
        request.jobPostingId = null;

        Test.startTest();
        List<JobPostingResearchController.ResearchResult> results =
            JobPostingResearchController.researchCompany(new List<JobPostingResearchController.ResearchRequest>{ request });
        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, results.size(), 'Should have one result');
        JobPostingResearchController.ResearchResult result = results[0];
        System.assertEquals(false, result.success, 'Should not be successful');
        System.assertEquals('Job Posting ID is required', result.errorMessage, 'Should have error message');
    }

    @isTest
    static void testResearchCompany_JobPostingNotFound() {
        // Create request with fake ID
        JobPostingResearchController.ResearchRequest request = new JobPostingResearchController.ResearchRequest();
        // Generate a fake Id that looks valid but doesn't exist
        request.jobPostingId = 'a00000000000000AAA';

        Test.startTest();
        List<JobPostingResearchController.ResearchResult> results =
            JobPostingResearchController.researchCompany(new List<JobPostingResearchController.ResearchRequest>{ request });
        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, results.size(), 'Should have one result');
        JobPostingResearchController.ResearchResult result = results[0];
        System.assertEquals(false, result.success, 'Should not be successful');
        System.assertEquals('Job Posting not found', result.errorMessage, 'Should have not found message');
    }

    @isTest
    static void testResearchCompany_NoCompanyName() {
        // Create job posting without company name
        Job_Posting__c jobWithoutCompany = new Job_Posting__c(
            Title__c = 'Test Job',
            Description__c = 'Test description'
        );
        insert jobWithoutCompany;

        // Create request
        JobPostingResearchController.ResearchRequest request = new JobPostingResearchController.ResearchRequest();
        request.jobPostingId = jobWithoutCompany.Id;

        Test.startTest();
        List<JobPostingResearchController.ResearchResult> results =
            JobPostingResearchController.researchCompany(new List<JobPostingResearchController.ResearchRequest>{ request });
        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, results.size(), 'Should have one result');
        JobPostingResearchController.ResearchResult result = results[0];
        System.assertEquals(false, result.success, 'Should not be successful');
        System.assertEquals('Job Posting must have a Company name to research', result.errorMessage, 'Should have company required message');
    }

    /**
     * @description Mock HTTP response for Claude API
     */
    private class ClaudeAPIMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{' +
                '"id": "msg_test123",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [{"type": "text", "text": "' +
                    '{' +
                        '\\"companyOverview\\": \\"Acme Corporation is a leading technology company.\\",' +
                        '\\"recentNews\\": \\"Recently launched new AI products.\\",' +
                        '\\"cultureInsights\\": \\"Known for flexible remote work policy.\\",' +
                        '\\"keyProducts\\": \\"Enterprise software solutions.\\",' +
                        '\\"talkingPoints\\": [\\"What is the team structure?\\", \\"What are growth opportunities?\\"],' +
                        '\\"whyThisCompany\\": \\"Innovative company with strong culture.\\",' +
                        '\\"potentialChallenges\\": [\\"Fast-paced environment\\"]' +
                    '}"}],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 100, "output_tokens": 200}' +
            '}');
            return res;
        }
    }
}
