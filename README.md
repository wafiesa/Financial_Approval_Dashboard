# Financial_Approvals_Dashboard

### **Introduction**

The Central Bank of Malaysia (Bank Negara Malaysia, BNM) champions the Financial Inclusion initiatives with the vision of building an inclusive financial system. This initiative ensures equitable access to affordable, high-quality financial services for all Malaysians, particularly underserved communities. Financial inclusion plays a vital role in promoting shared prosperity and economic development by empowering individuals and small businesses to engage actively in the financial ecosystem.

One of many substantial contributions that have supported the growing number of Small and Medium Enterprises (SMEs) over the years is the availability of access to financing. The financing offered by Financial Institutions (FIs) was the backbone that steered new businesses to establish.

---

### **Financial Outlook for SMEs**

The Small and Medium Enterprises (SMEs) are important to Malaysia’s economic growth, contributing significantly to employment and Gross Domestic Product (GDP). Financial inclusion for SMEs is essential to enable their participation in competitive markets. Challenges such as limited access to credit, high borrowing costs and knowledge gaps in navigating financial products hinder SMEs’ growth potential.

BNM's targeted strategies include:
- Streamlining SME financing approvals.
- Expanding the range of tailored financial products for SMEs.
- Partnering with development financial institutions to reduce funding risks for lenders.

The strageties from BNM has put inplace a financial inclusion report from FIs as follows:
- Commercial Banks
- Islamic Banks
- Investment Banks
- Development Financial Institutions

---

### **Dataset Information**

The dataset from BNM Financial Inclusion, titled "1.12_Approvals_by_Sector" which can be obtained from https://www.bnm.gov.my/financial-inclusion-data-for-malaysia  includes data on financing approvals across various economic sectors.

The key components in the dataset include:

1. **Economic Sectors**:
   - Agriculture, Forestry and Fishing
   - Mining and Quarrying
   - Manufacturing
   - Electricity, Gas, Steam and Air Conditioning Supply
   - Water Supply, Sewerage, Waste Management and Remediation Activities
   - Construction
   - Wholesale and Retail Trade
   - Accommodation and Food Service Activities
   - Transportation & Storage
   - Information & Communication
   - Financial and Insurance/Takaful Activities
   - Real Estate Activities
   - Professional, Scientific and Technical Activities
   - Administrative and Support Service Activities
   - Education, Health and Others
   - Other Sectors
     
2. **Financial Institutions**:
   - Commercial Banks
   - Islamic Banks
   - Investment Banks
   - Development Financial Institutions

---

### **Financing Approvals Dashboard**

1. **About The Dashboard**:
   - This dashboard provides an overview of financing approvals for SMEs categorised by Financial Institutions (FIs).
   - The data was acquired from the website of the Central Bank of Malaysia (BNM) to perform time series analysis on the financing approvals for 16 economic sectors.

2. **Data Overview**:
   - Data Overview Tab displays an overview of the dataset, including details of economic sectors and financial institutions.
   - It uses the 1.12_Approvals_by_Sector dataset from BNM. Several data cleaning steps have been applied to make the raw dataset compatible with this dashboard. Future users can use the same dataset (1.12_Approvals_by_Sector) without additional preparation.

3. **Time Series**:
   - Produces time series plots from the dataset, allowing users to select an economic sector and financial institution.
   - It provides insights into trends, seasonality and random fluctuations within the time series data.
     
4. **Forecasting**:
   - Displays forecast plots for a selected economic sector and financial institution using the Auto ARIMA model.
   - Users can enhance the model by adjusting the forecasting period ahead. The forecast plot automatically updates when this setting is modified.

---

### **Recommendations**

1. **Utilising The Dashboard**:
   - Utilise predictive analytics to identify underserved economic sectors.
   - Regularly update datasets to reflect evolving financial trends and inclusion gaps.
     
2. **Future Forecasting Model Improvement**:
   - Currently, the dashboard is developed by adapting forecasting method using Auto ARIMA model. However, future developers can use other method such as Exponential Smoothing, Holt-Winters or Prophet a method developed by META. 

---

### **Conclusion**

The time series dashboard is a valuable tool for observing trends in financing approvals by financial institutions across economic sectors. Insights derived from the dashboard can guide financial institutions in aligning resources to support BNM’s financial inclusion vision. Additionally, it is hoped that this dashboard will disseminate financing information for SMEs across various economic sectors and encourage financial institutions to provide financing solutions for underserved sectors in the near future.

Disclaimer: The developer of this dashboard is not responsible for collecting the dataset, as it primarily visualises time series data derived from BNM's dataset. It should also be noted that BNM, as a monetary regulator, has the right to revise and expand the dataset. The developer is not liable for any losses resulting from the use of this dashboard.
