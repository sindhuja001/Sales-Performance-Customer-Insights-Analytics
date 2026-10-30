# E-commerce Sales, Customer Behaviour and Profitability Analytics



## Business Insights Report



**Business Case:** NovaCart Global

**Analysis Period:** 2012–2015

**Dataset:** Global Superstore public business-case dataset

**Prepared For:** Executive and commercial decision-making



> **Disclosure:** NovaCart Global is a fictional company created for this portfolio project. The analysis uses the public Global Superstore sample dataset and should not be presented as verified transactional data from a named real company.



## Analysis Scope



This report consolidates insights produced through Python exploratory analysis, statistical testing, MySQL analysis, Excel reporting and Power BI dashboards.



The validated analytical dataset contains:



\- 51,290 sales line records

\- 25,739 analytical orders

\- 796 customers

\- 3,788 products

\- Sales activity across 2012–2015



## 1. Executive Summary



NovaCart Global generated **$12.64M in revenue** and **$1.47M in profit**, resulting in an overall **11.61% profit margin**. Revenue increased from approximately **$2.26M in 2012 to $4.30M in 2015**, while profit increased from approximately **$248.94K to $504.17K**.



The business is growing, but the analysis identified several profitability risks:



\- Revenue growth has been driven primarily by increased order volume rather than improvement in average order value.

\- Technology is the strongest category for both revenue and profit.

\- Furniture profitability is weakened significantly by the Tables sub-category.

\- High discount levels have a strong negative relationship with profit margin.

\- Discount bands above 20% are loss-making in aggregate.

\- Several countries, products and customer transactions generate revenue while destroying profit.

\- Customer activity is highly concentrated among repeat purchasers.

\- Returns affect a relatively small share of orders, but product-level return findings must be interpreted as associations because partial-return details are unavailable.



The strongest commercial opportunity is to protect profitable growth by controlling deep discounts, reviewing loss-making products and using customer and geographic performance differences to guide targeted decisions.



## 2. Revenue Growth and Seasonality



### 2.1 Multi-Year Growth



Revenue increased consistently during the four-year analysis period:



\- **2012:** $2.26M

\- **2013:** $2.68M

\- **2014:** $3.41M

\- **2015:** $4.30M



Profit also increased from approximately **$248.94K in 2012** to **$504.17K in 2015**.



However, average order value decreased from approximately **$500.32 in 2012** to **$485.31 in 2015**. This indicates that business growth was driven mainly by a higher number of orders rather than customers spending more per order.



### 2.2 Monthly Seasonality



November and December generated the strongest monthly revenue performance. However, the highest-revenue period did not always produce the strongest margins:



\- **October recorded the highest monthly profit margin at approximately 13.41%.**

\- **December recorded a lower margin of approximately 10.73%.**



This difference shows that high sales volume alone does not guarantee high-quality profit. Seasonal promotions, discount levels and product mix should be evaluated together when interpreting peak-period performance.



### 2.3 Business Interpretation



The historical growth trend is positive, but its quality depends heavily on maintaining profitability as order volume increases. The declining average order value and lower margin during the peak revenue period indicate that future performance should be monitored using revenue, order volume, average order value and profit margin together rather than revenue alone.



## 3. Product and Category Performance



### Category Performance



Technology was the strongest category. It generated the highest revenue and profit.



Furniture generated about **32.51% of total revenue**, but contributed only **19.43% of total profit**. This shows that Furniture sales are high, but its profitability is weaker than the other categories.



### Tables Are the Main Problem Area



Tables was the only sub-category with an overall loss:



\- Revenue: **$757.04K**

\- Profit: **-$64.08K**

\- Profit Margin: **-8.46%**

\- Average Discount: **29.07%**



Tables reduced the overall Furniture category margin by approximately **3.47 percentage points**. High discounts are one of the main reasons for this poor result.



### Loss-Making Products



The analysis found **677 loss-making products**. Together, these products generated **19.28% of total revenue**, but produced a combined loss of approximately **$247.84K**.



This is important because some products may look successful when they are ranked only by revenue. Profit and profit margin must also be checked before deciding whether a product is performing well.



### What This Means



Technology should remain a key growth category. Furniture, especially Tables, needs closer review. Product performance should be judged using revenue, profit, margin and discount together.



## 4. Discount Impact on Profitability



Discount was the strongest factor linked with poor profitability.



The statistical analysis found a strong negative relationship between discount and line-level profit margin (**Spearman correlation: -0.67**). In simple terms, profit margin usually decreased as discount increased.



### Margin by Discount Level



\- Transactions with no discount had a median margin of approximately **27.00%**.

\- At a **20–30% discount**, the median margin fell to approximately **-4.29%**.

\- At discounts above **30%**, the median margin fell to approximately **-55.52%**.

\- Approximately **92.44% of sales lines** with discounts above 30% were loss-making.



Discount bands above 20% were loss-making overall. Discounts above 30% generated a combined loss of approximately **$793.53K**.



### Deep-Discount Risk



The discount band above 50% recorded:



\- Revenue: **$371.62K**

\- Profit: **-$412.58K**

\- Profit Margin: **-111.02%**

\- Average Discount: **65.81%**



This means the business lost more money than the revenue it generated from this discount band.



### What This Means



Discounts can increase sales, but deep discounts are damaging profit. Revenue from heavily discounted orders should not be treated as successful sales unless the final profit is also positive.



## 5. Geography and Market Performance



Performance was different across markets.



### Market Results



\- **Asia Pacific** generated the highest revenue at approximately **$4.04M**. However, its profit margin was only **9.97%**.

\- **Europe** generated approximately **$3.29M in revenue** and the highest market profit of approximately **$449.55K**. It also recorded the strongest market margin at **13.68%**.

\- **USCA** generated approximately **$2.36M in revenue** with a **12.87% margin**.

\- **LATAM** generated approximately **$2.16M in revenue** with a **10.24% margin**.

\- **Africa** generated approximately **$783.77K in revenue** with an **11.34% margin**.



Asia Pacific had the highest average discount among the markets at approximately **18.10%**, while Europe had the lowest at approximately **9.09%**. This difference helps explain why Europe produced stronger profit from lower revenue.



### Loss-Making Countries



The analysis found **31 loss-making countries**. Turkey and Nigeria recorded some of the largest country-level losses, along with high discount levels.



### What This Means



High market revenue does not always mean strong profitability. Market-level results should be checked together with Region and Country details because profitable markets can still contain loss-making locations.



## 6. Customer Behaviour



### Repeat Purchasing



Out of 796 customers, **795 customers placed more than one order** during the four-year dataset period. This gives an observed repeat-purchase rate of approximately **99.87%**.



Orders from returning customers generated approximately **96.86% of total revenue**.



This figure should not be described as customer retention. The dataset does not contain complete customer acquisition, churn or contract information. It only shows that most customers made repeat purchases during the available period.



### Customer Segments



\- **Consumer** was the largest segment, with 409 customers and approximately **$6.51M in revenue**.

\- **Corporate** recorded the highest revenue per customer at approximately **$16.07K** and the highest average order value at approximately **$494.98**.

\- **Home Office** recorded the highest profit margin at approximately **11.99%**.



The differences between the three segments are not very large, but they are useful for planning segment-specific sales and pricing decisions.



### Customers Requiring Attention



RFM analysis identified an **At Risk** customer group with approximately **$2.02M in historical revenue**. These customers were valuable in the past but had lower recent activity.



### Customer Profit Value



The average estimated 12-month customer profit value was approximately **$492.85**.



This value is a historical 12-month profit proxy, not a predictive customer lifetime value model. It should be used as a simple comparison measure between customers and segments.



### What This Means



Repeat customers are very important to the business. Customer analysis should focus on protecting valuable repeat purchasers, reviewing inactive high-value customers and understanding the small performance differences between customer segments.



## 7. Returns Analysis



The dataset contains **1,079 returned orders** out of 25,739 total orders. This gives an overall returned-order rate of approximately **4.19%**.



Return rates were fairly close across markets:



\- Africa: **3.80%**

\- Asia Pacific: **4.34%**

\- Europe: **4.04%**

\- LATAM: **4.06%**

\- USCA: **4.47%**



USCA recorded the highest market return rate, but the difference between markets was relatively small.



The discount band above 50% had a return rate of approximately **3.73%**, which was below the overall return rate. This suggests that returns were not the main reason for the large losses in the deep-discount group. The losses were more closely linked with pricing and discount levels.



### Data Limitation



The Returns table identifies returned orders, but it does not show which individual items were returned from a multi-product order.



For this reason, product-level results should be described as **products appearing in returned orders**, not as confirmed returned products.



### What This Means



Returns should continue to be monitored, especially in USCA and for products that frequently appear in returned orders. However, the overall analysis shows that discounting and product profitability are larger financial risks than the current return rate.



## 8. Statistical and Advanced Analysis



### Discount and Loss Risk



Statistical tests confirmed that the discount findings were not caused by a few unusual transactions.



\- Discount level and loss-making status had a strong association (**Cramer's V: 0.84**).

\- Differences in profit margin across discount bands had a large effect size (**Epsilon Squared: 0.50**).

\- The relationship between discount and line-level margin was strongly negative (**Spearman correlation: -0.67**).



These results support the business finding that deep discounting is a major profitability risk.



### Category Profitability



Furniture had a median product margin of approximately **9.04%** and performed weaker than Office Supplies in the product-level statistical comparison.



However, the difference between product categories was much smaller than the effect of discounting. This means discount control may have a larger overall impact than category-level changes alone.



### Customer Activity Over Time



The weighted Month-2 customer activity rate was approximately **28.19%**, while Month-12 activity was approximately **38.35%**.



The rate can increase again in later months because customers may return after gaps between purchases. Therefore, this analysis shows customer purchasing activity by cohort and should not be treated as a standard subscription-retention curve.



### Market Basket Analysis



Exact product pairs were too sparse for reliable conclusions. The most common exact product pair appeared together in only three orders.



At a broader category level:



\- **Appliances and Paper** recorded a lift of approximately **1.17**.

\- **Accessories and Phones** appeared together in 377 orders and showed a positive relationship.



These results may support cross-selling tests, but they should be treated as early signals rather than guaranteed customer buying patterns.



## 9. Key Findings Summary



The main findings from the complete analysis are:



1\. Revenue and profit increased strongly between 2012 and 2015.

2\. Growth was driven mainly by more orders, while average order value slightly decreased.

3\. Technology was the strongest category for both revenue and profit.

4\. Tables was the main loss-making sub-category and reduced Furniture profitability.

5\. Deep discounting was the strongest profitability risk found in the analysis.

6\. Asia Pacific generated the highest revenue, while Europe generated the highest profit and strongest market margin.

7\. Thirty-one countries were loss-making, showing that market-level results can hide local problems.

8\. Repeat purchasers generated most of the business revenue.

9\. The At Risk customer group contained customers with high historical value.

10\. The overall returned-order rate was 4.19%, but returns were a smaller financial risk than discounting and loss-making products.



## 10. Important Limitations



The following limitations should be considered when using the results:



\- The project uses a public sample dataset and a fictional company scenario.

\- The analysis shows historical relationships and does not prove that one factor directly caused another.

\- Return information is available at order level, not individual product-return level.

\- The repeat-purchase rate is not the same as customer retention.

\- The 12-month customer profit value is a historical proxy, not a predictive lifetime value model.

\- Exact product-pair results were too sparse for strong market basket conclusions.

\- Missing postal codes were retained because they mainly belonged to non-US locations where postal codes were not consistently available.

\- Negative-profit transactions and statistical outliers were retained because they represent valid business activity and are important for profitability analysis.



## Conclusion



NovaCart Global showed strong sales and profit growth, but a meaningful share of revenue came from low-margin or loss-making activity.



The clearest issue was deep discounting, followed by loss-making products and weaker performance in specific countries and sub-categories. The business can improve the quality of future growth by measuring success using profit and margin together with revenue.
