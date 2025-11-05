/**
 * @description Controller for CoverLetterPDF Visualforce page
 * Fetches cover letter content from Resume_Package__c record
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-04
 */
public with sharing class CoverLetterPDFController {

    public String coverLetterContent { get; set; }

    public CoverLetterPDFController() {
        // Get Resume Package ID from URL parameter
        String resumePackageId = ApexPages.currentPage().getParameters().get('id');

        if (String.isNotBlank(resumePackageId)) {
            try {
                // Query the Resume Package record
                Resume_Package__c pkg = [
                    SELECT Id, Cover_Letter__c
                    FROM Resume_Package__c
                    WHERE Id = :resumePackageId
                    LIMIT 1
                ];

                // Set the content, converting line breaks to HTML
                if (String.isNotBlank(pkg.Cover_Letter__c)) {
                    coverLetterContent = pkg.Cover_Letter__c.replaceAll('\n', '<br/>');
                } else {
                    coverLetterContent = 'No cover letter content available.';
                }

            } catch (Exception e) {
                coverLetterContent = 'Error loading cover letter: ' + e.getMessage();
            }
        } else {
            coverLetterContent = 'No Resume Package ID provided.';
        }
    }
}
