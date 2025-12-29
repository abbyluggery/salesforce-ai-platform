# Journal Business Salesforce Extension - Build Plan

**Date**: November 29, 2025
**Integration**: Adding to existing DivergentThrive (Full-ND-app-build) org
**Status**: Phase 1A - Core Foundation (In Progress)

---

## PROJECT SUMMARY

Building a complete journal publishing business management system integrated with:
- **33 physical journals** published on Amazon KDP
- **Pinterest marketing automation** (auto-post pins, AI-generated content)
- **Etsy integration** (sync orders, manage listings)
- **Email nurture sequences** (welcome series, abandoned browse, re-engagement)
- **Cross-sell to DivergentThrive users** (recommend journals based on app usage)

---

## BUILD PHASES

### ✅ Phase 1A: Core Foundation (Week 1) - BUILDING NOW
- 6 custom objects
- Data loader for 33 journals
- Core service classes
- Dashboard & catalog LWCs
- KDP CSV importer
- Permission sets & app
- Test classes (75%+ coverage)

### Phase 1B: Pinterest Automation (Week 1-2) - Needs API credentials
- Pinterest OAuth integration
- AI content generator (uses existing ClaudeAPIService)
- Marketing content manager LWC
- Scheduled posting

### Phase 2: Etsy & Email (Week 2-3)
- Etsy API integration
- Order sync
- Email automation flows
- Lead magnet delivery

### Phase 3: Advanced Features (Week 3-4)
- Customer segmentation
- Advanced analytics
- Cross-sell recommendations
- Batch content generation

---

## CUSTOM OBJECTS (6 Objects)

### 1. Journal_Product__c
Tracks each of 33 journals in the catalog.

**Key Fields**:
- Name (Text 255) - Journal title
- Category__c (Picklist) - Moon & Lunar, Wellness & Mental Health, Spiritual & Witchy, LGBTQIA+ Journey, Practical & Home, Garden & Homestead, Fitness & Health
- Amazon_ASIN__c (Text 20, External ID, Unique)
- Amazon_Link__c (URL)
- Etsy_Link__c (URL)
- KDP_Status__c (Picklist) - Draft, Design In Progress, Ready for Upload, In Review, Published, Needs Update
- Price__c (Currency)
- Page_Count__c (Number)
- Trim_Size__c (Picklist) - 6x9, 8.5x11, 5x8, 5.5x8.5
- Target_Audience__c (Multi-select Picklist) - Beginners, Experienced, Neurodivergent, Chronic Illness, LGBTQIA+, Trans/Non-binary, Homeowners, Gardeners, Parents
- Launch_Date__c (Date)
- Total_Sales__c (Number) - Rollup summary from Journal_Sale__c
- Total_Revenue__c (Currency) - Rollup summary from Journal_Sale__c
- Average_Rating__c (Number 2.1)
- Review_Count__c (Number)
- Description__c (Long Text Area 32000)
- Keywords__c (Long Text Area 32000) - SEO keywords
- Related_NeuroThrive_Feature__c (Picklist) - Mood Tracking, Meal Planning, Daily Routines, Job Search, Gratitude Journal, None

### 2. Journal_Customer__c
Tracks customers and email subscribers across platforms.

**Key Fields**:
- Name (Text 255) - Customer name
- Email__c (Email, Required, Unique, External ID)
- Source__c (Picklist) - Pinterest, Instagram, Amazon Organic, Email Signup, DivergentThrive App, SafeHaven App, TikTok, Etsy, Referral, Other
- Lead_Magnet__c (Picklist) - 2026 Moon Calendar, Self Care Checklist, Foraging Starter Guide, Garden Planning Guide, None
- Customer_Type__c (Picklist) - Lead, One-Time Buyer, Repeat Buyer, VIP, Inactive
- Interests__c (Multi-select Picklist) - Moon/Lunar, Witchcraft/Pagan, Mental Health, Self Care, Gardening, Home Organization, LGBTQIA+ Content, Neurodivergent Support, Fitness, Homesteading
- Total_Purchases__c (Number, default 0)
- Total_Spend__c (Currency, default 0)
- Last_Purchase_Date__c (Date)
- Email_Opt_In__c (Checkbox, default false)
- Journey_Status__c (Picklist) - Not Started, Welcome Series, Nurture Sequence, Post Purchase, Re-engagement, Completed
- DivergentThrive_User__c (Checkbox) - Cross-reference to app users
- Last_Email_Open__c (DateTime)
- Last_Email_Click__c (DateTime)
- Unsubscribed__c (Checkbox, default false)
- Unsubscribed_Date__c (DateTime)

### 3. Journal_Sale__c
Tracks individual sales/orders from all platforms.

**Key Fields**:
- Name (Auto-number) - SALE-{0000}
- Journal_Product__c (Master-Detail to Journal_Product__c, Required)
- Journal_Customer__c (Lookup to Journal_Customer__c)
- Sale_Date__c (Date, Required)
- Quantity__c (Number, default 1)
- Sale_Price__c (Currency, Required)
- Total_Amount__c (Formula: Quantity__c * Sale_Price__c)
- Sale_Source__c (Picklist, Required) - Amazon KDP, Etsy, Direct, Bundle, Giveaway
- Amazon_Order_ID__c (Text 50)
- Etsy_Order_ID__c (Text 50)
- Notes__c (Long Text Area)

### 4. Marketing_Content__c
Stores generated marketing content for reuse across platforms.

**Key Fields**:
- Name (Text 255) - Content title/description
- Content_Type__c (Picklist) - Pinterest Pin, Instagram Post, Instagram Story, Email, Blog Post, Product Description, Ad Copy
- Platform__c (Picklist) - Pinterest, Instagram, Facebook, TikTok, Email, Amazon, Etsy, Website
- Journal_Product__c (Lookup to Journal_Product__c)
- Headline__c (Text 255)
- Body_Content__c (Long Text Area 32000)
- Hashtags__c (Long Text Area 32000)
- Call_To_Action__c (Text 255)
- Image_URL__c (URL)
- Pin_Link__c (URL) - Amazon or Etsy product link
- Scheduled_Date__c (DateTime)
- Posted__c (Checkbox, default false)
- Posted_Date__c (DateTime)
- Platform_Post_ID__c (Text 100) - Pinterest Pin ID, Instagram Post ID, etc.
- Engagement_Clicks__c (Number)
- Engagement_Likes__c (Number)
- Engagement_Saves__c (Number)
- Engagement_Impressions__c (Number)
- AI_Generated__c (Checkbox) - Was this AI-generated?
- Generation_Prompt__c (Long Text Area) - Prompt used for AI generation

### 5. Email_Journey__c
Tracks email automation journeys/sequences.

**Key Fields**:
- Name (Text 255) - Journey name
- Journey_Type__c (Picklist) - Welcome Series, Product Launch, Post Purchase, Re-engagement, Seasonal, Abandoned Browse, Lead Magnet Delivery
- Status__c (Picklist) - Draft, Active, Paused, Completed, Archived
- Description__c (Long Text Area)
- Trigger_Event__c (Text 255) - What starts the journey
- Total_Emails__c (Number) - How many emails in sequence
- Total_Enrolled__c (Number) - Rollup from Email_Send__c
- Total_Completed__c (Number)
- Open_Rate__c (Percent)
- Click_Rate__c (Percent)
- Conversion_Rate__c (Percent)
- Last_Modified_Date__c (DateTime)

### 6. Email_Send__c
Tracks individual email sends to customers.

**Key Fields**:
- Name (Auto-number) - EMAIL-{00000}
- Email_Journey__c (Lookup to Email_Journey__c)
- Journal_Customer__c (Lookup to Journal_Customer__c, Required)
- Email_Template__c (Text 255) - Template name/ID
- Subject_Line__c (Text 255)
- Sent_Date__c (DateTime)
- Opened__c (Checkbox, default false)
- Opened_Date__c (DateTime)
- Clicked__c (Checkbox, default false)
- Clicked_Date__c (DateTime)
- Bounced__c (Checkbox, default false)
- Unsubscribed__c (Checkbox, default false)
- Error_Message__c (Text 255)

---

## ADDITIONAL OBJECTS (Phase 1B+)

### API_Credential__c
Securely stores API tokens for integrations.

**Key Fields**:
- Name (Text 255) - Platform name
- Platform__c (Picklist) - Pinterest, Etsy, Printify, SendGrid, Mailchimp
- Access_Token__c (Text 255, Encrypted)
- Refresh_Token__c (Text 255, Encrypted)
- Token_Expiry__c (DateTime)
- Client_ID__c (Text 100)
- Client_Secret__c (Text 255, Encrypted)
- Is_Active__c (Checkbox)
- Last_Refreshed__c (DateTime)

### Social_Post_Analytics__c
Tracks performance metrics from social platforms.

**Key Fields**:
- Name (Auto-number) - ANALYTICS-{0000}
- Marketing_Content__c (Lookup to Marketing_Content__c, Required)
- Platform__c (Picklist) - Pinterest, Instagram, Facebook, TikTok
- Post_ID__c (Text 100) - Platform's unique post ID
- Impressions__c (Number)
- Clicks__c (Number)
- Saves__c (Number)
- Engagement_Rate__c (Percent, Formula)
- Last_Synced__c (DateTime)
- Sync_Status__c (Picklist) - Success, Failed, Pending

---

## APEX CLASSES

### Core Service Classes

#### JournalProductService.cls
Business logic for journal product operations.

**Methods**:
```apex
// Get all published journals
public static List<Journal_Product__c> getPublishedJournals()

// Get journals by category
public static List<Journal_Product__c> getJournalsByCategory(String category)

// Update sales metrics (called from triggers)
public static void updateSalesMetrics(Set<Id> journalIds)

// Get cross-sell recommendations based on purchase history
public static List<Journal_Product__c> getRelatedJournals(Id journalId)

// Get journals recommended for DivergentThrive users
public static List<Journal_Product__c> getJournalsForNeuroThriveFeature(String feature)
```

#### JournalCustomerService.cls
Business logic for customer management.

**Methods**:
```apex
// Upsert customer (handles duplicates by email)
public static Journal_Customer__c createOrUpdateCustomer(String email, String name, String source)

// Auto-classify customer type based on purchase behavior
public static void updateCustomerType(Id customerId)

// Get customer segments
public static List<Journal_Customer__c> getCustomersByInterest(List<String> interests)

// Find inactive customers (no purchase in X days)
public static List<Journal_Customer__c> getInactiveCustomers(Integer daysSinceLastActivity)

// Track email engagement
public static void trackEmailEngagement(Id customerId, String action, DateTime timestamp)

// Check for DivergentThrive user match (by email)
public static void checkDivergentThriveMatch(Set<Id> customerIds)
```

#### JournalAnalyticsService.cls
Analytics and reporting logic.

**Methods**:
```apex
// Get sales data for date range
public static Map<String, Object> getSalesByPeriod(Date startDate, Date endDate)

// Get top selling journals
public static List<Journal_Product__c> getTopSellingJournals(Integer limitCount)

// Get customer acquisition breakdown by source
public static Map<String, Integer> getCustomerAcquisitionBySource()

// Get email performance metrics
public static Map<String, Decimal> getEmailPerformanceMetrics()

// Get revenue by category
public static Map<String, Decimal> getRevenueByCategory()

// Get dashboard summary data
public static Map<String, Object> getDashboardSummary()
```

### Data Management Classes

#### JournalDataLoader.cls
Utility to load initial journal data and test data.

**Methods**:
```apex
// Load all 33 journals with complete data
public static void loadAllJournals()

// Load sample customers for testing
public static void loadSampleCustomers()

// Load marketing content templates
public static void loadMarketingTemplates()

// Delete all test data
public static void cleanupTestData()
```

#### KDPSalesImporter.cls
Import Amazon KDP sales from CSV reports.

**Methods**:
```apex
// Parse and import KDP sales report CSV
public static void importKDPSales(String csvContent)

// Process individual sale record
private static void processSaleRecord(Map<String, String> saleData)

// Match or create customer from order data
private static Journal_Customer__c matchOrCreateCustomer(String customerEmail, String customerName)
```

### Integration Classes (Phase 1B+)

#### PinterestService.cls
Pinterest API integration.

**Methods**:
```apex
// Create a pin on Pinterest
public static String createPin(Id marketingContentId)

// Get pin analytics
public static void syncPinAnalytics(Id marketingContentId)

// Schedule pin for posting
public static void schedulePin(Id marketingContentId, DateTime scheduleTime)

// Get OAuth access token
private static String getAccessToken()

// Refresh expired token
private static String refreshAccessToken()
```

#### EtsyService.cls (Phase 2)
Etsy API integration.

**Methods**:
```apex
// Sync Etsy orders to Salesforce
public static void syncEtsyOrders()

// Create Etsy listing from journal product
public static String createEtsyListing(Id journalProductId)

// Update listing
public static void updateEtsyListing(Id journalProductId)

// Get Etsy order details
public static void getEtsyOrderDetails(String etsyOrderId)
```

#### AIContentGenerator.cls
AI-powered content generation using existing ClaudeAPIService.

**Methods**:
```apex
// Generate Pinterest pin descriptions
public static List<Marketing_Content__c> generatePinterestPins(Id journalId, Integer count)

// Generate Instagram captions
public static Marketing_Content__c generateInstagramPost(Id journalId)

// Generate email content
public static String generateEmailContent(Id journalId, String emailType)

// Generate product descriptions for Amazon/Etsy
public static String generateProductDescription(Id journalId, String platform)

// Get hashtags for category
public static String getHashtagsByCategory(String category)
```

### Schedulable Classes

#### SocialMediaScheduler.cls
Daily scheduled job to post scheduled content.

**Schedule**: Daily at 9:00 AM EST

**Methods**:
```apex
public void execute(SchedulableContext sc)

// Find content scheduled for today
private static List<Marketing_Content__c> getTodaysScheduledContent()

// Post to Pinterest
private static void postToPinterest(Marketing_Content__c content)

// Send posting reminder if manual
private static void sendPostingReminder(Marketing_Content__c content)
```

#### EtsyOrderSyncScheduler.cls (Phase 2)
Daily sync of Etsy orders.

**Schedule**: Daily at 6:00 PM EST

**Methods**:
```apex
public void execute(SchedulableContext sc)

// Sync orders from last 7 days
private static void syncRecentOrders()
```

---

## LIGHTNING WEB COMPONENTS

### journalProductCatalog
Grid/list view of all journal products with filtering and sorting.

**Features**:
- Display all journals in responsive grid
- Filter by category, status, audience
- Sort by sales, revenue, launch date, name
- Quick edit inline (price, status, keywords)
- Link to Amazon/Etsy listings
- "Generate Marketing Content" button per journal

**Controller**: Uses JournalProductService

### journalDashboard
Main dashboard showing key business metrics.

**Widgets**:
- Total revenue (this month, all time)
- Revenue by category (pie chart)
- Top 5 selling journals (bar chart)
- Recent sales (data table)
- Email journey performance (metrics)
- Content calendar preview (upcoming posts)
- Quick actions (Generate Content, Import Sales, View Analytics)

**Controller**: Uses JournalAnalyticsService

### marketingContentManager (Phase 1B)
Create, edit, schedule, and track marketing content.

**Features**:
- Generate content with AI (one-click)
- Edit generated content
- Schedule posts
- Track engagement metrics
- Filter by platform, journal, status
- Bulk actions (schedule multiple pins)

**Controller**: Uses AIContentGenerator, PinterestService

### customerSegmentBuilder (Phase 3)
Build and manage customer segments.

**Features**:
- Filter customers by criteria (interests, purchase history, source, etc.)
- Preview segment results
- Save segments
- Enroll segment in email journey
- Export segment (CSV)

**Controller**: Uses JournalCustomerService

---

## FLOWS

### New_Customer_Welcome_Flow (Record-Triggered)
**Trigger**: Journal_Customer__c created with Email_Opt_In__c = true
**Actions**:
1. Set Journey_Status__c = 'Welcome Series'
2. Create Email_Send__c record for Welcome Email Day 1
3. Create scheduled Email_Send__c for Day 3
4. Create scheduled Email_Send__c for Day 7
5. If Lead_Magnet__c != 'None', send lead magnet delivery email

### Post_Purchase_Flow (Record-Triggered)
**Trigger**: Journal_Sale__c created
**Actions**:
1. Update Journal_Customer__c:
   - Total_Purchases__c += 1
   - Total_Spend__c += Total_Amount__c
   - Last_Purchase_Date__c = TODAY
2. Update Customer_Type__c:
   - If Total_Purchases__c = 1 → 'One-Time Buyer'
   - If Total_Purchases__c >= 2 → 'Repeat Buyer'
   - If Total_Spend__c >= $100 → 'VIP'
3. Set Journey_Status__c = 'Post Purchase'
4. Create Email_Send__c for Thank You email
5. Create Email_Send__c for Product Review request (7 days later)

### Customer_Reengagement_Flow (Scheduled)
**Schedule**: Daily at 8:00 AM
**Actions**:
1. Find customers where:
   - Last_Email_Open__c > 60 days ago OR Last_Purchase_Date__c > 90 days ago
   - Customer_Type__c != 'Inactive'
   - Unsubscribed__c = false
2. Set Journey_Status__c = 'Re-engagement'
3. Create Email_Send__c for "We Miss You" email
4. If no response in 14 days, set Customer_Type__c = 'Inactive'

### Content_Posting_Reminder_Flow (Scheduled)
**Schedule**: Daily at 7:00 AM
**Actions**:
1. Find Marketing_Content__c where:
   - Scheduled_Date__c = TODAY
   - Posted__c = false
2. Send email notification to admin
3. Create task for content posting

### Journal_Launch_Flow (Screen Flow)
**Purpose**: Wizard to launch a new journal product

**Screens**:
1. Enter journal details (name, category, price, page count, description)
2. Upload to Amazon/Etsy (links)
3. Generate marketing content (AI-powered)
   - 10 Pinterest pins
   - 5 Instagram posts
   - Email announcement
4. Schedule content (calendar view)
5. Create launch tasks (review checklist)
6. Confirmation screen

---

## PERMISSION SETS

### Journal_Business_Admin
**Object Permissions**: Full CRUD on all journal objects
**Field Permissions**: All fields (including API credentials)
**Apex Class Access**: All classes
**Flow Access**: All flows
**Tab Visibility**: All tabs
**App Access**: Journal Business app

### Journal_Business_User
**Object Permissions**:
- Journal_Product__c: Read
- Journal_Customer__c: Read, Create
- Journal_Sale__c: Read, Create
- Marketing_Content__c: Read
- Email_Journey__c: Read
- Email_Send__c: Read

**Field Permissions**: All except encrypted API credentials
**Tab Visibility**: All journal tabs
**App Access**: Journal Business app

---

## LIGHTNING APP

**Name**: Journal Business
**Icon**: Book icon
**Tabs**:
1. Home (journalDashboard component)
2. Journal Products
3. Customers
4. Sales
5. Marketing Content
6. Email Journeys
7. Reports

---

## INITIAL DATA - ALL 33 JOURNALS

### Moon & Lunar (4 journals)
1. Beginner's Moon Journal 2026 - $15.99, 250 pages, 6x9
2. Moon Ritual Journal 2026 - $16.99, 280 pages, 6x9
3. Manifestation by the Moons 2026 - $16.99, 260 pages, 6x9
4. Divination Journal 2026 - $17.99, 300 pages, 6x9

### Wellness & Mental Health (5 journals)
5. Mental Health & Mood Journal - $15.99, 220 pages, 6x9
6. Self Care Planner - $14.99, 200 pages, 6x9
7. 365 Daily Planner - $18.99, 380 pages, 6x9
8. Meal Planning Journal - $14.99, 180 pages, 6x9
9. Skin Care Journal - $13.99, 160 pages, 6x9

### Spiritual & Witchy (4 journals)
10. Spoonie Witch's Grimoire - $17.99, 280 pages, 6x9
11. Neurodivergent Witch's Grimoire - $17.99, 290 pages, 6x9
12. Sacred Cycles Menstrual Journal - $15.99, 200 pages, 6x9
13. Lilith Shadow Work Journey - $16.99, 240 pages, 6x9

### LGBTQIA+ Journey (3 journals)
14. Becoming Her (Trans Feminine) - $16.99, 260 pages, 6x9
15. Claiming Him (Trans Masculine) - $16.99, 260 pages, 6x9
16. Rainbow Magic Queer Grimoire - $17.99, 280 pages, 6x9

### Practical & Home (8 journals)
17. Household Chore Planner - $13.99, 160 pages, 6x9
18. Home Maintenance Log - $14.99, 180 pages, 6x9
19. Household Inventory Log - $13.99, 150 pages, 6x9
20. Emergency Planning Log - $14.99, 180 pages, 6x9
21. First Time Home Buying - $15.99, 200 pages, 6x9
22. Car Maintenance Log - $12.99, 140 pages, 6x9
23. Perimenopause Journal - $15.99, 220 pages, 6x9
24. Gym/Fitness Journal - $14.99, 180 pages, 6x9

### Garden & Homestead (5 journals)
25. Garden Planner - $15.99, 200 pages, 6x9
26. Garden Inventory Log - $13.99, 160 pages, 6x9
27. Gardening Journal - $14.99, 180 pages, 6x9
28. Crop Log Books - $14.99, 170 pages, 6x9
29. Foraging Journal - $16.99, 220 pages, 6x9

### Fitness & Health (4 journals)
30. Fitness Goal Tracker - $14.99, 200 pages, 6x9
31. Workout Log - $13.99, 180 pages, 6x9
32. Nutrition Journal - $15.99, 200 pages, 6x9
33. Wellness Habits Tracker - $14.99, 180 pages, 6x9

---

## DEPLOYMENT CHECKLIST

### Phase 1A - Core Foundation
- [ ] Deploy 6 custom objects with all fields
- [ ] Deploy Permission Sets
- [ ] Deploy JournalProductService + tests
- [ ] Deploy JournalCustomerService + tests
- [ ] Deploy JournalAnalyticsService + tests
- [ ] Deploy JournalDataLoader
- [ ] Deploy KDPSalesImporter + tests
- [ ] Deploy journalDashboard LWC
- [ ] Deploy journalProductCatalog LWC
- [ ] Deploy Lightning App and tabs
- [ ] Run JournalDataLoader.loadAllJournals()
- [ ] Verify all tests pass (75%+ coverage)
- [ ] Assign Journal_Business_Admin to admin user

### Phase 1B - Pinterest Integration
- [ ] Get Pinterest API credentials from user
- [ ] Create API_Credential__c custom metadata
- [ ] Deploy PinterestService + tests
- [ ] Deploy AIContentGenerator + tests
- [ ] Deploy SocialMediaScheduler + tests
- [ ] Deploy marketingContentManager LWC
- [ ] Schedule SocialMediaScheduler (daily 9 AM)
- [ ] Test pin creation
- [ ] Test AI content generation

### Phase 2 - Etsy & Email
- [ ] Get Etsy API credentials
- [ ] Deploy EtsyService + tests
- [ ] Deploy EtsyOrderSyncScheduler + tests
- [ ] Deploy 5 flows
- [ ] Activate flows
- [ ] Test order sync
- [ ] Test email automation

### Phase 3 - Advanced Features
- [ ] Deploy customerSegmentBuilder LWC
- [ ] Deploy advanced analytics
- [ ] Test cross-sell recommendations
- [ ] Test customer segmentation

---

## SUCCESS CRITERIA

After Phase 1A deployment:
- [ ] All 33 journals visible in Journal Products tab
- [ ] Can create customers and track sales manually
- [ ] Dashboard shows revenue, top sellers, recent sales
- [ ] Can import KDP sales via CSV
- [ ] Product catalog allows filtering and sorting
- [ ] All tests pass with 75%+ coverage

After Phase 1B deployment:
- [ ] Can generate Pinterest pin content with AI
- [ ] Can schedule pins for future posting
- [ ] Scheduled job auto-posts pins daily
- [ ] Pin analytics sync from Pinterest

After Phase 2 deployment:
- [ ] Etsy orders sync automatically
- [ ] New customer welcome email triggers
- [ ] Post-purchase emails send automatically
- [ ] Re-engagement campaign runs daily

---

**Next Steps**: Begin building custom objects and service classes immediately.

**Estimated Completion**: 2-3 weeks for full system
**Current Status**: Phase 1A Day 1 - Building objects now
