/**
 * @description Test class for OpportunityResumeGeneratorInvocable
 * Tests Opportunity-based resume generation for Flow integration
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-03
 */
@isTest
private class OpportunityResumeGeneratorInvocableTest {

    /**
     * @description Mock HTTP callout for resume generation
     */
    private class InvocableMockSuccess implements HttpCalloutMock {
        private Integer callCount = 0;

        public HTTPResponse respond(HTTPRequest req) {
            callCount++;

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String responseText = (callCount == 1) ?
                'JOHN DOE\\nSalesforce Developer\\n\\nEXPERIENCE...' :
                'Dear Hiring Manager,\\n\\nI am interested...';

            String responseBody = '{' +
                '"id": "msg_opp_invocable_' + callCount + '",' +
                '"type": "message",' +
                '"role": "assistant",' +
                '"content": [{"type": "text", "text": "' + responseText + '"}],' +
                '"model": "claude-3-haiku-20240307",' +
                '"stop_reason": "end_turn",' +
                '"usage": {"input_tokens": 200, "output_tokens": 150}' +
            '}';

            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description Test successful invocable method execution from Opportunity
     */
    @isTest
    static void testGenerateResumeFromOpportunity_Success() {
        Test.setMock(HttpCalloutMock.class, new InvocableMockSuccess());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Salesforce Developer',
            Company__c = 'Tech Company',
            Location__c = 'Remote',
            Description__c = 'Great opportunity',
            Apply_URL__c = 'https://example.com/apply',
            Provider__c = 'LinkedIn',
            ExternalID__c = 'TEST-OPP-INVOCABLE-001',
            Status__c = 'Active'
        );
        insert testJob;

        Account testAccount = new Account(Name = 'Tech Company');
        insert testAccount;

        Opportunity testOpp = new Opportunity(
            Name = 'Salesforce Developer - Tech Company',
            AccountId = testAccount.Id,
            Job_Posting__c = testJob.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'JOHN DOE\\nSalesforce Developer\\nExperience...'
        );
        insert masterResume;

        // Create invocable request
        OpportunityResumeGeneratorInvocable.Request request = new OpportunityResumeGeneratorInvocable.Request();
        request.opportunityId = testOpp.Id;

        List<OpportunityResumeGeneratorInvocable.Request> requests = new List<OpportunityResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<OpportunityResumeGeneratorInvocable.Result> results =
            OpportunityResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].success, 'Generation should be successful');
        System.assertNotEquals(null, results[0].resumePackageId, 'Should return resume package ID');
        System.assert(results[0].message.contains('successfully'), 'Success message should be positive');

        // Verify resume package was created and linked to Opportunity
        List<Resume_Package__c> packages = [
            SELECT Id, Job_Posting__c, Opportunity__c
            FROM Resume_Package__c
            WHERE Opportunity__c = :testOpp.Id
        ];
        System.assertEquals(1, packages.size(), 'Should create one resume package');
        System.assertEquals(testOpp.Id, packages[0].Opportunity__c, 'Should link to Opportunity');
        System.assertEquals(testJob.Id, packages[0].Job_Posting__c, 'Should link to Job Posting');
    }

    /**
     * @description Test error handling when Opportunity not found
     */
    @isTest
    static void testGenerateResumeFromOpportunity_OpportunityNotFound() {
        // Create request with fake ID
        OpportunityResumeGeneratorInvocable.Request request = new OpportunityResumeGeneratorInvocable.Request();
        request.opportunityId = '006000000000000AAA'; // Fake ID

        List<OpportunityResumeGeneratorInvocable.Request> requests = new List<OpportunityResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<OpportunityResumeGeneratorInvocable.Result> results =
            OpportunityResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].success, 'Generation should fail');
        System.assertEquals(null, results[0].resumePackageId, 'Should not have resume package ID');
        System.assert(results[0].message.contains('not found'), 'Should indicate Opportunity not found');
    }

    /**
     * @description Test error handling when Opportunity has no Job Posting
     */
    @isTest
    static void testGenerateResumeFromOpportunity_NoJobPosting() {
        // Create Opportunity without Job Posting link
        Account testAccount = new Account(Name = 'Test Company');
        insert testAccount;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
            // No Job_Posting__c link
        );
        insert testOpp;

        // Create request
        OpportunityResumeGeneratorInvocable.Request request = new OpportunityResumeGeneratorInvocable.Request();
        request.opportunityId = testOpp.Id;

        List<OpportunityResumeGeneratorInvocable.Request> requests = new List<OpportunityResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<OpportunityResumeGeneratorInvocable.Result> results =
            OpportunityResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].success, 'Generation should fail');
        System.assertEquals(null, results[0].resumePackageId, 'Should not have resume package ID');
        System.assert(results[0].message.contains('not linked'), 'Should indicate no Job Posting');
    }

    /**
     * @description Test API error handling
     */
    @isTest
    static void testGenerateResumeFromOpportunity_APIError() {
        Test.setMock(HttpCalloutMock.class, new APIErrorMock());

        // Create test data
        Job_Posting__c testJob = new Job_Posting__c(
            Title__c = 'Test Job',
            Company__c = 'Test Company',
            Location__c = 'Remote',
            Apply_URL__c = 'https://example.com/apply',
            Provider__c = 'LinkedIn',
            ExternalID__c = 'TEST-OPP-INVOCABLE-002',
            Status__c = 'Active'
        );
        insert testJob;

        Account testAccount = new Account(Name = 'Test Company');
        insert testAccount;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            Job_Posting__c = testJob.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;

        Master_Resume_Config__c masterResume = new Master_Resume_Config__c(
            Resume_Content__c = 'Test resume'
        );
        insert masterResume;

        // Create request
        OpportunityResumeGeneratorInvocable.Request request = new OpportunityResumeGeneratorInvocable.Request();
        request.opportunityId = testOpp.Id;

        List<OpportunityResumeGeneratorInvocable.Request> requests = new List<OpportunityResumeGeneratorInvocable.Request>();
        requests.add(request);

        Test.startTest();

        List<OpportunityResumeGeneratorInvocable.Result> results =
            OpportunityResumeGeneratorInvocable.generateResumePackages(requests);

        Test.stopTest();

        // Verify error was caught and returned
        System.assertEquals(false, results[0].success, 'Should report failure');
        System.assert(results[0].message.contains('Error'), 'Should include error message');
    }

    /**
     * @description Mock for API error
     */
    private class APIErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal error"}');
            return res;
        }
    }
}
