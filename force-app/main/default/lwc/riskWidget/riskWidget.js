import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Fields on RiskAssessment__c
const FIELDS = [
    'RiskAssessment__c.Score__c',
    'RiskAssessment__c.Band__c',
    'RiskAssessment__c.Jurisdiction__c',
    'RiskAssessment__c.NextAction__c'
];

export default class RiskWidget extends LightningElement {
    // Option A: pass a RiskAssessment Id directly
    @api riskAssessmentId;
    // Option B: pass a subject (Account or Contact) Id and we could extend to query latest via Apex later
    @api subjectId;

    risk;
    error;

    // For the POC, when riskAssessmentId is provided, load the record via UI API
    @wire(getRecord, { recordId: '$riskAssessmentId', fields: FIELDS })
    wiredRisk({ data, error }) {
        if (data) {
            this.risk = {
                score: getFieldValue(data, FIELDS[0]),
                band: getFieldValue(data, FIELDS[1]),
                jurisdiction: getFieldValue(data, FIELDS[2]),
                nextAction: getFieldValue(data, FIELDS[3])
            };
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.risk = undefined;
        }
    }
}
