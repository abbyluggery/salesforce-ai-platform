/**
 * JournalCustomerService
 *
 * Core business logic for customer management.
 * Handles customer lifecycle, journey status, and segmentation.
 *
 * Part of the Journal Business module.
 */
public class JournalCustomerService {

    /**
     * Create or update customer from order
     * @param email - Customer email
     * @param firstName - First name
     * @param lastName - Last name
     * @param source - Source channel (Salesforce Storefront, Amazon, Etsy)
     * @return Customer record
     */
    public static Journal_Customer__c upsertCustomer(String email, String firstName, String lastName, String source) {
        List<Journal_Customer__c> existing = [
            SELECT Id, Email__c, Journey_Status__c, First_Purchase_Date__c
            FROM Journal_Customer__c
            WHERE Email__c = :email
            LIMIT 1
        ];

        Journal_Customer__c customer;

        if (existing.isEmpty()) {
            // New customer
            customer = new Journal_Customer__c(
                Email__c = email,
                First_Name__c = firstName,
                Last_Name__c = lastName,
                Source__c = source,
                Journey_Status__c = 'New',
                First_Purchase_Date__c = Date.today()
            );
            insert customer;
        } else {
            customer = existing[0];

            // Update journey status if needed
            if (customer.Journey_Status__c == 'New') {
                customer.Journey_Status__c = 'First Purchase';
                update customer;
            }
        }

        return customer;
    }

    /**
     * Update customer journey status based on purchase history
     * Called by trigger after sale creation
     */
    public static void updateCustomerJourneyStatus(Set<Id> customerIds) {
        List<Journal_Customer__c> customers = [
            SELECT Id, Journey_Status__c,
                   (SELECT Id, Sale_Date__c FROM Journal_Sales__r ORDER BY Sale_Date__c DESC)
            FROM Journal_Customer__c
            WHERE Id IN :customerIds
        ];

        List<Journal_Customer__c> customersToUpdate = new List<Journal_Customer__c>();

        for (Journal_Customer__c customer : customers) {
            String newStatus = calculateJourneyStatus(customer);

            if (newStatus != customer.Journey_Status__c) {
                customer.Journey_Status__c = newStatus;
                customersToUpdate.add(customer);
            }
        }

        if (!customersToUpdate.isEmpty()) {
            update customersToUpdate;
        }
    }

    /**
     * Calculate appropriate journey status based on purchase history
     */
    private static String calculateJourneyStatus(Journal_Customer__c customer) {
        Integer purchaseCount = customer.Journal_Sales__r.size();

        if (purchaseCount == 0) {
            return 'New';
        } else if (purchaseCount == 1) {
            return 'First Purchase';
        } else if (purchaseCount >= 2 && purchaseCount < 5) {
            return 'Repeat Customer';
        } else if (purchaseCount >= 5) {
            return 'VIP';
        }

        // Check for churned customers (no purchase in 180 days)
        if (!customer.Journal_Sales__r.isEmpty()) {
            Date lastPurchase = customer.Journal_Sales__r[0].Sale_Date__c;
            if (lastPurchase != null && lastPurchase.daysBetween(Date.today()) > 180) {
                return 'Churned';
            }
        }

        return customer.Journey_Status__c;
    }

    /**
     * Get customer segmentation for marketing campaigns
     * @return Map of segment name to customer list
     */
    public static Map<String, List<Journal_Customer__c>> getCustomerSegments() {
        Map<String, List<Journal_Customer__c>> segments = new Map<String, List<Journal_Customer__c>>();

        // Initialize segments
        segments.put('New Customers', new List<Journal_Customer__c>());
        segments.put('First Purchase', new List<Journal_Customer__c>());
        segments.put('Repeat Customers', new List<Journal_Customer__c>());
        segments.put('VIP', new List<Journal_Customer__c>());
        segments.put('At Risk', new List<Journal_Customer__c>());

        List<Journal_Customer__c> allCustomers = [
            SELECT Id, Email__c, First_Name__c, Last_Name__c,
                   Journey_Status__c, Lifetime_Value__c, Source__c,
                   First_Purchase_Date__c, Favorite_Categories__c
            FROM Journal_Customer__c
        ];

        for (Journal_Customer__c customer : allCustomers) {
            String segment = customer.Journey_Status__c;

            if (segment == 'New') {
                segments.get('New Customers').add(customer);
            } else if (segment == 'First Purchase') {
                segments.get('First Purchase').add(customer);
            } else if (segment == 'Repeat Customer') {
                segments.get('Repeat Customers').add(customer);
            } else if (segment == 'VIP') {
                segments.get('VIP').add(customer);
            } else if (segment == 'Churned') {
                segments.get('At Risk').add(customer);
            }
        }

        return segments;
    }

    /**
     * Get customers who haven't purchased in X days (re-engagement)
     * @param daysSinceLastPurchase - Days since last purchase
     * @return List of customers to re-engage
     */
    public static List<Journal_Customer__c> getCustomersForReengagement(Integer daysSinceLastPurchase) {
        Date cutoffDate = Date.today().addDays(-daysSinceLastPurchase);

        List<Journal_Customer__c> customers = [
            SELECT Id, Email__c, First_Name__c, Last_Name__c,
                   Journey_Status__c, Lifetime_Value__c,
                   (SELECT Id, Sale_Date__c FROM Journal_Sales__r ORDER BY Sale_Date__c DESC LIMIT 1)
            FROM Journal_Customer__c
            WHERE Journey_Status__c != 'New'
            AND Journey_Status__c != 'Churned'
        ];

        List<Journal_Customer__c> reengagementList = new List<Journal_Customer__c>();

        for (Journal_Customer__c customer : customers) {
            if (!customer.Journal_Sales__r.isEmpty()) {
                Date lastPurchase = customer.Journal_Sales__r[0].Sale_Date__c;
                if (lastPurchase != null && lastPurchase < cutoffDate) {
                    reengagementList.add(customer);
                }
            }
        }

        return reengagementList;
    }

    /**
     * Update customer's favorite categories based on purchase history
     * Called nightly by scheduled Apex
     */
    public static void updateCustomerFavoriteCategories(Set<Id> customerIds) {
        List<Journal_Customer__c> customers = [
            SELECT Id, Favorite_Categories__c,
                   (SELECT Journal_Product__r.Category__c
                    FROM Journal_Sales__r)
            FROM Journal_Customer__c
            WHERE Id IN :customerIds
        ];

        List<Journal_Customer__c> customersToUpdate = new List<Journal_Customer__c>();

        for (Journal_Customer__c customer : customers) {
            // Count category purchases
            Map<String, Integer> categoryCount = new Map<String, Integer>();

            for (Journal_Sale__c sale : customer.Journal_Sales__r) {
                String category = sale.Journal_Product__r.Category__c;
                if (!categoryCount.containsKey(category)) {
                    categoryCount.put(category, 0);
                }
                categoryCount.put(category, categoryCount.get(category) + 1);
            }

            // Get top 3 categories
            List<String> topCategories = getTopCategories(categoryCount, 3);

            // Update if changed
            String newFavorites = String.join(topCategories, ';');
            if (newFavorites != customer.Favorite_Categories__c) {
                customer.Favorite_Categories__c = newFavorites;
                customersToUpdate.add(customer);
            }
        }

        if (!customersToUpdate.isEmpty()) {
            update customersToUpdate;
        }
    }

    /**
     * Get top N categories from category count map
     */
    private static List<String> getTopCategories(Map<String, Integer> categoryCount, Integer topN) {
        List<CategoryCount> counts = new List<CategoryCount>();

        for (String category : categoryCount.keySet()) {
            CategoryCount cc = new CategoryCount();
            cc.category = category;
            cc.count = categoryCount.get(category);
            counts.add(cc);
        }

        // Sort by count descending
        counts.sort();

        List<String> topCategories = new List<String>();
        for (Integer i = 0; i < Math.min(topN, counts.size()); i++) {
            topCategories.add(counts[i].category);
        }

        return topCategories;
    }

    /**
     * Get customer lifetime value tier
     * @param customerId - Customer ID
     * @return Tier (Bronze, Silver, Gold, Platinum)
     */
    public static String getCustomerLTVTier(Id customerId) {
        Journal_Customer__c customer = [
            SELECT Lifetime_Value__c
            FROM Journal_Customer__c
            WHERE Id = :customerId
            LIMIT 1
        ];

        Decimal ltv = customer.Lifetime_Value__c != null ? customer.Lifetime_Value__c : 0;

        if (ltv >= 500) {
            return 'Platinum';
        } else if (ltv >= 250) {
            return 'Gold';
        } else if (ltv >= 100) {
            return 'Silver';
        } else {
            return 'Bronze';
        }
    }

    /**
     * Helper class for sorting categories by count
     */
    private class CategoryCount implements Comparable {
        String category;
        Integer count;

        public Integer compareTo(Object other) {
            CategoryCount otherCategory = (CategoryCount) other;
            // Sort descending
            return otherCategory.count - this.count;
        }
    }
}
