public with sharing class RunScreeningInvocable {
    public class Request {
        @InvocableVariable(required=true)
        public Id subjectId; // Account or Contact

        @InvocableVariable(required=true)
        public String type; // IDV, Sanctions, PEP, Adverse Media, Doc, KYB

        @InvocableVariable
        public String providerKey; // maps to ProviderCredential__mdt record name

        @InvocableVariable
        public String payloadJson; // optional request details
    }
    public class Response {
        @InvocableVariable public Id verificationJobId;
        @InvocableVariable public Id verificationResultId;
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Run Screening' description='Execute a screening via orchestration/policy - stub for POC')
    public static List<Response> run(List<Request> requests) {
        List<Response> out = new List<Response>();
        for (Request req : requests) {
            Response r = new Response();
            try {
                // Create a VerificationJob__c stub
                VerificationJob__c job = new VerificationJob__c(
                    Type__c = req.type,
                    Provider__c = req.providerKey,
                    Status__c = 'Completed',
                    RequestPayload__c = req.payloadJson
                );
                // naive subject link
                if (req.subjectId != null) {
                    if (String.valueOf(req.subjectId).startsWith('001')) {
                        job.Account__c = req.subjectId;
                    } else if (String.valueOf(req.subjectId).startsWith('003')) {
                        job.Contact__c = req.subjectId;
                    }
                }
                insert job;

                // Create a sample VerificationResult__c
                VerificationResult__c vr = new VerificationResult__c(
                    VerificationJob__c = job.Id,
                    Account__c = job.Account__c,
                    Contact__c = job.Contact__c,
                    Passed__c = true,
                    PEP__c = false,
                    SanctionsHits__c = 0,
                    AdverseMediaHits__c = 0,
                    Confidence__c = 95,
                    Findings__c = '{"summary":"POC stub - no real provider call executed."}'
                );
                insert vr;

                // Upsert a RiskAssessment__c (simplified): create new with score 10 Low
                RiskAssessment__c ra = new RiskAssessment__c(
                    Account__c = job.Account__c,
                    Contact__c = job.Contact__c,
                    Score__c = 10,
                    Band__c = 'Low',
                    Jurisdiction__c = 'GLOBAL',
                    ProviderBreakdown__c = '{"example":"normalized"}',
                    NextAction__c = 'No Action'
                );
                insert ra;

                // Publish Platform Event: RiskUpdated__e
                RiskUpdated__e evt = new RiskUpdated__e(
                    SubjectId__c = req.subjectId,
                    NewScore__c = 10,
                    Band__c = 'Low',
                    ReasonCodes__c = 'POC_STUB'
                );
                Database.SaveResult sr = EventBus.publish(evt);

                r.verificationJobId = job.Id;
                r.verificationResultId = vr.Id;
                r.success = true;
                r.message = 'Screening executed (POC stub). Event published: ' + sr.isSuccess();
            } catch (Exception e) {
                r.success = false;
                r.message = e.getMessage();
            }
            out.add(r);
        }
        return out;
    }
}
