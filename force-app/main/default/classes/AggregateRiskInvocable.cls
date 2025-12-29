public with sharing class AggregateRiskInvocable {
    public class Request {
        @InvocableVariable(required=true)
        public Id subjectId; // Account or Contact
    }
    public class Response {
        @InvocableVariable public Id riskAssessmentId;
        @InvocableVariable public Integer score;
        @InvocableVariable public String band;
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Aggregate Risk' description='Aggregates VerificationResult__c records into a unified RiskAssessment__c (POC stub).')
    public static List<Response> aggregate(List<Request> requests) {
        List<Response> out = new List<Response>();
        for (Request req : requests) {
            Response r = new Response();
            try {
                Integer score = 10; // POC logic; later replace with weighted model
                String band = 'Low';

                RiskAssessment__c ra = new RiskAssessment__c(
                    Score__c = score,
                    Band__c = band,
                    Jurisdiction__c = 'GLOBAL',
                    ProviderBreakdown__c = '{"agg":"stub"}',
                    NextAction__c = 'No Action'
                );
                if (req.subjectId != null) {
                    if (String.valueOf(req.subjectId).startsWith('001')) {
                        ra.Account__c = req.subjectId;
                    } else if (String.valueOf(req.subjectId).startsWith('003')) {
                        ra.Contact__c = req.subjectId;
                    }
                }
                insert ra;

                // Publish event
                RiskUpdated__e evt = new RiskUpdated__e(
                    SubjectId__c = req.subjectId,
                    NewScore__c = score,
                    Band__c = band,
                    ReasonCodes__c = 'AGG_POC'
                );
                EventBus.publish(evt);

                r.riskAssessmentId = ra.Id;
                r.score = score;
                r.band = band;
                r.success = true;
                r.message = 'Aggregated risk created.';
            } catch (Exception e) {
                r.success = false;
                r.message = e.getMessage();
            }
            out.add(r);
        }
        return out;
    }
}
