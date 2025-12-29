public with sharing class LeverProvider {
    
    public static List<JobPosting__c> fetchJobs(String site) {
        List<JobPosting__c> postings = new List<JobPosting__c>();
        
        // Get Named Credential endpoint
        String endpoint = 'https://api.lever.co/v0/postings/' + site + '?mode=json';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            List<Object> jobs = (List<Object>)JSON.deserializeUntyped(res.getBody());
            
            for (Object jobObj : jobs) {
                Map<String, Object> jobData = (Map<String, Object>)jobObj;
                JobNormalizer.JobRecord jobRec = JobNormalizer.normalizeLeverJob(jobData, site);
                String externalId = jobRec.provider + ':' + jobRec.jobId;
                JobPosting__c posting = JobNormalizer.toJobPosting(jobRec, externalId);
                postings.add(posting);
            }
        }
        
        return postings;
    }
}
