/**
 * JournalProductService
 *
 * Core business logic for journal product management.
 * Handles product search, recommendations, bundles, and SKU management.
 *
 * Part of the Journal Business module.
 */
public class JournalProductService {

    /**
     * Search products by name, category, or features
     * @param searchTerm - Search term
     * @return List of matching products
     */
    public static List<Journal_Product__c> searchProducts(String searchTerm) {
        String searchPattern = '%' + searchTerm + '%';

        return [
            SELECT Id, Name, Parent_Journal_Name__c, Category__c,
                   Description__c, Product_SKU__c, Base_Price__c,
                   Product_Tier__c, Trim_Size__c, Binding_Type__c,
                   Cover_Image_URL__c, Key_Features__c
            FROM Journal_Product__c
            WHERE Name LIKE :searchPattern
            OR Category__c LIKE :searchPattern
            OR Key_Features__c LIKE :searchPattern
            OR Description__c LIKE :searchPattern
            ORDER BY Name
            LIMIT 50
        ];
    }

    /**
     * Get products by category
     * @param category - Category name
     * @return List of products in category
     */
    public static List<Journal_Product__c> getProductsByCategory(String category) {
        return [
            SELECT Id, Name, Parent_Journal_Name__c, Category__c,
                   Description__c, Product_SKU__c, Base_Price__c,
                   Product_Tier__c, Cover_Image_URL__c
            FROM Journal_Product__c
            WHERE Category__c = :category
            ORDER BY Product_Tier__c, Base_Price__c
        ];
    }

    /**
     * Get all SKU variations for a base journal
     * @param parentJournalName - Parent journal name
     * @return List of all SKU variations
     */
    public static List<Journal_Product__c> getJournalVariations(String parentJournalName) {
        return [
            SELECT Id, Name, Parent_Journal_Name__c, Product_SKU__c,
                   Product_Tier__c, Trim_Size__c, Binding_Type__c,
                   Base_Price__c, Cover_Material__c, Foil_Stamp_Color__c,
                   Has_Ribbon_Bookmark__c, Cover_Image_URL__c
            FROM Journal_Product__c
            WHERE Parent_Journal_Name__c = :parentJournalName
            ORDER BY Product_Tier__c, Base_Price__c
        ];
    }

    /**
     * Get product recommendations based on customer purchase history
     * @param customerId - Journal_Customer__c record ID
     * @return List of recommended products
     */
    public static List<Journal_Product__c> getRecommendations(Id customerId) {
        // Get customer's favorite categories from purchase history
        List<AggregateResult> purchaseHistory = [
            SELECT Journal_Product__r.Category__c category, COUNT(Id) purchases
            FROM Journal_Sale__c
            WHERE Journal_Customer__c = :customerId
            GROUP BY Journal_Product__r.Category__c
            ORDER BY COUNT(Id) DESC
            LIMIT 3
        ];

        Set<String> favoriteCategories = new Set<String>();
        for (AggregateResult ar : purchaseHistory) {
            favoriteCategories.add((String) ar.get('category'));
        }

        // Get products they haven't purchased yet in favorite categories
        Set<Id> purchasedProductIds = new Set<Id>();
        for (Journal_Sale__c sale : [SELECT Journal_Product__c FROM Journal_Sale__c WHERE Journal_Customer__c = :customerId]) {
            purchasedProductIds.add(sale.Journal_Product__c);
        }

        List<Journal_Product__c> recommendations = new List<Journal_Product__c>();

        if (!favoriteCategories.isEmpty()) {
            recommendations = [
                SELECT Id, Name, Category__c, Description__c,
                       Product_SKU__c, Base_Price__c, Product_Tier__c,
                       Cover_Image_URL__c
                FROM Journal_Product__c
                WHERE Category__c IN :favoriteCategories
                AND Id NOT IN :purchasedProductIds
                ORDER BY Product_Tier__c DESC, Base_Price__c DESC
                LIMIT 10
            ];
        }

        return recommendations;
    }

    /**
     * Create bundle pricing
     * @param productIds - List of product IDs in bundle
     * @param bundleDiscountPercent - Discount percentage (e.g., 15 for 15% off)
     * @return Bundle pricing details
     */
    public static BundlePricing calculateBundlePrice(List<Id> productIds, Decimal bundleDiscountPercent) {
        List<Journal_Product__c> products = [
            SELECT Id, Name, Base_Price__c
            FROM Journal_Product__c
            WHERE Id IN :productIds
        ];

        BundlePricing bundle = new BundlePricing();
        bundle.products = products;
        bundle.originalPrice = 0;

        for (Journal_Product__c product : products) {
            bundle.originalPrice += product.Base_Price__c;
        }

        bundle.discountPercent = bundleDiscountPercent;
        bundle.discountAmount = bundle.originalPrice * (bundleDiscountPercent / 100);
        bundle.bundlePrice = bundle.originalPrice - bundle.discountAmount;
        bundle.savings = bundle.discountAmount;

        return bundle;
    }

    /**
     * Get best-selling products
     * @param limit - Number of products to return
     * @return List of best-selling products
     */
    public static List<ProductSalesStats> getBestSellers(Integer limitCount) {
        List<AggregateResult> salesData = [
            SELECT Journal_Product__c productId,
                   Journal_Product__r.Name productName,
                   Journal_Product__r.Category__c category,
                   Journal_Product__r.Base_Price__c price,
                   COUNT(Id) totalSales,
                   SUM(Quantity__c) totalUnits,
                   SUM(Sale_Price__c) totalRevenue
            FROM Journal_Sale__c
            GROUP BY Journal_Product__c,
                     Journal_Product__r.Name,
                     Journal_Product__r.Category__c,
                     Journal_Product__r.Base_Price__c
            ORDER BY COUNT(Id) DESC
            LIMIT :limitCount
        ];

        List<ProductSalesStats> bestSellers = new List<ProductSalesStats>();

        for (AggregateResult ar : salesData) {
            ProductSalesStats stats = new ProductSalesStats();
            stats.productId = (Id) ar.get('productId');
            stats.productName = (String) ar.get('productName');
            stats.category = (String) ar.get('category');
            stats.price = (Decimal) ar.get('price');
            stats.totalSales = (Integer) ar.get('totalSales');
            stats.totalUnits = (Integer) ar.get('totalUnits');
            stats.totalRevenue = (Decimal) ar.get('totalRevenue');
            bestSellers.add(stats);
        }

        return bestSellers;
    }

    /**
     * Get products by price range
     * @param minPrice - Minimum price
     * @param maxPrice - Maximum price
     * @return List of products in price range
     */
    public static List<Journal_Product__c> getProductsByPriceRange(Decimal minPrice, Decimal maxPrice) {
        return [
            SELECT Id, Name, Category__c, Description__c,
                   Product_SKU__c, Base_Price__c, Product_Tier__c,
                   Cover_Image_URL__c
            FROM Journal_Product__c
            WHERE Base_Price__c >= :minPrice
            AND Base_Price__c <= :maxPrice
            ORDER BY Base_Price__c, Name
        ];
    }

    /**
     * Get products by tier
     * @param tier - Product tier (Standard, Premium, Luxury)
     * @return List of products in tier
     */
    public static List<Journal_Product__c> getProductsByTier(String tier) {
        return [
            SELECT Id, Name, Category__c, Description__c,
                   Product_SKU__c, Base_Price__c, Product_Tier__c,
                   Trim_Size__c, Binding_Type__c, Cover_Material__c,
                   Cover_Image_URL__c
            FROM Journal_Product__c
            WHERE Product_Tier__c = :tier
            ORDER BY Category__c, Base_Price__c
        ];
    }

    /**
     * Wrapper class for bundle pricing
     */
    public class BundlePricing {
        public List<Journal_Product__c> products;
        public Decimal originalPrice;
        public Decimal bundlePrice;
        public Decimal discountPercent;
        public Decimal discountAmount;
        public Decimal savings;
    }

    /**
     * Wrapper class for product sales statistics
     */
    public class ProductSalesStats {
        public Id productId;
        public String productName;
        public String category;
        public Decimal price;
        public Integer totalSales;
        public Integer totalUnits;
        public Decimal totalRevenue;
    }
}
