import { LightningElement } from 'lwc';

export default class SupportPanel extends LightningElement {
    tips = [
        'Take a 5-minute walk to reset your focus.',
        'Break large tasks into smaller steps.',
        'Celebrate small wins to stay motivated.'
    ];

    crisisResources = [
        {
            name: 'National Suicide Prevention Lifeline',
            phone: '988',
            url: 'https://988lifeline.org'
        },
        {
            name: 'Crisis Text Line',
            phone: 'Text HOME to 741741',
            url: 'https://crisistextline.org'
        }
    ];
}
