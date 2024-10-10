# Задача 1
WITH MonthlyTransactions AS (
    SELECT 
        t.ID_client,
        DATE_FORMAT(t.date_new, '%Y-%m') AS yearmonth,
        COUNT(t.Id_check) AS transactions_per_month,
        AVG(t.Sum_payment) AS avg_check_per_month
    FROM transactionsinfo t
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY t.ID_client, DATE_FORMAT(t.date_new, '%Y-%m')
),
ClientHistory AS (
    SELECT 
        mt.ID_client,
        COUNT(DISTINCT mt.yearmonth) AS active_months,
        AVG(mt.avg_check_per_month) AS avg_monthly_check,
        SUM(mt.transactions_per_month) AS total_transactions
    FROM MonthlyTransactions mt
    GROUP BY mt.ID_client
)
SELECT 
    c.ID_client,
    c.Total_amount,
    ch.avg_monthly_check,
    ch.total_transactions
FROM ClientHistory ch
JOIN customerinfo c ON ch.ID_client = c.ID_client
WHERE ch.active_months = 12;

# Задача 2
WITH MonthlyData AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS yearmonth,
        COUNT(t.Id_check) AS transactions_per_month,
        AVG(t.Sum_payment) AS avg_check,
        COUNT(DISTINCT t.ID_client) AS active_clients,
        SUM(t.Sum_payment) AS total_monthly_sum
    FROM transactionsinfo t
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY yearmonth
),
YearlyData AS (
    SELECT 
        SUM(md.transactions_per_month) AS total_transactions_year,
        SUM(md.total_monthly_sum) AS total_sum_year
    FROM MonthlyData md
)
SELECT 
    md.yearmonth,
    md.avg_check,
    md.transactions_per_month,
    md.active_clients,
    (md.transactions_per_month / yd.total_transactions_year) * 100 AS transaction_share_percentage,
    (md.total_monthly_sum / yd.total_sum_year) * 100 AS sum_share_percentage
FROM MonthlyData md
CROSS JOIN YearlyData yd;

# Задача 3
WITH AgeGroups AS (
    SELECT 
        CASE 
            WHEN c.Age IS NULL THEN 'Unknown'
            WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
            WHEN c.Age >= 80 THEN '80+'
        END AS agegroup,
        t.ID_client,
        SUM(t.Sum_payment) AS total_sum,
        COUNT(t.Id_check) AS total_transactions
    FROM transactionsinfo t
    JOIN customerinfo c ON t.ID_client = c.ID_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY agegroup, t.ID_client
),
QuarterlyData AS (
    SELECT 
        CASE 
            WHEN c.Age IS NULL THEN 'Unknown'
            WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
            WHEN c.Age >= 80 THEN '80+'
        END AS agegroup,
        DATE_FORMAT(t.date_new, '%Y-Q%q') AS year_quarter,
        AVG(t.Sum_payment) AS avg_sum_per_quarter,
        COUNT(t.Id_check) AS transactions_per_quarter
    FROM transactionsinfo t
    JOIN customerinfo c ON t.ID_client = c.ID_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY agegroup, year_quarter
)
SELECT 
    ag.agegroup,
    SUM(ag.total_sum) AS total_sum_period,
    SUM(ag.total_transactions) AS total_transactions_period,
    AVG(qd.avg_sum_per_quarter) AS avg_sum_quarter,
    AVG(qd.transactions_per_quarter) AS avg_transactions_quarter
FROM AgeGroups ag
JOIN QuarterlyData qd ON ag.agegroup = qd.agegroup
GROUP BY ag.agegroup;