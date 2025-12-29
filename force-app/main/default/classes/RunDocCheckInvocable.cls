public with sharing class RunDocCheckInvocable {
    public class Request {
        @InvocableVariable(required=true) public Id subjectId; // Account or Contact
        @InvocableVariable(required=true) public String documentType; // Passport, ID Card, DriverLicense
        @InvocableVariable public String providerKey; // maps to ProviderCredential__mdt
        @InvocableVariable public String payloadJson; // optional extra data, e.g., doc capture token
    }
    public class Response {
        @InvocableVariable public Id verificationJobId;
        @InvocableVariable public Id verificationResultId;
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Run Document Check' description='Submits a document verification to the configured provider (POC stub).')
    public static List<Response> run(List<Request> requests) {
        List<Response> out = new List<Response>();
        for (Request req : requests) {
            Response r = new Response();
            try {
                VerificationJob__c job = new VerificationJob__c(
                    Type__c = 'Doc',
                    Provider__c = req.providerKey,
                    Status__c = 'Completed',
                    RequestPayload__c = req.payloadJson
                );
                if (req.subjectId != null) {
                    if (String.valueOf(req.subjectId).startsWith('001')) {
                        job.Account__c = req.subjectId;
                    } else if (String.valueOf(req.subjectId).startsWith('003')) {
                        job.Contact__c = req.subjectId;
                    }
                }
                insert job;

                VerificationResult__c vr = new VerificationResult__c(
                    VerificationJob__c = job.Id,
                    Account__c = job.Account__c,
                    Contact__c = job.Contact__c,
                    Passed__c = true,
                    PEP__c = false,
                    SanctionsHits__c = 0,
                    AdverseMediaHits__c = 0,
                    Confidence__c = 92,
                    Findings__c = '{"docType":"' + String.escapeSingleQuotes(req.documentType) + '","summary":"Document verified (POC stub)."}'
                );
                insert vr;

                RiskUpdated__e evt = new RiskUpdated__e(
                    SubjectId__c = req.subjectId,
                    NewScore__c = 12,
                    Band__c = 'Low',
                    ReasonCodes__c = 'DOC_OK'
                );
                EventBus.publish(evt);

                r.verificationJobId = job.Id;
                r.verificationResultId = vr.Id;
                r.success = true;
                r.message = 'Document check completed (POC stub).';
            } catch (Exception e) {
                r.success = false;
                r.message = e.getMessage();
            }
            out.add(r);
        }
        return out;
    }
}
