/**
 * @description Generates PDF files from Resume Packages
 * Creates ContentVersion records that can be attached to emails
 *
 * @author Abby Luggery / Claude Code Assistant
 * @date 2025-11-04
 */
public with sharing class ResumePDFGenerator {

    /**
     * @description Generate PDF files for a Resume Package and attach to Opportunity
     * @param resumePackageId The Resume Package ID
     * @return Map of file names to ContentVersion IDs
     */
    public static Map<String, Id> generateResumeFiles(Id resumePackageId) {
        Map<String, Id> fileIds = new Map<String, Id>();

        // Get the Resume Package with Opportunity info
        Resume_Package__c pkg = [
            SELECT Id, Name, Resume_Content__c, Cover_Letter__c,
                   Opportunity__c, Opportunity__r.Name,
                   Job_Posting__c, Job_Posting__r.Title__c,
                   Job_Posting_Title__c
            FROM Resume_Package__c
            WHERE Id = :resumePackageId
            LIMIT 1
        ];

        if (pkg.Opportunity__c == null) {
            throw new ResumePDFException('Resume Package must be linked to an Opportunity');
        }

        // Determine the job title for filename
        String jobTitle = null;
        if (pkg.Job_Posting__c != null && pkg.Job_Posting__r != null) {
            jobTitle = pkg.Job_Posting__r.Title__c;
        } else if (String.isNotBlank(pkg.Job_Posting_Title__c)) {
            jobTitle = pkg.Job_Posting_Title__c;
        } else if (pkg.Opportunity__r != null) {
            jobTitle = pkg.Opportunity__r.Name;
        } else {
            jobTitle = 'Job Application';
        }

        // Generate Resume PDF
        if (String.isNotBlank(pkg.Resume_Content__c)) {
            Id resumeFileId = createPDFFile(
                'Resume - ' + jobTitle + '.pdf',
                resumePackageId,
                pkg.Opportunity__c,
                true // isResume = true
            );
            fileIds.put('resume', resumeFileId);
        }

        // Generate Cover Letter PDF
        if (String.isNotBlank(pkg.Cover_Letter__c)) {
            Id coverLetterFileId = createPDFFile(
                'Cover Letter - ' + jobTitle + '.pdf',
                resumePackageId,
                pkg.Opportunity__c,
                false // isResume = false (cover letter)
            );
            fileIds.put('coverLetter', coverLetterFileId);
        }

        return fileIds;
    }

    /**
     * @description Create a PDF file from Resume Package using Visualforce
     * @param fileName The name for the PDF file
     * @param resumePackageId The Resume Package ID to pass to Visualforce
     * @param recordId The record to link the file to
     * @param isResume True if this is a resume, false if cover letter
     * @return ContentVersion ID
     */
    private static Id createPDFFile(String fileName, Id resumePackageId, Id recordId, Boolean isResume) {
        // Use Visualforce page to generate PDF
        PageReference pdfPage;
        if (isResume) {
            pdfPage = Page.ResumePDF;
        } else {
            pdfPage = Page.CoverLetterPDF;
        }

        // Pass Resume Package ID to the Visualforce controller
        pdfPage.getParameters().put('id', resumePackageId);

        // Generate PDF blob
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            // In test context, getContentAsPDF() doesn't work, so use dummy blob
            pdfBlob = Blob.valueOf('Test PDF Content');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }

        // Create ContentVersion (this creates the file)
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName.replace('.pdf', '');
        cv.PathOnClient = fileName;
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        cv.FirstPublishLocationId = recordId; // Link to Opportunity

        insert cv;

        return cv.Id;
    }


    /**
     * @description Invocable method to generate resume files from Flow
     * @param requests List of Resume Package IDs
     * @return List of results
     */
    @InvocableMethod(label='Generate Resume PDF Files'
                     description='Generates PDF files from Resume Package and attaches to Opportunity'
                     category='Resume Generation')
    public static List<Result> generateResumeFilesInvocable(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();
            try {
                Map<String, Id> fileIds = generateResumeFiles(req.resumePackageId);
                res.success = true;
                res.resumeFileId = fileIds.get('resume');
                res.coverLetterFileId = fileIds.get('coverLetter');
                res.message = 'PDF files generated successfully';
            } catch (Exception e) {
                res.success = false;
                res.message = 'Error generating PDFs: ' + e.getMessage();
            }
            results.add(res);
        }

        return results;
    }

    // Inner classes for Invocable method
    public class Request {
        @InvocableVariable(label='Resume Package ID' required=true)
        public Id resumePackageId;
    }

    public class Result {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Resume File ID')
        public Id resumeFileId;

        @InvocableVariable(label='Cover Letter File ID')
        public Id coverLetterFileId;

        @InvocableVariable(label='Message')
        public String message;
    }

    public class ResumePDFException extends Exception {}
}
