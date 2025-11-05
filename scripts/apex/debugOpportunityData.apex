// Debug script to check Opportunity data for resume generation

// Query recent Opportunities
List<Opportunity> opps = [
    SELECT Id, Name, Job_Posting__c, Job_Posting__r.Title__c,
           Job_Posting__r.Company__c, StageName
    FROM Opportunity
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('===== OPPORTUNITY DEBUG =====');
System.debug('Found ' + opps.size() + ' opportunities');

for (Opportunity opp : opps) {
    System.debug('---');
    System.debug('Opportunity: ' + opp.Name + ' (' + opp.Id + ')');
    System.debug('Stage: ' + opp.StageName);
    System.debug('Job Posting ID: ' + opp.Job_Posting__c);
    System.debug('Job Title: ' + (opp.Job_Posting__r != null ? opp.Job_Posting__r.Title__c : 'NULL'));
    System.debug('Company: ' + (opp.Job_Posting__r != null ? opp.Job_Posting__r.Company__c : 'NULL'));
}

// Check Resume Package object structure
System.debug('===== RESUME PACKAGE FIELDS =====');
Schema.DescribeSObjectResult resDesc = Resume_Package__c.sObjectType.getDescribe();
Map<String, Schema.SObjectField> fieldMap = resDesc.fields.getMap();

if (fieldMap.containsKey('opportunity__c')) {
    System.debug('✓ Opportunity__c field EXISTS on Resume_Package__c');
} else {
    System.debug('✗ Opportunity__c field MISSING on Resume_Package__c');
}

// Check if OpportunityResumeGeneratorInvocable class exists
try {
    Type invocableType = Type.forName('OpportunityResumeGeneratorInvocable');
    if (invocableType != null) {
        System.debug('✓ OpportunityResumeGeneratorInvocable class EXISTS');
    }
} catch (Exception e) {
    System.debug('✗ OpportunityResumeGeneratorInvocable class ERROR: ' + e.getMessage());
}

System.debug('===== DEBUG COMPLETE =====');
