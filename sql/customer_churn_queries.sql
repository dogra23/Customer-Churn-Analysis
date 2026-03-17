create database customer_churn;
use customer_churn;

CREATE TABLE churn_master AS
SELECT 
    f.customer_ID,
    f.gender,
    f.senior_citizen,
    f.partner,
    f.dependents,
    f.tenure,
    f.contract,
    f.payment_method,
    f.paperless_billing,
    f.monthly_charges,
    f.total_charges,
    s.`Internet Type`,
    s.`Online Security`,
    s.`Online Backup`,
    s.`Premium Tech Support`,
    s.`Streaming TV`,
    s.`Streaming Movies`,
    cs.`Churn Category`,
    cs.`Churn Reason`,
    cs.`Satisfaction Score`,
    cs.`Churn Score`,
    cs.CLTV,
    f.churn
    
FROM fact_churn_table f
LEFT JOIN dim_churn_services s 
    ON f.customer_ID = s. `ï»¿Customer ID`
LEFT JOIN dim_churn_status cs 
    ON f.customer_ID = cs.`ï»¿Customer ID`;
    

select * from churn_master;

update churn_master
set `Internet Type` = 'No Internet'
where `Internet Type` = 'None';

select churn,
count(*) as total_customers
from churn_master
group by churn;

select 
count(*) as total_customer,
sum(case when churn = 'Yes' then 1  else 0 end) as churned_customers,
round(sum(case when churn ='Yes' then 1 else 0 end)*100.0/COUNT(*),2) as churn_rate
from churn_master;

-- Churn rate is 26% (approx) meaning 1 out of 4 customers leave the service


SELECT 
Contract,
COUNT(*) AS total_customers,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS churn_rate
FROM churn_master
GROUP BY Contract
ORDER BY churn_rate DESC;

-- Customers with month-to-month contracts churn significantly more, indicating a lack of long-term commitment.


SELECT 
CASE
WHEN tenure <= 6 THEN '0-6 months'
WHEN tenure <= 12 THEN '6-12 months'
WHEN tenure <= 24 THEN '12-24 months'
ELSE '24+ months'
END AS tenure_group,
COUNT(*) AS customers,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
round(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END)*100.00/COUNT(*),2) as churn_rate
FROM churn_master
GROUP BY tenure_group
ORDER BY tenure_group;

-- created a tenure group for furthur analysis



select
round(sum(total_charges),2) as monthly_revenue_lost
from churn_master
where churn = 'Yes';




SELECT 
CASE
WHEN Monthly_Charges < 40 THEN 'Low'
WHEN Monthly_Charges BETWEEN 40 AND 80 THEN 'Medium'
ELSE 'High'
END AS charge_category,
COUNT(*) AS customers,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
round(sum(case when churn = 'Yes' then 1 else 0 end)*100.00/count(*),2) as churn_rate
FROM churn_master
GROUP BY charge_category;

-- created charge category to anlayse the relation between charge price and churn


SELECT 
`Internet Type`,
COUNT(*) AS customers,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
round(sum(case when churn = 'Yes' then 1 else 0 end)*100/count(*),2) as churn_rate
FROM churn_master
GROUP BY `Internet Type`
ORDER BY churned DESC;



SELECT 
`Premium Tech Support`,
COUNT(*) AS customers,
SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned,
round(sum(case when churn = 'Yes' then 1 else 0 end)*100/count(*),2) as churn_rate
FROM churn_master
GROUP BY `Premium Tech Support`;

-- services vs churn (customer with NO tech support churn significantly more than those who opt for tech support)




SELECT 
`Churn category`,
COUNT(*) AS customers
FROM churn_master
WHERE Churn='Yes'
GROUP BY `Churn category`
ORDER BY customers DESC;



SELECT 
`Satisfaction Score`,
COUNT(*) AS customers,
SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) AS churned
FROM churn_master
GROUP BY `Satisfaction Score`
ORDER BY `Satisfaction Score`;

-- Low Satisfaction score (1 or 2) are responsible for 100% churn rate whereas High satisfaction score churn rate is 0%


SELECT 
tenure,
COUNT(*) AS churned_customers
FROM churn_master
WHERE churn = 'Yes'
GROUP BY tenure
ORDER BY tenure;



SELECT 
AVG(tenure) AS avg_tenure
FROM churn_master;


SELECT 
contract,
`Internet Type`,
COUNT(*) AS customers,
SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) AS churned
FROM churn_master
GROUP BY contract, `Internet Type`
ORDER BY contract;


SELECT 
contract,
SUM(monthly_charges) AS revenue
FROM churn_master
GROUP BY contract
ORDER BY revenue DESC;

-- revenue loss because of month-to-month conract type is very high


SELECT 
payment_method,
COUNT(*) AS customers,
SUM(CASE WHEN churn='Yes' THEN 1 ELSE 0 END) AS churned
FROM churn_master
GROUP BY payment_method
ORDER BY churned DESC;


SELECT *,
case when risk_score >=4 then 'High risk'
when risk_score >=2 then 'Medium risk'
else 'Low risk'
end as risk_category
from (
select
Customer_ID,
(
CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END +
CASE WHEN Tenure <= 12 THEN 1 ELSE 0 END +
CASE WHEN `Internet Type` = 'Fiber Optic' THEN 1 ELSE 0 END +
CASE WHEN `Premium Tech Support` = 'No' THEN 1 ELSE 0 END +
CASE WHEN `Satisfaction Score` <= 2 THEN 1 ELSE 0 END +
CASE WHEN Monthly_Charges > 80 THEN 1 ELSE 0 END
) AS risk_score,
churn
from churn_master) t;

-- Created a risk score considering the 6 important parameters like contract, tenure, service type, satisfaction score and pricing(i.e total of 6 points)
-- furthur created a risk category of high,medium or low considering the risk score of each customer.