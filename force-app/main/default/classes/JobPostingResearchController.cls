/**
 * @description Controller for Job Posting research Quick Action
 * Invocable method to trigger company research from Job_Posting__c button
 *
 * LEARNING NOTES:
 * - Invocable Methods: Allow Flow/Process Builder/Quick Actions to call Apex
 * - @InvocableMethod: Makes method callable from declarative tools
 * - Reuses CompanyResearcher: Same AI logic, different entry point
 *
 * @author Claude Code Assistant
 * @date December 16, 2025
 */
public with sharing class JobPostingResearchController {

    /**
     * @description Input wrapper for invocable method
     */
    public class ResearchRequest {
        @InvocableVariable(required=true label='Job Posting ID' description='The Job_Posting__c record to research')
        public Id jobPostingId;
    }

    /**
     * @description Output wrapper for invocable method
     */
    public class ResearchResult {
        @InvocableVariable(label='Company Research ID' description='ID of created Company_Research__c record')
        public Id companyResearchId;

        @InvocableVariable(label='Success' description='Whether research was successful')
        public Boolean success;

        @InvocableVariable(label='Error Message' description='Error message if research failed')
        public String errorMessage;
    }

    /**
     * @description Generate company research for a Job Posting
     * Called from Quick Action button on Job Posting page
     *
     * @param requests List of ResearchRequest containing Job Posting IDs
     * @return List<ResearchResult> Results of research generation
     */
    @InvocableMethod(label='Research Company for Job' description='Generate AI-powered company research for this Job Posting' category='Job Search')
    public static List<ResearchResult> researchCompany(List<ResearchRequest> requests) {
        List<ResearchResult> results = new List<ResearchResult>();

        for (ResearchRequest request : requests) {
            ResearchResult result = new ResearchResult();
            result.success = false;

            try {
                // Validate input
                if (request.jobPostingId == null) {
                    result.errorMessage = 'Job Posting ID is required';
                    results.add(result);
                    continue;
                }

                // Verify the job posting exists and has company info
                List<Job_Posting__c> jobs = [
                    SELECT Id, Company__c, Title__c
                    FROM Job_Posting__c
                    WHERE Id = :request.jobPostingId
                    LIMIT 1
                ];

                if (jobs.isEmpty()) {
                    result.errorMessage = 'Job Posting not found';
                    results.add(result);
                    continue;
                }

                Job_Posting__c job = jobs[0];
                if (String.isBlank(job.Company__c)) {
                    result.errorMessage = 'Job Posting must have a Company name to research';
                    results.add(result);
                    continue;
                }

                // Call CompanyResearcher to generate research
                Id researchId = CompanyResearcher.generateResearch(request.jobPostingId);

                if (researchId != null) {
                    result.companyResearchId = researchId;
                    result.success = true;
                    System.debug('JobPostingResearchController: Successfully generated research: ' + researchId);
                } else {
                    result.errorMessage = 'Failed to generate research - no record created';
                }

            } catch (Exception e) {
                result.errorMessage = e.getMessage();
                System.debug(LoggingLevel.ERROR, 'JobPostingResearchController Error: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            }

            results.add(result);
        }

        return results;
    }

}
