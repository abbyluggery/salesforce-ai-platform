import { LightningElement, track } from 'lwc';

export default class EmailTemplateManager extends LightningElement {
    @track templates = [];
    @track columns = [
        { label: 'Template Name', fieldName: 'TemplateName__c', type: 'text' },
        { label: 'Subject Line', fieldName: 'SubjectLine__c', type: 'text' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Actions', type: 'action', typeAttributes: { rowActions: this.getRowActions } }
    ];

    connectedCallback() {
        // In a real implementation, this would fetch data from the backend
        this.templates = [
            {
                id: '1',
                TemplateName__c: 'Welcome Email',
                SubjectLine__c: 'Welcome to NDJobSearch!',
                CreatedDate: '2025-06-15'
            },
            {
                id: '2',
                TemplateName__c: 'Weekly Digest',
                SubjectLine__c: 'Your Weekly Job Digest',
                CreatedDate: '2025-07-20'
            }
        ];
    }

    getRowActions(row) {
        const actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Preview', name: 'preview' },
            { label: 'Duplicate', name: 'duplicate' }
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
            case 'preview':
                this.handlePreview(row);
                break;
            case 'duplicate':
                this.handleDuplicate(row);
                break;
            default:
        }
    }

    handleEdit(row) {
        // Logic to edit template
        console.log('Editing template:', row);
    }

    handlePreview(row) {
        // Logic to preview template
        console.log('Previewing template:', row);
    }

    handleDuplicate(row) {
        // Logic to duplicate template
        console.log('Duplicating template:', row);
    }

    handleCreateTemplate() {
        // Logic to create new template
        console.log('Creating new template');
    }
}
