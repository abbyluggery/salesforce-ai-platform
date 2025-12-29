/**
 * @description Queueable class to analyze job postings asynchronously
 * This allows API callouts to run in the background without blocking the UI
 *
 * LEARNING NOTES:
 * - Queueable: Runs asynchronously, allows chaining, supports callouts
 * - Why async? API calls can be slow - don't make users wait
 * - Implements Database.AllowsCallouts to enable HTTP requests
 * - Processes jobs in small batches to avoid timeout (max 2 per execution)
 *
 * @author Claude Code Assistant
 * @date 2025-10-27
 */
public class JobPostingAnalysisQueue implements Queueable, Database.AllowsCallouts {

    private List<Id> jobPostingIds;

    // Process only 2 jobs per execution to avoid 120-second timeout
    // Each Claude API call can take 30-60 seconds
    private static final Integer BATCH_SIZE = 2;

    /**
     * @description Constructor - takes job posting IDs to analyze
     * @param jobPostingIds List of Job_Posting__c record IDs
     */
    public JobPostingAnalysisQueue(List<Id> jobPostingIds) {
        this.jobPostingIds = jobPostingIds;
    }

    /**
     * @description Execute method - runs the async job
     * Processes a small batch and chains to the next batch if more remain
     * LEARNING: This is called automatically by Salesforce when the job runs
     */
    public void execute(QueueableContext context) {
        // Take only BATCH_SIZE jobs for this execution
        List<Id> currentBatch = new List<Id>();
        List<Id> remainingIds = new List<Id>();

        for (Integer i = 0; i < jobPostingIds.size(); i++) {
            if (i < BATCH_SIZE) {
                currentBatch.add(jobPostingIds[i]);
            } else {
                remainingIds.add(jobPostingIds[i]);
            }
        }

        System.debug('Processing batch of ' + currentBatch.size() + ' jobs. Remaining: ' + remainingIds.size());

        // Query the job postings with all fields needed for analysis
        List<Job_Posting__c> jobsToAnalyze = [
            SELECT Id, Title__c, Company__c, Location__c, Workplace_Type__c,
                   Remote_Policy__c, Salary_Min__c, Salary_Max__c, Description__c,
                   Fit_Score__c, ND_Friendliness_Score__c, Application_Status__c
            FROM Job_Posting__c
            WHERE Id IN :currentBatch
        ];

        List<Job_Posting__c> jobsToUpdate = new List<Job_Posting__c>();

        // Analyze each job posting in the current batch
        for (Job_Posting__c job : jobsToAnalyze) {
            // Skip records without a description (cannot filter LTA in SOQL)
            if (String.isBlank(job.Description__c)) {
                System.debug('Skipping analysis for job without description: ' + job.Id);
                continue;
            }
            try {
                // Call the analyzer
                JobPostingAnalyzer.JobAnalysisResult result = JobPostingAnalyzer.analyzeJob(job);

                // Update the job record with results
                job.Fit_Score__c = result.fitScore;
                job.ND_Friendliness_Score__c = result.ndFriendlinessScore;
                job.Green_Flags__c = result.greenFlags;
                job.Red_Flags__c = result.redFlags;

                // Set initial application status if not already set
                if (String.isBlank(job.Application_Status__c)) {
                    job.Application_Status__c = 'Not Applied';
                }

                jobsToUpdate.add(job);

                System.debug('Analyzed: ' + job.Title__c + ' - Fit Score: ' + result.fitScore);

            } catch (Exception e) {
                // Log error but continue processing other jobs
                System.debug(LoggingLevel.ERROR, 'Failed to analyze job ' + job.Id + ': ' + e.getMessage());

                // Mark job with error flag so user knows it needs attention
                job.Red_Flags__c = 'Analysis failed: ' + e.getMessage();
                jobsToUpdate.add(job);
            }
        }

        // Update all analyzed jobs
        if (!jobsToUpdate.isEmpty()) {
            try {
                update jobsToUpdate;
                System.debug('Successfully updated ' + jobsToUpdate.size() + ' job postings with analysis results');
            } catch (DmlException e) {
                System.debug(LoggingLevel.ERROR, 'Failed to update job postings: ' + e.getMessage());
            }
        }

        // Chain to next batch if there are more jobs to process
        if (!remainingIds.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new JobPostingAnalysisQueue(remainingIds));
            System.debug('Chained next batch with ' + remainingIds.size() + ' remaining jobs');
        }
    }

    /**
     * @description Static method to enqueue job analysis
     * Makes it easy to call from triggers or other code
     *
     * @param jobPostingIds List of Job_Posting__c IDs to analyze
     */
    public static void enqueueAnalysis(List<Id> jobPostingIds) {
        if (!jobPostingIds.isEmpty()) {
            JobPostingAnalysisQueue queueJob = new JobPostingAnalysisQueue(jobPostingIds);
            System.enqueueJob(queueJob);
            System.debug('Enqueued analysis for ' + jobPostingIds.size() + ' job postings (will process in batches of ' + BATCH_SIZE + ')');
        }
    }
}
