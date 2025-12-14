/**
 * @description Service class for importing jobs from the Python multi-API job search system.
 * Handles callouts to the Python Flask API and upserts jobs to Salesforce.
 *
 * The Python system aggregates jobs from 7 sources:
 * - Adzuna, RemoteOK, Jobicy, Arbeitnow, Himalayas, Jooble, Indeed RSS
 *
 * @author Claude Code Assistant
 * @date 2025-12-14
 */
public with sharing class JobSearchAPIService {

    // Named Credential for the Python Job Search API
    private static final String NAMED_CREDENTIAL = 'Job_Search_API';

    // Default threshold for importing jobs (quick_score >= this value)
    private static final Decimal DEFAULT_MIN_SCORE = 6.0;

    /**
     * @description Wrapper class for job data from Python API
     */
    public class PythonJob {
        public String job_hash;
        public String title;
        public String company;
        public String location;
        public Integer salary_min;
        public Integer salary_max;
        public String salary_text;
        public String url;
        public String description;
        public String source;
        public Decimal quick_score;
        public Decimal fit_score;
        public String fit_analysis;
        public String status;
        public String created_at;
    }

    /**
     * @description Import result wrapper
     */
    public class ImportResult {
        public Integer totalFetched;
        public Integer newJobs;
        public Integer updatedJobs;
        public Integer errors;
        public List<String> errorMessages;
        public DateTime importTime;

        public ImportResult() {
            this.totalFetched = 0;
            this.newJobs = 0;
            this.updatedJobs = 0;
            this.errors = 0;
            this.errorMessages = new List<String>();
            this.importTime = DateTime.now();
        }
    }

    /**
     * @description Fetch and import jobs from Python API
     * Uses the default minimum score threshold
     *
     * @param ownerName The job searcher name (e.g., "Abby" or "Matt")
     * @return ImportResult Summary of the import operation
     */
    public static ImportResult importJobs(String ownerName) {
        return importJobs(ownerName, DEFAULT_MIN_SCORE);
    }

    /**
     * @description Fetch and import jobs from Python API with custom score threshold
     *
     * @param ownerName The job searcher name (e.g., "Abby" or "Matt")
     * @param minScore Minimum quick_score to import (0-10)
     * @return ImportResult Summary of the import operation
     */
    public static ImportResult importJobs(String ownerName, Decimal minScore) {
        ImportResult result = new ImportResult();

        try {
            // Fetch jobs from Python API
            List<PythonJob> pythonJobs = fetchJobsFromAPI(minScore);
            result.totalFetched = pythonJobs.size();

            if (pythonJobs.isEmpty()) {
                return result;
            }

            // Convert to Salesforce records
            List<Job_Posting__c> jobsToUpsert = new List<Job_Posting__c>();

            for (PythonJob pJob : pythonJobs) {
                try {
                    Job_Posting__c sfJob = convertToSalesforceJob(pJob, ownerName);
                    jobsToUpsert.add(sfJob);
                } catch (Exception e) {
                    result.errors++;
                    result.errorMessages.add('Error converting job: ' + pJob.title + ' - ' + e.getMessage());
                }
            }

            // Upsert using ExternalID__c for deduplication
            if (!jobsToUpsert.isEmpty()) {
                Schema.SObjectField externalIdField = Job_Posting__c.ExternalID__c;
                Database.UpsertResult[] upsertResults = Database.upsert(jobsToUpsert, externalIdField, false);

                for (Integer i = 0; i < upsertResults.size(); i++) {
                    Database.UpsertResult ur = upsertResults[i];
                    if (ur.isSuccess()) {
                        if (ur.isCreated()) {
                            result.newJobs++;
                        } else {
                            result.updatedJobs++;
                        }
                    } else {
                        result.errors++;
                        for (Database.Error err : ur.getErrors()) {
                            result.errorMessages.add('Upsert error for ' + jobsToUpsert[i].Title__c + ': ' + err.getMessage());
                        }
                    }
                }
            }

            System.debug(LoggingLevel.INFO, 'Job Import Complete - New: ' + result.newJobs + ', Updated: ' + result.updatedJobs);

        } catch (Exception e) {
            result.errors++;
            result.errorMessages.add('Import failed: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'JobSearchAPIService Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }

        return result;
    }

    /**
     * @description Fetch jobs from the Python Flask API
     *
     * @param minScore Minimum quick_score to fetch
     * @return List<PythonJob> Jobs from the API
     */
    @TestVisible
    private static List<PythonJob> fetchJobsFromAPI(Decimal minScore) {
        List<PythonJob> jobs = new List<PythonJob>();

        // Build the endpoint URL with query parameters
        String endpoint = 'callout:' + NAMED_CREDENTIAL + '/api/jobs?min_score=' + minScore + '&limit=200';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(60000); // 60 second timeout
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            jobs = (List<PythonJob>) JSON.deserialize(responseBody, List<PythonJob>.class);
            System.debug(LoggingLevel.INFO, 'Fetched ' + jobs.size() + ' jobs from Python API');
        } else {
            throw new JobSearchAPIException('API Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }

        return jobs;
    }

    /**
     * @description Convert a Python job to a Salesforce Job_Posting__c record
     *
     * @param pJob The Python job data
     * @param ownerName The job searcher name
     * @return Job_Posting__c The Salesforce record
     */
    @TestVisible
    private static Job_Posting__c convertToSalesforceJob(PythonJob pJob, String ownerName) {
        Job_Posting__c sfJob = new Job_Posting__c();

        // External ID for upsert deduplication
        sfJob.ExternalID__c = pJob.job_hash;

        // Core fields
        sfJob.Title__c = truncateField(pJob.title, 255);
        sfJob.Company__c = truncateField(pJob.company, 255);
        sfJob.Location__c = truncateField(pJob.location, 255);
        sfJob.Description__c = pJob.description; // Long text area
        sfJob.Apply_URL__c = truncateField(pJob.url, 255);

        // Provider mapping - normalize source names
        sfJob.Provider__c = mapSourceToProvider(pJob.source);

        // Salary
        if (pJob.salary_min != null && pJob.salary_min > 0) {
            sfJob.Salary_Min__c = pJob.salary_min;
        }
        if (pJob.salary_max != null && pJob.salary_max > 0) {
            sfJob.Salary_Max__c = pJob.salary_max;
        }

        // Scores
        sfJob.Quick_Score__c = pJob.quick_score;

        // If Python already ran AI analysis, import it
        if (pJob.fit_score != null) {
            sfJob.Fit_Score__c = pJob.fit_score;
        }

        // Multi-user support
        sfJob.Owner_Name__c = ownerName;

        // Sync timestamp
        sfJob.LastSynced__c = DateTime.now();

        // Default status
        sfJob.Status__c = 'Active';

        // Determine workplace type from location/description
        sfJob.Workplace_Type__c = determineWorkplaceType(pJob);

        return sfJob;
    }

    /**
     * @description Map Python source names to Salesforce Provider picklist values
     */
    @TestVisible
    private static String mapSourceToProvider(String source) {
        if (String.isBlank(source)) {
            return 'Indeed'; // Default
        }

        String sourceLower = source.toLowerCase();

        // Direct matches
        if (sourceLower.contains('adzuna')) return 'Adzuna';
        if (sourceLower.contains('remoteok') || sourceLower.contains('remote_ok')) return 'RemoteOK';
        if (sourceLower.contains('jobicy')) return 'Jobicy';
        if (sourceLower.contains('arbeitnow')) return 'Arbeitnow';
        if (sourceLower.contains('himalayas')) return 'Himalayas';
        if (sourceLower.contains('jooble')) return 'Jooble';
        if (sourceLower.contains('indeed')) return 'Indeed';
        if (sourceLower.contains('linkedin')) return 'LinkedIn';
        if (sourceLower.contains('dice')) return 'Dice';
        if (sourceLower.contains('glassdoor')) return 'Glassdoor';
        if (sourceLower.contains('greenhouse')) return 'Greenhouse';
        if (sourceLower.contains('lever')) return 'Lever';
        if (sourceLower.contains('flexjobs')) return 'FlexJobs';
        if (sourceLower.contains('ladders')) return 'Ladders';

        // Default to Indeed for RSS feeds
        return 'Indeed';
    }

    /**
     * @description Determine workplace type from job data
     */
    @TestVisible
    private static String determineWorkplaceType(PythonJob pJob) {
        String combined = '';
        if (pJob.title != null) combined += pJob.title.toLowerCase() + ' ';
        if (pJob.location != null) combined += pJob.location.toLowerCase() + ' ';
        if (pJob.description != null) combined += pJob.description.toLowerCase().left(500);

        if (combined.contains('remote') || combined.contains('work from home') || combined.contains('wfh')) {
            return 'Remote';
        } else if (combined.contains('hybrid')) {
            return 'Hybrid';
        } else if (combined.contains('on-site') || combined.contains('onsite') || combined.contains('in office')) {
            return 'On-Site';
        }

        return 'Remote'; // Default for remote job search
    }

    /**
     * @description Truncate field to max length
     */
    private static String truncateField(String value, Integer maxLength) {
        if (String.isBlank(value)) {
            return value;
        }
        return value.length() > maxLength ? value.left(maxLength) : value;
    }

    /**
     * @description Trigger a search on the Python API (optional - Python has its own scheduler)
     * This can be called to force an immediate search before importing
     *
     * @return Boolean True if search was triggered successfully
     */
    public static Boolean triggerPythonSearch() {
        try {
            String endpoint = 'callout:' + NAMED_CREDENTIAL + '/api/search';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(30000);
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            return res.getStatusCode() == 200;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to trigger Python search: ' + e.getMessage());
            return false;
        }
    }

    /**
     * @description Queue AI analysis for newly imported jobs that haven't been analyzed yet
     *
     * @param ownerName Filter by owner (optional)
     */
    public static void queueAnalysisForNewJobs(String ownerName) {
        String query = 'SELECT Id FROM Job_Posting__c WHERE Fit_Score__c = null AND Status__c = \'Active\'';

        if (String.isNotBlank(ownerName)) {
            query += ' AND Owner_Name__c = :ownerName';
        }

        query += ' LIMIT 50'; // Process in batches

        List<Job_Posting__c> jobsToAnalyze = Database.query(query);

        if (!jobsToAnalyze.isEmpty()) {
            // Queue each job for async AI analysis
            for (Job_Posting__c job : jobsToAnalyze) {
                System.enqueueJob(new JobPostingAnalysisQueue(job.Id));
            }
            System.debug(LoggingLevel.INFO, 'Queued ' + jobsToAnalyze.size() + ' jobs for AI analysis');
        }
    }

    /**
     * @description Custom exception for API errors
     */
    public class JobSearchAPIException extends Exception {}
}
