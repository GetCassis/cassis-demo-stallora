---
type: Domain
title: Measuring sales
description: Where money lives, the delivered-only rule, BV/GMV vocabulary, and counting rules.
---

# Measuring sales

## Where money lives

Sale amounts live on ORDER_ITEMS, one row per order line: PRICE is the item sale amount, FREIGHT_VALUE the shipping charged on that line. For any breakdown of sales (by product, category, seller, country, time), aggregate PRICE at the item grain. The curated FCT_ORDERS carries the same money pre-summed to one ORDER_VALUE per order, and FCT_SALES_MONTHLY pre-sums GMV by month: use those for order-level and monthly questions. The three reconcile; never sum more than one of them together.

## Realized vs gross

Unless the user explicitly asks otherwise, revenue, sales and business-volume questions cover delivered orders only (use the delivered filter). Freight is excluded from business volume; it is a separate charge.

## Vocabulary

BV, GMV, gross merchandise value, revenue and sales all mean the same thing here: the governed business_volume metric. Average basket questions map to the average_order_value metric. Use the metric definitions exactly; do not re-derive them.

## Counting rules

- Orders: count distinct ORDER_ID.
- People: count distinct CUSTOMER_UNIQUE_ID on CUSTOMERS, never the per-order CUSTOMER_ID. The repeat_customer_rate metric encodes the repeat-buyer rule.
- Cancellations: the order_cancellation_rate metric runs over ALL orders regardless of status, not only delivered ones.

All amounts are in EUR; see the root rules for rendering.
