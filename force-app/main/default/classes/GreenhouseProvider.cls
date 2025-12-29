public with sharing class GreenhouseProvider {
    
    public static List<JobPosting__c> fetchJobs(String boardToken) {
        List<JobPosting__c> postings = new List<JobPosting__c>();
        
        // Get Named Credential endpoint
        String endpoint = 'https://boards-api.greenhouse.io/v1/boards/' + boardToken + '/jobs';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            List<Object> jobs = (List<Object>)response.get('jobs');
            
            for (Object jobObj : jobs) {
                Map<String, Object> jobData = (Map<String, Object>)jobObj;
                JobNormalizer.JobRecord jobRec = JobNormalizer.normalizeGreenhouseJob(jobData, boardToken);
                String externalId = jobRec.provider + ':' + jobRec.jobId;
                JobPosting__c posting = JobNormalizer.toJobPosting(jobRec, externalId);
                postings.add(posting);
            }
        }
        
        return postings;
    }
}
