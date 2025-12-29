import { LightningElement, track } from 'lwc';

export default class MarketingCampaignDashboard extends LightningElement {
    @track campaigns = [];
    @track columns = [
        { label: 'Campaign Name', fieldName: 'CampaignName__c', type: 'text' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Actions', type: 'action', typeAttributes: { rowActions: this.getRowActions } }
    ];

    connectedCallback() {
        // In a real implementation, this would fetch data from the backend
        this.campaigns = [
            {
                id: '1',
                CampaignName__c: 'Summer Internship Campaign',
                CreatedDate: '2025-06-15',
                Status__c: 'Active'
            },
            {
                id: '2',
                CampaignName__c: 'New Grad Hiring',
                CreatedDate: '2025-07-20',
                Status__c: 'Draft'
            }
        ];
    }

    getRowActions(row) {
        const actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'View Details', name: 'view' },
            { label: 'Send Test Email', name: 'send_test' }
        ];
        return actions;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.handleEdit(row);
                break;
            case 'view':
                this.handleView(row);
                break;
            case 'send_test':
                this.handleSendTest(row);
                break;
            default:
        }
    }

    handleEdit(row) {
        // Logic to edit campaign
        console.log('Editing campaign:', row);
    }

    handleView(row) {
        // Logic to view campaign details
        console.log('Viewing campaign:', row);
    }

    handleSendTest(row) {
        // Logic to send test email
        console.log('Sending test email for campaign:', row);
    }

    handleCreateCampaign() {
        // Logic to create new campaign
        console.log('Creating new campaign');
    }
}
