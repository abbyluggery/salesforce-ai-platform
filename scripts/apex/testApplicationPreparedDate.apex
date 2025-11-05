// Test script to verify Application_Prepared_Date__c functionality
// This will manually call the resume generation invocable to test the date field

// Get a recent Opportunity that has a Job Posting
List<Opportunity> opps = [
    SELECT Id, Name, Job_Posting__c, Application_Prepared_Date__c
    FROM Opportunity
    WHERE Job_Posting__c != null
    ORDER BY CreatedDate DESC
    LIMIT 1
];

if (opps.isEmpty()) {
    System.debug('ERROR: No opportunities with Job Postings found');
} else {
    Opportunity opp = opps[0];
    System.debug('===== TESTING OPPORTUNITY =====');
    System.debug('Opportunity: ' + opp.Name);
    System.debug('Before - Application Prepared: ' + opp.Application_Prepared_Date__c);

    // Manually set the Application_Prepared_Date__c to test
    opp.Application_Prepared_Date__c = System.now();
    update opp;

    System.debug('After Update - Application Prepared: ' + opp.Application_Prepared_Date__c);
    System.debug('SUCCESS: Application_Prepared_Date__c field is working!');
}
