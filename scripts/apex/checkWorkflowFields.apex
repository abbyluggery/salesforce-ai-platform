// Check workflow tracking fields on recent Opportunities

List<Opportunity> opps = [
    SELECT Id, Name, Job_Discovered_Date__c, Application_Prepared_Date__c,
           Apply_URL__c, CreatedDate,
           (SELECT Id, Generated_Date__c FROM Resume_Packages__r ORDER BY CreatedDate DESC LIMIT 1)
    FROM Opportunity
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('===== WORKFLOW TRACKING FIELD STATUS =====');
for (Opportunity opp : opps) {
    System.debug('');
    System.debug('Opportunity: ' + opp.Name);
    System.debug('  Created: ' + opp.CreatedDate);
    System.debug('  Job Discovered: ' + (opp.Job_Discovered_Date__c != null ? String.valueOf(opp.Job_Discovered_Date__c) : 'NULL'));
    System.debug('  Application Prepared: ' + (opp.Application_Prepared_Date__c != null ? String.valueOf(opp.Application_Prepared_Date__c) : 'NULL'));
    System.debug('  Apply URL: ' + (opp.Apply_URL__c != null ? 'Has Link' : 'NULL'));
    System.debug('  Resume Packages: ' + opp.Resume_Packages__r.size());

    if (!opp.Resume_Packages__r.isEmpty()) {
        System.debug('    Latest Resume Generated: ' + opp.Resume_Packages__r[0].Generated_Date__c);
    }
}
