/**
 * Trigger: OpportunityCreationTrigger
 * Object: Job_Posting__c
 * Purpose: Create Opportunity, Account, and Contact immediately when job is captured
 *
 * On Job_Posting__c insert (from Chrome extension):
 * 1. Create/find Account for the company
 * 2. Create Contact from recruiter information
 * 3. Create Opportunity linked to Job_Posting__c
 * 4. Link Contact to Opportunity as Contact Role
 *
 * Note: Job_Posting__c serves as a background staging object.
 * Users work exclusively from the Opportunity record.
 */
trigger OpportunityCreationTrigger on Job_Posting__c (after insert) {
    OpportunityCreationHandler.handleOpportunityCreation(Trigger.new);
}
