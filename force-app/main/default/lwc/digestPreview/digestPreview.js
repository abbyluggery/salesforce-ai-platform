import { LightningElement } from 'lwc';

export default class DigestPreview extends LightningElement {
    digestContent = `
        <h2>Your Morning Digest</h2>
        <p>Here are the top 3 jobs matched to your preferences:</p>
        <ul>
            <li><strong>Senior Frontend Developer</strong> at Cloudinary - Remote</li>
            <li><strong>UX Researcher</strong> at Codesignal - San Francisco, CA</li>
            <li><strong>Product Manager</strong> at 360Learning - New York, NY</li>
        </ul>
        <p>Keep exploring or save these for later!</p>
    `;
}
