import { LightningElement, api, track } from 'lwc';
import initForEmbed from '@salesforce/apex/TableauAuthController.initForEmbed';

// Note: This LWC is designed for Tableau Embedding API v3 using an authenticated token.
// It calls an Apex controller to retrieve a short-lived access token issued by your secure token proxy.
// You must configure CSP Trusted Sites to allow your Tableau Cloud domain.

export default class TableauEmbed extends LightningElement {
    @api recordId;
    @api tableauBaseUrl; // public property required by meta config
    @api vizPath;

    @track tableauBaseUrl = this.tableauBaseUrl || '';
    @track vizPath = this.vizPath || '';
    @track error;
    accessToken;
    expiresIn;

    // Holds the current viz instance created by the Embedding API
    vizInstance = null;

    connectedCallback() {
        // Default placeholders; can be overridden in App Builder inputs or via inline inputs.
        // Example: 'https://us-east-1a.online.tableau.com/t/yourSite'
        this.tableauBaseUrl = this.tableauBaseUrl || '';
        // Example: '/views/YourWorkbook/YourView'
        this.vizPath = this.vizPath || '';
    }

    handleBaseUrlChange = (event) => {
        this.tableauBaseUrl = event.target.value?.trim();
    };

    handleVizPathChange = (event) => {
        this.vizPath = event.target.value?.trim();
    };

    async initializeViz() {
        try {
            this.error = undefined;

            if (!this.tableauBaseUrl || !this.vizPath) {
                this.error = [{ message: 'Set Tableau Base URL and Viz Path, then click Load Viz.' }];
                return;
            }

            // Request short-lived token and bootstrap values from Apex
            const initResp = await initForEmbed({
                tableauBaseUrl: this.tableauBaseUrl,
                vizPath: this.vizPath,
                recordId: this.recordId || null,
                extraContext: {}
            });

            this.accessToken = initResp.accessToken;
            this.expiresIn = initResp.expiresIn;

            // Render viz using Embedding API v3
            this.renderViz();
        } catch (e) {
            this.error = this.normalizeError(e);
            // Cleanup any existing viz
            this.destroyViz();
        }
    }

    renderViz() {
        // Destroy any previous viz
        this.destroyViz();

        const container = this.template.querySelector('.viz-container');
        if (!container) {
            this.error = [{ message: 'Viz container not found.' }];
            return;
        }

        // Create the <tableau-viz> element (v3 embedding)
        const viz = document.createElement('tableau-viz');
        // Full URL: base + vizPath (vizPath starts with /views/...)
        viz.src = `${this.tableauBaseUrl}${this.vizPath}`;
        // Token from Apex
        viz.token = this.accessToken;

        // Optional width/height styles for responsive layout
        viz.style.width = '100%';
        viz.style.height = '700px';

        // Optional: pass filters/parameters later using API methods or attributes
        // viz.hideTabs = true; // if you want to hide tabs when supported

        // Listen to load/error events if desired
        viz.addEventListener('firstinteractive', () => {
            // Viz loaded
        });
        viz.addEventListener('vizerror', (evt) => {
            this.error = [{ message: 'Tableau viz error: ' + (evt?.detail?.message || 'Unknown') }];
        });

        container.appendChild(viz);
        this.vizInstance = viz;
    }

    refreshViz = () => {
        if (this.vizInstance && typeof this.vizInstance.refreshDataAsync === 'function') {
            // v3 API may differ; attempt refresh via API method if exposed
            this.vizInstance.refreshDataAsync().catch(() => {
                // fallback: re-render
                this.initializeViz();
            });
        } else {
            // If API method isn't present, re-init to refresh token and viz
            this.initializeViz();
        }
    };

    destroyViz() {
        if (this.vizInstance) {
            try {
                // Remove element from DOM; v3 handles cleanup
                this.vizInstance.remove();
            } catch (e) {
                // ignore
            }
            this.vizInstance = null;
        }
    }

    normalizeError(e) {
        const msg = e && e.body && e.body.message ? e.body.message : (e && e.message ? e.message : 'Unknown error');
        return [{ message: msg }];
    }
}
