/**
 * JournalAnalyticsService
 *
 * Analytics and reporting for journal business metrics.
 * Provides sales analytics, marketing performance, and business insights.
 *
 * Part of the Journal Business module.
 */
public class JournalAnalyticsService {

    /**
     * Get sales summary for a date range
     * @param startDate - Start date
     * @param endDate - End date
     * @return Sales summary
     */
    public static SalesSummary getSalesSummary(Date startDate, Date endDate) {
        List<AggregateResult> salesData = [
            SELECT COUNT(Id) totalOrders,
                   SUM(Quantity__c) totalUnits,
                   SUM(Sale_Price__c) totalRevenue,
                   AVG(Sale_Price__c) avgOrderValue
            FROM Journal_Sale__c
            WHERE Sale_Date__c >= :startDate
            AND Sale_Date__c <= :endDate
        ];

        SalesSummary summary = new SalesSummary();

        if (!salesData.isEmpty()) {
            AggregateResult ar = salesData[0];
            summary.totalOrders = (Integer) ar.get('totalOrders');
            summary.totalUnits = (Integer) ar.get('totalUnits');
            summary.totalRevenue = (Decimal) ar.get('totalRevenue');
            summary.avgOrderValue = (Decimal) ar.get('avgOrderValue');
        }

        summary.startDate = startDate;
        summary.endDate = endDate;

        return summary;
    }

    /**
     * Get sales by channel
     * @param startDate - Start date
     * @param endDate - End date
     * @return Map of channel to sales data
     */
    public static Map<String, ChannelSales> getSalesByChannel(Date startDate, Date endDate) {
        List<AggregateResult> channelData = [
            SELECT Sale_Source__c channel,
                   COUNT(Id) orders,
                   SUM(Sale_Price__c) revenue
            FROM Journal_Sale__c
            WHERE Sale_Date__c >= :startDate
            AND Sale_Date__c <= :endDate
            GROUP BY Sale_Source__c
        ];

        Map<String, ChannelSales> channelSales = new Map<String, ChannelSales>();

        for (AggregateResult ar : channelData) {
            ChannelSales cs = new ChannelSales();
            cs.channel = (String) ar.get('channel');
            cs.orders = (Integer) ar.get('orders');
            cs.revenue = (Decimal) ar.get('revenue');
            channelSales.put(cs.channel, cs);
        }

        return channelSales;
    }

    /**
     * Get sales by category
     * @param startDate - Start date
     * @param endDate - End date
     * @return Map of category to sales data
     */
    public static Map<String, CategorySales> getSalesByCategory(Date startDate, Date endDate) {
        List<AggregateResult> categoryData = [
            SELECT Journal_Product__r.Category__c category,
                   COUNT(Id) orders,
                   SUM(Quantity__c) units,
                   SUM(Sale_Price__c) revenue
            FROM Journal_Sale__c
            WHERE Sale_Date__c >= :startDate
            AND Sale_Date__c <= :endDate
            GROUP BY Journal_Product__r.Category__c
        ];

        Map<String, CategorySales> categorySales = new Map<String, CategorySales>();

        for (AggregateResult ar : categoryData) {
            CategorySales cs = new CategorySales();
            cs.category = (String) ar.get('category');
            cs.orders = (Integer) ar.get('orders');
            cs.units = (Integer) ar.get('units');
            cs.revenue = (Decimal) ar.get('revenue');
            categorySales.put(cs.category, cs);
        }

        return categorySales;
    }

    /**
     * Get top products by revenue
     * @param startDate - Start date
     * @param endDate - End date
     * @param limitCount - Number of products to return
     * @return List of top products
     */
    public static List<TopProduct> getTopProductsByRevenue(Date startDate, Date endDate, Integer limitCount) {
        List<AggregateResult> topProducts = [
            SELECT Journal_Product__c productId,
                   Journal_Product__r.Name productName,
                   Journal_Product__r.Category__c category,
                   COUNT(Id) orders,
                   SUM(Quantity__c) units,
                   SUM(Sale_Price__c) revenue
            FROM Journal_Sale__c
            WHERE Sale_Date__c >= :startDate
            AND Sale_Date__c <= :endDate
            GROUP BY Journal_Product__c,
                     Journal_Product__r.Name,
                     Journal_Product__r.Category__c
            ORDER BY SUM(Sale_Price__c) DESC
            LIMIT :limitCount
        ];

        List<TopProduct> products = new List<TopProduct>();

        for (AggregateResult ar : topProducts) {
            TopProduct tp = new TopProduct();
            tp.productId = (Id) ar.get('productId');
            tp.productName = (String) ar.get('productName');
            tp.category = (String) ar.get('category');
            tp.orders = (Integer) ar.get('orders');
            tp.units = (Integer) ar.get('units');
            tp.revenue = (Decimal) ar.get('revenue');
            products.add(tp);
        }

        return products;
    }

    /**
     * Get marketing ROI analysis
     * @param startDate - Start date
     * @param endDate - End date
     * @return Marketing ROI data
     */
    public static MarketingROI getMarketingROI(Date startDate, Date endDate) {
        // Get Pinterest performance
        List<AggregateResult> pinterestData = [
            SELECT SUM(Impressions__c) totalImpressions,
                   SUM(Clicks__c) totalClicks,
                   SUM(Saves__c) totalSaves
            FROM Marketing_Content__c
            WHERE Content_Type__c = 'Pinterest Pin'
            AND Posted_Date__c >= :startDate
            AND Posted_Date__c <= :endDate
        ];

        MarketingROI roi = new MarketingROI();

        if (!pinterestData.isEmpty()) {
            AggregateResult ar = pinterestData[0];
            roi.totalImpressions = (Integer) ar.get('totalImpressions');
            roi.totalClicks = (Integer) ar.get('totalClicks');
            roi.totalSaves = (Integer) ar.get('totalSaves');
        }

        // Calculate click-through rate
        if (roi.totalImpressions > 0) {
            roi.clickThroughRate = (Decimal.valueOf(roi.totalClicks) / Decimal.valueOf(roi.totalImpressions)) * 100;
        }

        // Get sales from Pinterest traffic (would need utm tracking in real implementation)
        roi.startDate = startDate;
        roi.endDate = endDate;

        return roi;
    }

    /**
     * Get customer acquisition metrics
     * @param startDate - Start date
     * @param endDate - End date
     * @return Customer acquisition data
     */
    public static CustomerAcquisition getCustomerAcquisition(Date startDate, Date endDate) {
        // New customers in date range
        List<Journal_Customer__c> newCustomers = [
            SELECT Id, Source__c, Lifetime_Value__c
            FROM Journal_Customer__c
            WHERE First_Purchase_Date__c >= :startDate
            AND First_Purchase_Date__c <= :endDate
        ];

        CustomerAcquisition acquisition = new CustomerAcquisition();
        acquisition.totalNewCustomers = newCustomers.size();
        acquisition.startDate = startDate;
        acquisition.endDate = endDate;

        // Count by source
        Map<String, Integer> sourceCount = new Map<String, Integer>();
        Decimal totalLTV = 0;

        for (Journal_Customer__c customer : newCustomers) {
            String source = customer.Source__c;
            if (!sourceCount.containsKey(source)) {
                sourceCount.put(source, 0);
            }
            sourceCount.put(source, sourceCount.get(source) + 1);

            if (customer.Lifetime_Value__c != null) {
                totalLTV += customer.Lifetime_Value__c;
            }
        }

        acquisition.customersBySource = sourceCount;

        // Calculate average customer lifetime value
        if (acquisition.totalNewCustomers > 0) {
            acquisition.avgCustomerLTV = totalLTV / acquisition.totalNewCustomers;
        }

        return acquisition;
    }

    /**
     * Get fulfillment metrics
     * @return Fulfillment status summary
     */
    public static FulfillmentMetrics getFulfillmentMetrics() {
        List<AggregateResult> fulfillmentData = [
            SELECT Fulfillment_Status__c status,
                   COUNT(Id) count
            FROM Journal_Sale__c
            WHERE Fulfillment_Status__c != null
            GROUP BY Fulfillment_Status__c
        ];

        FulfillmentMetrics metrics = new FulfillmentMetrics();
        metrics.statusCounts = new Map<String, Integer>();

        for (AggregateResult ar : fulfillmentData) {
            String status = (String) ar.get('status');
            Integer count = (Integer) ar.get('count');
            metrics.statusCounts.put(status, count);
        }

        return metrics;
    }

    /**
     * Get email campaign performance
     * @param journeyId - Email_Journey__c record ID
     * @return Campaign performance metrics
     */
    public static EmailCampaignPerformance getEmailCampaignPerformance(Id journeyId) {
        List<Email_Send__c> sends = [
            SELECT Id, Opened__c, Clicked__c, Purchased__c
            FROM Email_Send__c
            WHERE Email_Journey__c = :journeyId
        ];

        EmailCampaignPerformance performance = new EmailCampaignPerformance();
        performance.totalSent = sends.size();
        performance.totalOpened = 0;
        performance.totalClicked = 0;
        performance.totalPurchased = 0;

        for (Email_Send__c send : sends) {
            if (send.Opened__c) performance.totalOpened++;
            if (send.Clicked__c) performance.totalClicked++;
            if (send.Purchased__c) performance.totalPurchased++;
        }

        // Calculate rates
        if (performance.totalSent > 0) {
            performance.openRate = (Decimal.valueOf(performance.totalOpened) / performance.totalSent) * 100;
            performance.clickRate = (Decimal.valueOf(performance.totalClicked) / performance.totalSent) * 100;
            performance.conversionRate = (Decimal.valueOf(performance.totalPurchased) / performance.totalSent) * 100;
        }

        return performance;
    }

    // Wrapper classes for analytics data

    public class SalesSummary {
        public Date startDate;
        public Date endDate;
        public Integer totalOrders;
        public Integer totalUnits;
        public Decimal totalRevenue;
        public Decimal avgOrderValue;
    }

    public class ChannelSales {
        public String channel;
        public Integer orders;
        public Decimal revenue;
    }

    public class CategorySales {
        public String category;
        public Integer orders;
        public Integer units;
        public Decimal revenue;
    }

    public class TopProduct {
        public Id productId;
        public String productName;
        public String category;
        public Integer orders;
        public Integer units;
        public Decimal revenue;
    }

    public class MarketingROI {
        public Date startDate;
        public Date endDate;
        public Integer totalImpressions;
        public Integer totalClicks;
        public Integer totalSaves;
        public Decimal clickThroughRate;
    }

    public class CustomerAcquisition {
        public Date startDate;
        public Date endDate;
        public Integer totalNewCustomers;
        public Map<String, Integer> customersBySource;
        public Decimal avgCustomerLTV;
    }

    public class FulfillmentMetrics {
        public Map<String, Integer> statusCounts;
    }

    public class EmailCampaignPerformance {
        public Integer totalSent;
        public Integer totalOpened;
        public Integer totalClicked;
        public Integer totalPurchased;
        public Decimal openRate;
        public Decimal clickRate;
        public Decimal conversionRate;
    }
}
