# Journal Business - Quick Start Guide

## Immediate Next Steps (Do This First!)

### 1. Deploy to Salesforce ⚡
```bash
# Navigate to project directory
cd "D:\Cloned GitHub\Full-ND-app-build"

# Deploy custom objects
sfdx force:source:deploy -p force-app/main/default/objects -u YourOrgAlias

# Deploy JournalDataLoader
sfdx force:source:deploy -p force-app/main/default/classes/JournalDataLoader.cls -u YourOrgAlias
```

### 2. Load 33 Base Journals 📚
```apex
// Open Developer Console → Debug → Execute Anonymous Window
// Paste and execute:
JournalDataLoader.loadAllJournals();

// Verify:
List<Journal_Product__c> journals = [SELECT Name, Category__c FROM Journal_Product__c ORDER BY Name];
for(Journal_Product__c j : journals) {
    System.debug(j.Name + ' - ' + j.Category__c);
}
// Should see all 33 journals
```

### 3. Set Up Lulu Print API Account 🖨️
1. Go to https://www.lulu.com/sell
2. Sign up for free account
3. Navigate to API section
4. Generate API credentials
5. Save credentials for LuluAPIService.cls (next session)

### 4. Set Up Pinterest Business Account 📌
1. Go to https://business.pinterest.com
2. Create business account (free)
3. Create board: "Wellness Journals"
4. Go to Settings → Apps → Developer
5. Generate API credentials (save for PinterestAPIService.cls)

### 5. Start Canva Pro Trial 🎨
1. Go to https://www.canva.com/pro/
2. Start 30-day free trial ($120/year after)
3. Create Brand Kit:
   - Upload logo
   - Set brand colors
   - Upload fonts
4. Create first journal mockup to test workflow

---

## What You Have NOW ✅

### Complete Data Model
- **6 custom objects** with all relationships configured
- **59 custom fields** ready to use
- **33 base journals** ready to load with one command

### Objects Created
1. **Journal_Product__c** - 231 SKU variations (will be created next)
2. **Journal_Customer__c** - Customer tracking across channels
3. **Journal_Sale__c** - Sales from Salesforce, Amazon, Etsy
4. **Marketing_Content__c** - Pinterest/Instagram tracking
5. **Email_Journey__c** - Email campaign management
6. **Email_Send__c** - Individual email conversion tracking

### Data Loader
- **JournalDataLoader.cls** - Loads all 33 journals instantly

---

## Test Your Setup (5 Minutes)

### Verify Deployment
```apex
// Developer Console → Execute Anonymous
// Check objects exist
Schema.DescribeSObjectResult prodDesc = Journal_Product__c.sObjectType.getDescribe();
System.debug('Journal_Product__c created: ' + prodDesc.isCreateable());

Schema.DescribeSObjectResult custDesc = Journal_Customer__c.sObjectType.getDescribe();
System.debug('Journal_Customer__c created: ' + custDesc.isCreateable());

// Load test data
JournalDataLoader.loadAllJournals();

// Query results
Integer count = [SELECT COUNT() FROM Journal_Product__c];
System.debug('Total journals: ' + count); // Should be 33

// Check categories
AggregateResult[] results = [
    SELECT Category__c, COUNT(Id) total
    FROM Journal_Product__c
    GROUP BY Category__c
    ORDER BY Category__c
];
for(AggregateResult ar : results) {
    System.debug(ar.get('Category__c') + ': ' + ar.get('total'));
}
// Moon & Lunar: 4
// Wellness & Mental Health: 5
// Spiritual & Witchcraft: 4
// LGBTQIA+: 3
// Practical Life: 8
// Garden & Homestead: 5
// Fitness & Wellness: 4
```

### Create Test Customer
```apex
Journal_Customer__c testCustomer = new Journal_Customer__c(
    Email__c = 'test@example.com',
    First_Name__c = 'Test',
    Last_Name__c = 'User',
    Source__c = 'Direct',
    Journey_Status__c = 'New'
);
insert testCustomer;
System.debug('Test customer created: ' + testCustomer.Id);
```

### Create Test Sale
```apex
Journal_Product__c gratitude = [
    SELECT Id, Base_Price__c
    FROM Journal_Product__c
    WHERE Name = 'Mental Health Journal'
    LIMIT 1
];

Journal_Customer__c customer = [
    SELECT Id FROM Journal_Customer__c
    WHERE Email__c = 'test@example.com' LIMIT 1
];

Journal_Sale__c testSale = new Journal_Sale__c(
    Journal_Product__c = gratitude.Id,
    Journal_Customer__c = customer.Id,
    Sale_Source__c = 'Salesforce Storefront',
    Sale_Date__c = Date.today(),
    Quantity__c = 1,
    Sale_Price__c = gratitude.Base_Price__c
);
insert testSale;
System.debug('Test sale created: ' + testSale.Id);

// Verify customer lifetime value rollup
Journal_Customer__c updated = [
    SELECT Lifetime_Value__c
    FROM Journal_Customer__c
    WHERE Id = :customer.Id
];
System.debug('Customer LTV: $' + updated.Lifetime_Value__c); // Should be $24.99
```

---

## Current Progress

### ✅ COMPLETED (Phase 1A)
- [x] 6 custom objects with complete data model
- [x] 59 custom fields configured
- [x] JournalDataLoader with all 33 journals
- [x] Master-detail and lookup relationships
- [x] Rollup summary fields (Lifetime Value)
- [x] Formula fields (Profit Margin)

### 🔄 IN PROGRESS (Next Session)
- [ ] LuluAPIService.cls (order fulfillment)
- [ ] PinterestAPIService.cls (marketing automation)
- [ ] EtsyAPIService.cls (order sync)
- [ ] JournalProductService.cls (business logic)
- [ ] JournalCustomerService.cls (customer management)
- [ ] JournalAnalyticsService.cls (reporting)

### ⏳ UPCOMING (Phase 2)
- [ ] Salesforce Flows (automation)
- [ ] LWC Components (dashboard, catalog, configurator)
- [ ] Test classes (75%+ coverage)
- [ ] Permission sets & sharing rules
- [ ] Salesforce Commerce Cloud storefront setup

---

## Your 33 Journals (Reference)

**Moon & Lunar (4)**
1. Beginner's Moon Journal
2. Moon Ritual Journal
3. Manifestation Moon Journal
4. Divination Moon Journal

**Wellness & Mental Health (5)**
5. Mental Health Journal
6. Self-Care Journal
7. 365 Daily Affirmations Journal
8. Meal Planning Journal
9. Skin Care Journal

**Spiritual & Witchcraft (4)**
10. Spoonie Witch Journal
11. Neurodivergent Witch Journal
12. Sacred Cycles Journal
13. Lilith Shadow Work Journal

**LGBTQIA+ (3)**
14. Becoming Her - Trans Feminine Journey
15. Claiming Him - Trans Masculine Journey
16. Rainbow Magic Journal

**Practical Life (8)**
17. Chore Planner
18. Home Maintenance Log
19. Inventory Tracker
20. Emergency Preparedness Guide
21. Home Buying Journey
22. Car Maintenance Log
23. Perimenopause Journal
24. Gym Workout Tracker

**Garden & Homestead (5)**
25. Garden Planner
26. Garden Inventory
27. Gardening Journal
28. Crop Log
29. Foraging Journal

**Fitness & Wellness (4)**
30. Fitness Goal Tracker
31. Workout Log
32. Nutrition Tracker
33. Wellness Habits Journal

---

## Need Help?

### Salesforce Setup Issues
- Check object permissions in profile
- Verify API access enabled
- Check field-level security

### Data Loader Issues
- Run in Developer Console (not Production)
- Check debug logs for errors
- Verify all required fields populated

### Deployment Issues
- Use SFDX CLI for fastest deployment
- VS Code Salesforce Extension works great
- Manual deployment via Setup UI is slower but reliable

---

## Cost Summary (Year 1)

**Required**:
- Salesforce Developer Edition: **FREE** ✅
- Lulu Print API: **FREE** (pay per order) ✅
- Pinterest API: **FREE** ✅
- Canva Pro: **$120/year** 💰

**Optional**:
- Etsy API: **FREE** ✅
- Make.com automation: **$108-348/year** (skip for now)

**Total Annual Cost: $120** (just Canva)

---

**Ready to continue? Let's build the API integration classes next!**
