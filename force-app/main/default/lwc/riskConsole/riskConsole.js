import { LightningElement, track, api } from 'lwc';
import runScreening from '@salesforce/apex/RunScreeningInvocable.run';
import aggregateRisk from '@salesforce/apex/AggregateRiskInvocable.aggregate';

export default class RiskConsole extends LightningElement {
    @api subjectId; // expose for template/parent usage
    @track subjectId = '';
    @track verificationType = 'IDV';
    @track providerKey = 'TEST_PROVIDER';
    @track lastMessage = '';
    @track riskAssessmentId = '';

    typeOptions = [
        { label: 'IDV', value: 'IDV' },
        { label: 'Sanctions', value: 'Sanctions' },
        { label: 'PEP', value: 'PEP' },
        { label: 'Adverse Media', value: 'Adverse Media' },
        { label: 'Document', value: 'Doc' },
        { label: 'KYB', value: 'KYB' }
    ];

    handleSubjectChange(event) {
        this.subjectId = event.target.value;
    }

    handleTypeChange(event) {
        this.verificationType = event.detail.value;
    }

    handleProviderChange(event) {
        this.providerKey = event.target.value;
    }

    async runScreening() {
        if (!this.subjectId) {
            this.lastMessage = 'Please enter a Subject Id';
            return;
        }

        try {
            const result = await runScreening({
                requests: [{
                    subjectId: this.subjectId,
                    type: this.verificationType,
                    providerKey: this.providerKey
                }]
            });
            const response = result[0];
            if (response.success) {
                this.lastMessage = `Screening completed: ${response.message}`;
                this.riskAssessmentId = response.verificationResultId; // for demo purposes
            } else {
                this.lastMessage = `Error: ${response.message}`;
            }
        } catch (error) {
            this.lastMessage = `Error: ${error.body.message}`;
        }
    }

    async aggregateRisk() {
        if (!this.subjectId) {
            this.lastMessage = 'Please enter a Subject Id';
            return;
        }

        try {
            const result = await aggregateRisk({
                requests: [{
                    subjectId: this.subjectId
                }]
            });
            const response = result[0];
            if (response.success) {
                this.lastMessage = `Aggregation completed: ${response.message}`;
                this.riskAssessmentId = response.riskAssessmentId;
            } else {
                this.lastMessage = `Error: ${response.message}`;
            }
        } catch (error) {
            this.lastMessage = `Error: ${error.body.message}`;
        }
    }
}
