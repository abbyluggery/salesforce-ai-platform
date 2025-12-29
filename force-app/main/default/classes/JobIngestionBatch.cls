public with sharing class JobIngestionBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all active job sources
        return Database.getQueryLocator([
            SELECT Id, Provider__c, Token__c, Site__c, ApiKey__c
            FROM JobSource__mdt
            WHERE IsActive__c = true
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<JobSource__mdt> jobSources) {
        List<JobPosting__c> postingsToInsert = new List<JobPosting__c>();
        
        for (JobSource__mdt source : jobSources) {
            if (source.Provider__c == 'Greenhouse' && source.Token__c != null) {
                try {
                    List<JobPosting__c> greenhousePostings = GreenhouseProvider.fetchJobs(source.Token__c);
                    postingsToInsert.addAll(greenhousePostings);
                } catch (Exception e) {
                    System.debug('Error fetching Greenhouse jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'Lever' && source.Site__c != null) {
                try {
                    List<JobPosting__c> leverPostings = LeverProvider.fetchJobs(source.Site__c);
                    postingsToInsert.addAll(leverPostings);
                } catch (Exception e) {
                    System.debug('Error fetching Lever jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'LinkedIn' && source.ApiKey__c != null) {
                try {
                    List<JobPosting__c> linkedinPostings = LinkedInProvider.fetchJobs(source.ApiKey__c);
                    postingsToInsert.addAll(linkedinPostings);
                } catch (Exception e) {
                    System.debug('Error fetching LinkedIn jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'Dice' && source.ApiKey__c != null) {
                try {
                    List<JobPosting__c> dicePostings = DiceProvider.fetchJobs(source.ApiKey__c);
                    postingsToInsert.addAll(dicePostings);
                } catch (Exception e) {
                    System.debug('Error fetching Dice jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'Indeed' && source.ApiKey__c != null) {
                try {
                    List<JobPosting__c> indeedPostings = IndeedProvider.fetchJobs(source.ApiKey__c);
                    postingsToInsert.addAll(indeedPostings);
                } catch (Exception e) {
                    System.debug('Error fetching Indeed jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'Glassdoor' && source.ApiKey__c != null) {
                try {
                    List<JobPosting__c> glassdoorPostings = GlassdoorProvider.fetchJobs(source.ApiKey__c);
                    postingsToInsert.addAll(glassdoorPostings);
                } catch (Exception e) {
                    System.debug('Error fetching Glassdoor jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'Ladders' && source.ApiKey__c != null) {
                try {
                    List<JobPosting__c> laddersPostings = LaddersProvider.fetchJobs(source.ApiKey__c);
                    postingsToInsert.addAll(laddersPostings);
                } catch (Exception e) {
                    System.debug('Error fetching Ladders jobs: ' + e.getMessage());
                }
            } else if (source.Provider__c == 'FlexJobs' && source.ApiKey__c != null) {
                try {
                    List<JobPosting__c> flexjobsPostings = FlexJobsProvider.fetchJobs(source.ApiKey__c);
                    postingsToInsert.addAll(flexjobsPostings);
                } catch (Exception e) {
                    System.debug('Error fetching FlexJobs jobs: ' + e.getMessage());
                }
            }
        }
        
        // Upsert the postings
        if (!postingsToInsert.isEmpty()) {
            upsert postingsToInsert ExternalId__c;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Optional: Send notification or log completion
        System.debug('Job ingestion batch finished.');
    }
}
