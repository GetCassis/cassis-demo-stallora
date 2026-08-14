WITH so AS (
  SELECT DISTINCT oi."SELLER_ID", o."ORDER_ID", o."ORDER_DELIVERED_CUSTOMER_DATE", o."ORDER_ESTIMATED_DELIVERY_DATE"
  FROM "STALLORA"."ORDER_ITEMS" oi
  JOIN "STALLORA"."ORDERS" o ON o."ORDER_ID" = oi."ORDER_ID"
  WHERE o."ORDER_STATUS" = 'delivered'
),
rv AS (
  SELECT "ORDER_ID", AVG("REVIEW_SCORE") AS score
  FROM "STALLORA"."ORDER_REVIEWS"
  GROUP BY 1
),
per AS (
  SELECT s."SELLER_ID",
         COUNT(DISTINCT s."ORDER_ID") AS delivered_orders,
         AVG(CASE WHEN s."ORDER_DELIVERED_CUSTOMER_DATE" IS NOT NULL
                   AND s."ORDER_DELIVERED_CUSTOMER_DATE" <= s."ORDER_ESTIMATED_DELIVERY_DATE"
                  THEN 1 ELSE 0 END) AS on_time_rate,
         AVG(rv.score) AS avg_review
  FROM so s
  LEFT JOIN rv ON rv."ORDER_ID" = s."ORDER_ID"
  GROUP BY 1
)
SELECT COUNT(CASE WHEN delivered_orders >= 5 AND (on_time_rate < 0.85 OR avg_review < 3) THEN 1 END) AS at_risk_sellers
FROM per
