// Test script to verify Job_Discovered_Date__c functionality
// This will manually set the date on recent Opportunities to test the field

List<Opportunity> recentOpps = [
    SELECT Id, Name, Job_Discovered_Date__c, CreatedDate
    FROM Opportunity
    ORDER BY CreatedDate DESC
    LIMIT 3
];

System.debug('===== RECENT OPPORTUNITIES =====');
for (Opportunity opp : recentOpps) {
    System.debug('Opportunity: ' + opp.Name);
    System.debug('  Created: ' + opp.CreatedDate);
    System.debug('  Job Discovered: ' + opp.Job_Discovered_Date__c);

    // If Job_Discovered_Date__c is null, set it to CreatedDate as a test
    if (opp.Job_Discovered_Date__c == null) {
        opp.Job_Discovered_Date__c = opp.CreatedDate;
        System.debug('  -> Setting Job_Discovered_Date__c to: ' + opp.CreatedDate);
    }
}

// Update the opportunities
if (!recentOpps.isEmpty()) {
    update recentOpps;
    System.debug('Updated ' + recentOpps.size() + ' opportunities with Job_Discovered_Date__c');
}
