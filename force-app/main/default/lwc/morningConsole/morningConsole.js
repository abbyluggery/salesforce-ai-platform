import { LightningElement, api, track } from 'lwc';

export default class MorningConsole extends LightningElement {
    @api userId;
    @track jobs = [];
    @track loading = false;

    connectedCallback() {
        this.fetchJobs();
    }

    fetchJobs() {
        this.loading = true;
        // Simulated data for demo
        this.jobs = [
            {
                id: '1',
                title: 'Senior Frontend Developer',
                company: 'Cloudinary',
                location: 'Remote',
                url: 'https://example.com/job1'
            },
            {
                id: '2',
                title: 'UX Researcher',
                company: 'Codesignal',
                location: 'San Francisco, CA',
                url: 'https://example.com/job2'
            },
            {
                id: '3',
                title: 'Product Manager',
                company: '360Learning',
                location: 'New York, NY',
                url: 'https://example.com/job3'
            }
        ];
        this.loading = false;
    }

    handleSave(event) {
        const jobId = event.target.dataset.id;
        // Logic to save job
        console.log('Saved job:', jobId);
    }

    handleDismiss(event) {
        const jobId = event.target.dataset.id;
        // Logic to dismiss job
        console.log('Dismissed job:', jobId);
        this.jobs = this.jobs.filter(job => job.id !== jobId);
    }

    handleViewDetails(event) {
        const jobId = event.target.dataset.id;
        // Logic to view job details
        console.log('Viewing job:', jobId);
    }
}
