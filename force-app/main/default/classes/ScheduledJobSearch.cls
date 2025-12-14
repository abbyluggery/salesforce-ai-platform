/**
 * @description Schedulable class to automatically import jobs from the Python job search API.
 * Can be scheduled to run daily or at any custom interval.
 *
 * Schedule examples:
 * - Daily at 8am: System.schedule('Daily Job Import', '0 0 8 * * ?', new ScheduledJobSearch());
 * - Every 4 hours: System.schedule('Job Import Every 4h', '0 0 0/4 * * ?', new ScheduledJobSearch());
 * - Weekdays at 9am: System.schedule('Weekday Job Import', '0 0 9 ? * MON-FRI', new ScheduledJobSearch());
 *
 * @author Claude Code Assistant
 * @date 2025-12-14
 */
public with sharing class ScheduledJobSearch implements Schedulable {

    // Configuration - can be set via constructor
    private String ownerName;
    private Decimal minScore;
    private Boolean triggerSearchFirst;
    private Boolean runAIAnalysis;

    // Default constructor - imports for all owners
    public ScheduledJobSearch() {
        this.ownerName = null; // All owners
        this.minScore = 6.0;
        this.triggerSearchFirst = false; // Python has its own scheduler
        this.runAIAnalysis = true;
    }

    /**
     * @description Constructor with owner filter
     * @param ownerName Filter jobs by owner (e.g., "Abby" or "Matt")
     */
    public ScheduledJobSearch(String ownerName) {
        this();
        this.ownerName = ownerName;
    }

    /**
     * @description Full configuration constructor
     * @param ownerName Filter jobs by owner (null for all)
     * @param minScore Minimum quick_score to import (0-10)
     * @param triggerSearchFirst If true, trigger Python search before import
     * @param runAIAnalysis If true, queue AI analysis after import
     */
    public ScheduledJobSearch(String ownerName, Decimal minScore, Boolean triggerSearchFirst, Boolean runAIAnalysis) {
        this.ownerName = ownerName;
        this.minScore = minScore;
        this.triggerSearchFirst = triggerSearchFirst;
        this.runAIAnalysis = runAIAnalysis;
    }

    /**
     * @description Schedulable execute method - called by the scheduler
     * @param sc The SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        // Use Queueable for the actual work to avoid callout restrictions in scheduled context
        System.enqueueJob(new JobImportQueueable(ownerName, minScore, triggerSearchFirst, runAIAnalysis));
    }

    /**
     * @description Inner Queueable class to perform the actual import
     * Queueable allows HTTP callouts which Schedulable does not
     */
    public class JobImportQueueable implements Queueable, Database.AllowsCallouts {
        private String ownerName;
        private Decimal minScore;
        private Boolean triggerSearchFirst;
        private Boolean runAIAnalysis;

        public JobImportQueueable(String ownerName, Decimal minScore, Boolean triggerSearchFirst, Boolean runAIAnalysis) {
            this.ownerName = ownerName;
            this.minScore = minScore;
            this.triggerSearchFirst = triggerSearchFirst;
            this.runAIAnalysis = runAIAnalysis;
        }

        public void execute(QueueableContext context) {
            try {
                // Step 1: Optionally trigger Python to search first
                if (triggerSearchFirst) {
                    Boolean searchStarted = JobSearchAPIService.triggerPythonSearch();
                    if (searchStarted) {
                        // Wait a bit for Python to gather jobs (crude but effective)
                        // In production, you might use a callback pattern instead
                        System.debug(LoggingLevel.INFO, 'Python search triggered, proceeding with import');
                    }
                }

                // Step 2: Import jobs from Python API
                String importOwner = String.isNotBlank(ownerName) ? ownerName : 'Abby'; // Default owner
                JobSearchAPIService.ImportResult result = JobSearchAPIService.importJobs(importOwner, minScore);

                // Step 3: Log results
                logImportResult(result);

                // Step 4: Queue AI analysis for new jobs
                if (runAIAnalysis && result.newJobs > 0) {
                    JobSearchAPIService.queueAnalysisForNewJobs(importOwner);
                }

            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'ScheduledJobSearch Error: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());

                // Send error notification (you could add email alerts here)
                logError(e);
            }
        }

        private void logImportResult(JobSearchAPIService.ImportResult result) {
            System.debug(LoggingLevel.INFO, '=== Job Import Summary ===');
            System.debug(LoggingLevel.INFO, 'Total Fetched: ' + result.totalFetched);
            System.debug(LoggingLevel.INFO, 'New Jobs: ' + result.newJobs);
            System.debug(LoggingLevel.INFO, 'Updated Jobs: ' + result.updatedJobs);
            System.debug(LoggingLevel.INFO, 'Errors: ' + result.errors);

            if (!result.errorMessages.isEmpty()) {
                for (String msg : result.errorMessages) {
                    System.debug(LoggingLevel.WARN, 'Error: ' + msg);
                }
            }
        }

        private void logError(Exception e) {
            // Create a simple error log entry
            // You could extend this to create a custom object record or send an email
            System.debug(LoggingLevel.ERROR, 'Job Import Failed at ' + DateTime.now());
            System.debug(LoggingLevel.ERROR, 'Error: ' + e.getMessage());
        }
    }

    // =========================================================================
    // HELPER METHODS FOR SCHEDULING
    // =========================================================================

    /**
     * @description Schedule daily job import at 8am
     * @return String The job ID
     */
    public static String scheduleDailyImport() {
        return scheduleDailyImport('Abby');
    }

    /**
     * @description Schedule daily job import at 8am for a specific owner
     * @param ownerName The owner name to filter by
     * @return String The job ID
     */
    public static String scheduleDailyImport(String ownerName) {
        String jobName = 'Daily Job Import - ' + ownerName;
        String cronExp = '0 0 8 * * ?'; // 8:00 AM every day

        // Check if already scheduled
        List<CronTrigger> existingJobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
            LIMIT 1
        ];

        if (!existingJobs.isEmpty()) {
            // Abort existing job before rescheduling
            System.abortJob(existingJobs[0].Id);
        }

        return System.schedule(jobName, cronExp, new ScheduledJobSearch(ownerName));
    }

    /**
     * @description Schedule job import every 4 hours
     * @param ownerName The owner name to filter by
     * @return String The job ID
     */
    public static String scheduleEveryFourHours(String ownerName) {
        String jobName = 'Job Import Every 4h - ' + ownerName;
        String cronExp = '0 0 0/4 * * ?'; // Every 4 hours

        // Check if already scheduled
        List<CronTrigger> existingJobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
            LIMIT 1
        ];

        if (!existingJobs.isEmpty()) {
            System.abortJob(existingJobs[0].Id);
        }

        return System.schedule(jobName, cronExp, new ScheduledJobSearch(ownerName));
    }

    /**
     * @description Run import immediately (for testing or manual triggers)
     * @param ownerName The owner name
     */
    public static void runNow(String ownerName) {
        System.enqueueJob(new JobImportQueueable(ownerName, 6.0, false, true));
    }

    /**
     * @description Get all scheduled job import jobs
     * @return List<CronTrigger> The scheduled jobs
     */
    public static List<CronTrigger> getScheduledJobs() {
        return [
            SELECT Id, CronJobDetail.Name, CronExpression, NextFireTime, State
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE '%Job Import%'
            ORDER BY NextFireTime
        ];
    }

    /**
     * @description Cancel all scheduled job import jobs
     */
    public static void cancelAllScheduledJobs() {
        List<CronTrigger> jobs = getScheduledJobs();
        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
        System.debug(LoggingLevel.INFO, 'Cancelled ' + jobs.size() + ' scheduled job import jobs');
    }
}
