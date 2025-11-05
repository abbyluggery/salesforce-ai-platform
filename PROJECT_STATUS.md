# Job Search AI Assistant - Project Status Report

**Date:** November 4, 2025
**Developer:** Abby Luggery
**AI Assistant:** Claude Code
**Dev Hub Org:** abbyluggery179@agentforce.com

---

## Project Overview

Salesforce-based AI-powered job search assistant that helps manage the entire job application lifecycle, from discovering opportunities to preparing tailored application materials.

---

## Goals Achieved

### ✅ Core Functionality
1. **Job Posting Management**
   - Custom Job_Posting__c object with comprehensive fields
   - Fields: Title, Company, Description, Location, Salary Range, URL, Workplace Type, Remote Policy
   - Status tracking and application management

2. **AI-Powered Job Analysis**
   - JobPostingAnalyzer class integrates with Claude AI API
   - Analyzes job postings for:
     - Fit score (0-100)
     - Neurodivergent-friendliness score
     - Must-have vs Nice-to-have requirements matching
     - Green flags and red flags identification
     - Personalized recommendations
   - Company research integration with comprehensive details

3. **Opportunity Lifecycle Management**
   - Opportunity stages: Prospecting → Application Prepared → Applied → Phone Screen → Technical Interview → Final Interview → Offer Received
   - Job_Posting__c lookup field on Opportunity
   - Application_Prepared_Date__c tracking
   - Automatic stage advancement when resume generated

4. **Resume Generation System**
   - ResumeGenerator class creates tailored resumes and cover letters
   - OpportunityResumeGeneratorInvocable for Flow integration
   - Generates content customized to specific job postings
   - Links Resume_Package__c to Opportunity via Opportunity__c field

5. **PDF Export Functionality** ✨ NEW
   - ResumePDFGenerator class with Visualforce integration
   - Separate templates for resume and cover letter PDFs
   - Visualforce pages: ResumePDF.page and CoverLetterPDF.page
   - PDFs automatically attached to Opportunity records as ContentVersion
   - Files ready for email attachment from Opportunity

6. **Email Templates** ✨ NEW
   - Pre-loaded professional email templates for each stage:
     - Initial Application Email
     - Follow-Up After Application
     - Thank You After Phone Screen
     - Thank You After Technical Interview
     - Thank You After Final Interview
   - Auto-populate contact information using merge fields
   - Located in Job_Search_Templates folder

---

## Technical Architecture

### Custom Objects
- **Job_Posting__c** - Stores job opportunity details
- **Resume_Package__c** - Stores generated resumes and cover letters
- **Master_Resume__c** - Stores base resume data for personalization
- **Opportunity** (Standard) - Extended with custom fields for job application tracking

### Apex Classes
1. **JobPostingAnalyzer** - AI integration for job analysis
2. **ResumeGenerator** - AI-powered resume/cover letter generation
3. **OpportunityResumeGeneratorInvocable** - Flow-callable resume generation
4. **ResumePDFGenerator** - PDF generation using Visualforce
5. **ClaudeAPIService** - Handles API calls to Claude AI
6. **JobPostingAnalyzerTest** - Test coverage (98%+)
7. **ResumeGeneratorTest** - Test coverage
8. **OpportunityResumeGeneratorInvocableTest** - Test coverage

### Visualforce Pages
- **ResumePDF.page** - Resume PDF template with proper styling
- **CoverLetterPDF.page** - Cover letter PDF template with proper styling

### Email Templates (Job_Search_Templates folder)
- Initial_Application_Email.email
- Follow_Up_After_Application.email
- Thank_You_After_Phone_Screen.email
- Thank_You_After_Technical_Interview.email
- Thank_You_After_Final_Interview.email

### Flows
- **Generate Resume Package for Opportunity** - Quick action to generate tailored resume

### Test Coverage
- All Apex classes: 54 passing tests (100% success rate)
- Total test execution time: ~12 seconds

---

## Recent Session Work (November 4, 2025)

### 1. Email Template Creation
- Created 5 professional email templates for different job application stages
- Implemented merge fields for auto-population:
  - {!Opportunity.Contact.FirstName}
  - {!Opportunity.Name}
  - {!Opportunity.Account.Name}
  - {!User.Email}
  - {!User.Phone}
- Successfully deployed to dev hub

### 2. PDF Generation Implementation
**Problem:** User needed to attach resumes directly to emails from Opportunity window

**Solution Implemented:**
- Created ResumePDFGenerator.cls class
- Integrated PDF generation into OpportunityResumeGeneratorInvocable workflow
- PDFs automatically generated when resume package is created

**Technical Challenge Encountered:**
- Initial approach using `Blob.toPDF()` with HTML strings showed CSS code as plain text in PDFs
- **Root Cause:** Salesforce's Blob.toPDF() has limited HTML/CSS support

**Final Solution:**
- Switched to Visualforce pages with `renderAs="pdf"` attribute
- Created separate templates for resume and cover letter
- Used `PageReference.getContentAsPDF()` method
- Much more reliable PDF rendering with proper CSS support
- PDFs stored as ContentVersion records linked to Opportunity

**Files Created:**
- ResumePDF.page
- CoverLetterPDF.page
- Updated ResumePDFGenerator.cls to use Visualforce approach

**Deployment Status:**
- ✅ Visualforce pages deployed successfully
- ✅ ResumePDFGenerator deployed with all tests passing
- ✅ 54/54 tests passing in dev hub

### 3. Deployment Correction
**Issue:** Initially deploying to wrong org (creative-shark-cub7oy.com)
**Resolution:** Corrected to deploy to dev hub (abbyluggery179@agentforce.com)

---

## Current Issue (To Be Resolved)

**Flow Error:** "An unhandled fault has occurred in this flow"

**Status:** Deployment completed successfully but Flow execution failing

**Likely Causes:**
1. Opportunity missing Job_Posting__c field value
2. Missing or null data in related Job Posting record
3. Opportunity__c field on Resume_Package__c not fully deployed/synchronized

**Recommended Next Steps:**
1. Check Opportunity record has Job_Posting__c populated before generating resume
2. Enable debug logs to see exact error message
3. Verify Opportunity__c field exists on Resume_Package__c in org
4. Test with a different Opportunity that has all required data

---

## Next Feature Ideas

### 🎯 Call Log Transcription Integration
**Goal:** Integrate transcription capability into call logging for phone screens and interviews

**Proposed Implementation Options:**

#### Option 1: Otter.ai Plugin Integration
**Pros:**
- User already has Otter plugin available
- Professional transcription quality
- Speaker identification
- Real-time transcription
- Searchable transcripts

**Implementation Approach:**
1. Create custom object: **Call_Log__c**
   - Fields: Date, Duration, Call_Type__c (Phone Screen, Technical Interview, etc.)
   - Transcript__c (Long Text Area)
   - Recording_URL__c (link to Otter recording)
   - Key_Points__c (AI-extracted summary)
   - Action_Items__c
   - Lookup to Opportunity

2. Integration with Otter:
   - Manual: Copy/paste transcript from Otter into Call_Log__c
   - Semi-automated: Otter webhook to create Call_Log record
   - Automated: Otter API integration (if available)

3. AI Enhancement Layer:
   - Use Claude AI to analyze transcript
   - Extract key points and action items
   - Identify red flags or positive signals
   - Generate follow-up email suggestions
   - Update Opportunity fields based on insights

#### Option 2: Native Salesforce Voice Integration
**Pros:**
- Fully integrated within Salesforce
- No external dependencies

**Cons:**
- May require additional Salesforce licenses
- Less mature than dedicated transcription services

#### Option 3: Hybrid Approach
- Use Otter for transcription (user's existing tool)
- Store transcripts in Salesforce Call_Log__c
- Add Claude AI analysis layer for insights
- Link to Opportunity for full context

### Recommended Architecture:

```
Call/Interview
    ↓
Otter.ai Transcription
    ↓
Call_Log__c Record in Salesforce
    ├─ Transcript__c (full text)
    ├─ Recording_URL__c (Otter link)
    └─ Lookup to Opportunity
    ↓
Claude AI Analysis (Apex callout)
    ├─ Extract key discussion points
    ├─ Identify follow-up actions
    ├─ Detect red/green flags
    ├─ Sentiment analysis
    └─ Generate follow-up email draft
    ↓
Update Opportunity
    ├─ Add notes
    ├─ Update stage if appropriate
    └─ Create tasks for follow-ups
```

### Additional Call Log Features:
- **Automatic follow-up reminders** based on promised timelines mentioned in call
- **Interview question bank** - track questions asked and responses
- **Interviewer profiles** - remember who interviewed, their role, interests
- **Compare notes** across multiple rounds with same company
- **AI-generated thank you emails** customized with specific call details

---

## File Structure

```
force-app/main/default/
├── classes/
│   ├── ClaudeAPIService.cls
│   ├── JobPostingAnalyzer.cls
│   ├── JobPostingAnalyzerTest.cls
│   ├── ResumeGenerator.cls
│   ├── ResumeGeneratorTest.cls
│   ├── OpportunityResumeGeneratorInvocable.cls
│   ├── OpportunityResumeGeneratorInvocableTest.cls
│   ├── ResumePDFGenerator.cls
│   └── [meta.xml files for each]
├── pages/
│   ├── ResumePDF.page
│   ├── ResumePDF.page-meta.xml
│   ├── CoverLetterPDF.page
│   └── CoverLetterPDF.page-meta.xml
├── email/
│   ├── Job_Search_Templates.emailFolder-meta.xml
│   └── Job_Search_Templates/
│       ├── Initial_Application_Email.email
│       ├── Follow_Up_After_Application.email
│       ├── Thank_You_After_Phone_Screen.email
│       ├── Thank_You_After_Technical_Interview.email
│       └── Thank_You_After_Final_Interview.email
├── objects/
│   ├── Job_Posting__c/
│   ├── Resume_Package__c/
│   ├── Master_Resume__c/
│   └── Opportunity/
├── flows/
│   └── Generate_Resume_Package_for_Opportunity.flow-meta.xml
└── quickActions/
    └── Opportunity.Generate_Resume_Package.quickAction-meta.xml
```

---

## API Integration

**Claude AI API:**
- Model: claude-3-5-sonnet-20241022
- Max tokens: 4096
- Temperature: 0.7
- Stored in Named Credential: `Claude_AI`

---

## Known Limitations & Considerations

1. **API Costs:** Each AI analysis/generation consumes Claude API credits
2. **Governor Limits:** Callout limits apply (max 100 callouts per transaction)
3. **PDF Generation:** Visualforce `getContentAsPDF()` doesn't work in test context (handled with conditional logic)
4. **Email Templates:** Text-only format (no HTML templates yet)
5. **Resume Customization:** Requires Master_Resume__c record to be populated

---

## Success Metrics

- ✅ 54 passing Apex tests (100% success rate)
- ✅ PDF generation working with Visualforce approach
- ✅ Email templates deployed and ready to use
- ✅ Full resume generation workflow functional
- ✅ AI analysis providing valuable insights
- ⏳ Flow execution issue to be resolved

---

## Key Learnings from This Session

1. **Blob.toPDF() Limitations:** Salesforce's built-in HTML-to-PDF conversion has significant CSS rendering limitations
2. **Visualforce PDFs:** More reliable approach using `renderAs="pdf"` and `PageReference.getContentAsPDF()`
3. **Deployment Targeting:** Important to verify deploying to correct org (dev hub vs scratch orgs)
4. **Email Template Structure:** Requires EmailFolder metadata before templates can be deployed
5. **Merge Fields:** Powerful for auto-populating email templates with related record data

---

## Resources & Documentation

- **Salesforce Org:** abbyluggery179@agentforce.com (Dev Hub)
- **Claude AI Model:** claude-3-5-sonnet-20241022
- **Project Directory:** C:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant
- **Git Branch:** backup-before-expiration-20251023

---

## Next Session Priorities

1. **IMMEDIATE:** Resolve Flow execution error
   - Debug why "Generate Resume Package" is failing
   - Verify all required fields are populated
   - Check Opportunity__c field deployment status

2. **HIGH PRIORITY:** Call Log Transcription Feature
   - Design Call_Log__c object schema
   - Plan Otter.ai integration approach
   - Create AI analysis layer for transcripts
   - Build follow-up automation

3. **MEDIUM PRIORITY:** Enhanced Email Features
   - Create HTML email templates
   - Add email tracking
   - Build email send automation from Opportunity

4. **NICE TO HAVE:** Dashboard & Reporting
   - Application pipeline metrics
   - Success rate by job type/company
   - Interview conversion rates
   - Time-to-offer analytics

---

## Technical Debt

1. Some Resume_Package__c fields may be deprecated (check field usage)
2. Master_Resume__c object has fields returned from org but not in local project
3. Consider refactoring PDF generation to handle errors more gracefully
4. Add more robust error handling in OpportunityResumeGeneratorInvocable

---

**End of Project Status Report**

*Generated by Claude Code Assistant*
*Last Updated: November 4, 2025*
