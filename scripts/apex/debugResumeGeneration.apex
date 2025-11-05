// Debug script to check if resume generation is working and updating dates

// Get the most recent Resume Package
List<Resume_Package__c> packages = [
    SELECT Id, Name, Opportunity__c, Opportunity__r.Name,
           Opportunity__r.Application_Prepared_Date__c, Generated_Date__c
    FROM Resume_Package__c
    ORDER BY CreatedDate DESC
    LIMIT 1
];

if (packages.isEmpty()) {
    System.debug('ERROR: No resume packages found');
} else {
    Resume_Package__c pkg = packages[0];
    System.debug('===== MOST RECENT RESUME PACKAGE =====');
    System.debug('Resume Package: ' + pkg.Name);
    System.debug('Generated Date: ' + pkg.Generated_Date__c);
    System.debug('Linked Opportunity: ' + pkg.Opportunity__r.Name);
    System.debug('Opportunity Application Prepared Date: ' + pkg.Opportunity__r.Application_Prepared_Date__c);

    if (pkg.Opportunity__r.Application_Prepared_Date__c == null) {
        System.debug('');
        System.debug('WARNING: Application_Prepared_Date__c is NULL on the Opportunity!');
        System.debug('This means the OpportunityResumeGeneratorInvocable is NOT updating the date.');
    } else {
        System.debug('');
        System.debug('SUCCESS: Application_Prepared_Date__c is set!');
    }
}
