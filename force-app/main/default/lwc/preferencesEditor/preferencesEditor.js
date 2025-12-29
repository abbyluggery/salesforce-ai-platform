import { LightningElement, api } from 'lwc';

export default class PreferencesEditor extends LightningElement {
    @api userId;
    selectedLocation = '';
    selectedRoleTags = '';
    selectedWorkStyle = '';

    handleLocationChange(event) {
        this.selectedLocation = event.detail.value;
    }

    handleRoleTagsChange(event) {
        this.selectedRoleTags = event.detail.value;
    }

    handleWorkStyleChange(event) {
        this.selectedWorkStyle = event.detail.value;
    }

    handleSave() {
        // Logic to save preferences
        console.log('Saving preferences:', {
            location: this.selectedLocation,
            roleTags: this.selectedRoleTags,
            workStyle: this.selectedWorkStyle
        });
    }
}
