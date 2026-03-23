SELECT * FROM funnel;

--Where are users dropping off in the funnel?
/*Funnel in Correct Order*/
SELECT event,
COUNT(*) AS users
FROM funnel
GROUP BY event
ORDER BY 
CASE 
WHEN event = 'Browse' THEN 1
WHEN event = 'Add to Cart' THEN 2
WHEN event = 'Checkout' THEN 3
WHEN event = 'Purchase' THEN 4
END;
/*according to the funnel shown 
most customers drop off in the last stage which is 
checkout & purchase*/

--Which channels bring high-quality leads?

SELECT channel,
COUNT(*) FILTER (WHERE event='Purchase') AS purchases,
SUM(revenue) AS total_revenue
FROM funnel
GROUP BY channel
ORDER BY purchases DESC;
/*google ads are the main reason behind the high lead to the customers and users 
Social Media and Email also perform well with similar conversions.*/

--How can conversion rates be improved?
/*Overall Conversion Rate*/
SELECT 
COUNT(DISTINCT CASE WHEN event='Purchase' THEN user_id END) * 100.0 /
COUNT(DISTINCT CASE WHEN event='Browse' THEN user_id END) 
AS conversion_rate_percentage
FROM funnel;

/*Conversion Rate by Channel*/
SELECT 
channel,
COUNT(DISTINCT CASE WHEN event='Purchase' THEN user_id END) AS purchases,
COUNT(DISTINCT user_id) AS total_users,
COUNT(DISTINCT CASE WHEN event='Purchase' THEN user_id END) * 100.0 /
COUNT(DISTINCT user_id) AS conversion_rate
FROM funnel
GROUP BY channel
ORDER BY conversion_rate DESC;
/*1. Simplify the Checkout Process
2. Improve Payment Experience
3. Optimize High-Performing Channels*/

--Which stages need optimization?
WITH stage_counts AS (
    SELECT 
        event AS stage,
        COUNT(DISTINCT user_id) AS users
    FROM funnel
    GROUP BY event
),
ordered_stages AS (
    SELECT 
        stage,
        users,
        CASE
            WHEN stage = 'Browse' THEN 1
            WHEN stage = 'Add to Cart' THEN 2
            WHEN stage = 'Checkout' THEN 3
            WHEN stage = 'Purchase' THEN 4
        END AS stage_order
    FROM stage_counts
)
SELECT 
    stage,
    users,
    LAG(users) OVER (ORDER BY stage_order) - users AS drop_off_from_previous_stage
FROM ordered_stages
ORDER BY stage_order;
/*1.Checkout Stage : Improve the Add to Cart
2.Purchase : Reduce Checkout[Offer multiple payment options (UPI, cards, wallets)]*/