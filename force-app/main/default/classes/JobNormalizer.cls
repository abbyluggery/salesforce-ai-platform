public with sharing class JobNormalizer {
    
    public class JobRecord {
        public String title;
        public String company;
        public String location;
        public String description;
        public String url;
        public String applyUrl;
        public String provider;
        public String jobId;
        public String workplaceType;
        public List<String> tags;
        public Decimal salaryMin;
        public Decimal salaryMax;
        public String currency;
        public String interval;
    }
    
    public static JobRecord normalizeGreenhouseJob(Map<String, Object> jobData, String boardToken) {
        JobRecord job = new JobRecord();
        job.provider = 'Greenhouse';
        job.jobId = (String)jobData.get('id');
        job.title = (String)jobData.get('title');
        job.company = (String)jobData.get('company');
        job.location = (String)jobData.get('location');
        job.url = (String)jobData.get('absolute_url');
        job.applyUrl = (String)jobData.get('absolute_apply_url');
        
        // Normalize workplace type
        if (jobData.containsKey('employment_type')) {
            String empType = (String)jobData.get('employment_type');
            if (empType != null) {
                if (empType.contains('Remote')) job.workplaceType = 'Remote';
                else if (empType.contains('Hybrid')) job.workplaceType = 'Hybrid';
                else job.workplaceType = 'On-site';
            }
        }
        
        // Tags
        job.tags = new List<String>();
        if (jobData.containsKey('departments')) {
            List<Object> departments = (List<Object>)jobData.get('departments');
            for (Object dept : departments) {
                job.tags.add((String)dept);
            }
        }
        
        // ExternalId
        job.jobId = job.provider + ':' + job.jobId;
        
        return job;
    }
    
    public static JobRecord normalizeLeverJob(Map<String, Object> jobData, String site) {
        JobRecord job = new JobRecord();
        job.provider = 'Lever';
        job.jobId = (String)jobData.get('id');
        job.title = (String)jobData.get('text');
        job.company = site; // Lever uses site as company identifier
        job.location = (String)((Map<String, Object>)jobData.get('categories')).get('location');
        job.description = (String)jobData.get('descriptionPlain');
        job.url = (String)jobData.get('hostedUrl');
        job.applyUrl = (String)jobData.get('applyUrl');
        
        // Workplace Type
        String wpType = (String)((Map<String, Object>)jobData.get('categories')).get('workplaceType');
        if (wpType != null) {
            if (wpType == 'remote') job.workplaceType = 'Remote';
            else if (wpType == 'hybrid') job.workplaceType = 'Hybrid';
            else job.workplaceType = 'On-site';
        }
        
        // Tags
        job.tags = new List<String>();
        if (jobData.containsKey('categories')) {
            Map<String, Object> categories = (Map<String, Object>)jobData.get('categories');
            if (categories.containsKey('commitment')) {
                job.tags.add((String)categories.get('commitment'));
            }
            if (categories.containsKey('team')) {
                job.tags.add((String)categories.get('team'));
            }
            if (categories.containsKey('department')) {
                job.tags.add((String)categories.get('department'));
            }
        }
        
        // Salary
        if (jobData.containsKey('salaryRange')) {
            Map<String, Object> salary = (Map<String, Object>)jobData.get('salaryRange');
            job.salaryMin = (Decimal)salary.get('min');
            job.salaryMax = (Decimal)salary.get('max');
            job.currency = (String)salary.get('currency');
            job.interval = (String)salary.get('interval');
        }
        
        // ExternalId
        job.jobId = job.provider + ':' + job.jobId;
        
        return job;
    }
    
    public static JobPosting__c toJobPosting(JobRecord job, String externalId) {
        JobPosting__c posting = new JobPosting__c(
            Title__c = job.title,
            Company__c = job.company,
            Location__c = job.location,
            Description__c = job.description,
            Url__c = job.url,
            ApplyUrl__c = job.applyUrl,
            Provider__c = job.provider,
            ExternalId__c = externalId,
            WorkplaceType__c = job.workplaceType,
            Tags__c = String.join(job.tags, ';')
        );
        
        if (job.salaryMin != null) posting.SalaryMin__c = job.salaryMin;
        if (job.salaryMax != null) posting.SalaryMax__c = job.salaryMax;
        if (job.currency != null) posting.Currency__c = job.currency;
        if (job.interval != null) posting.Interval__c = job.interval;
        
        return posting;
    }
}
