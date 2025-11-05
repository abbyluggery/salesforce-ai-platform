/**
 * @description Controller for ResumePDF Visualforce page
 * Fetches resume content from Resume_Package__c record
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-04
 */
public with sharing class ResumePDFController {

    public String resumeContent { get; set; }

    public ResumePDFController() {
        // Get Resume Package ID from URL parameter
        String resumePackageId = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(resumePackageId)) {
            try {
                // Query the Resume Package record
                Resume_Package__c pkg = [
                    SELECT Id, Resume_Content__c
                    FROM Resume_Package__c
                    WHERE Id = :resumePackageId
                    LIMIT 1
                ];

                // Set the content, converting line breaks to HTML
                if (String.isNotBlank(pkg.Resume_Content__c)) {
                    resumeContent = pkg.Resume_Content__c.replaceAll('\n', '<br/>');
                } else {
                    resumeContent = 'No resume content available.';
                }

            } catch (Exception e) {
                resumeContent = 'Error loading resume: ' + e.getMessage();
            }
        } else {
            resumeContent = 'No Resume Package ID provided.';
        }
    }
}
