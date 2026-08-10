---
type: Domain
title: Marketplace
description: Orders, order items, products, sellers, customers, payments, reviews, geolocation, and the curated marketplace
  rollups.
---

The transactional heart of Stallora: customers place orders; an order contains one or more order items; each order item is one product sold and fulfilled by one seller.

## Tables and routing

- **ORDERS** is the hub: items, payments, reviews and customers all join through it. One row per order, carrying status and the delivery timestamps; money does NOT live here.
- **ORDER_ITEMS** is the sale grain (one row per order line). PRICE carries business volume; FREIGHT_VALUE is shipping. Use this table for any breakdown of sales by product, category, seller or geography.
- **PRODUCTS** describe what is sold; **DIM_CATEGORY** groups the catalog category into a department.
- **SELLERS** and **CUSTOMERS** describe who sells and who buys. Customers are per-order records; the real person is CUSTOMER_UNIQUE_ID.
- **ORDER_PAYMENTS** and **ORDER_REVIEWS** hang off orders.
- **GEOLOCATION** maps postal-code prefixes to coordinates; dedup it before any join (see [geography](marketplace/geography)).

## Curated rollups

- **FCT_ORDERS**: one row per order, precomputing delivered/on-time flags, delivery days, order value and the per-order review score. The home for order-level metrics.
- **DIM_SELLER**: one row per seller with lifetime rollups (delivered orders, GMV, on-time rate, average review, average delivery days).
- **FCT_SALES_MONTHLY**: GMV, orders and AOV by month, for trends.

Each table carries its own rules on the table and column descriptions (grain, value lists, dedup keys, data gaps, lineage): read them before writing SQL.

## Topic docs

- [Measuring sales](marketplace/measuring-sales): where money lives, the delivered-only rule, BV/GMV vocabulary, counting rules.
- [Geography](marketplace/geography): countries, market concentration, where coordinates live.
- [Seller performance](marketplace/seller-performance): the per-seller signals available in the data.

<!-- cassis:nav:begin (generated, do not edit) -->

## Tables
- [STALLORA.CUSTOMERS](../../tables/STALLORA/CUSTOMERS.yml)
- [STALLORA.DIM_CATEGORY](../../tables/STALLORA/DIM_CATEGORY.yml)
- [STALLORA.DIM_SELLER](../../tables/STALLORA/DIM_SELLER.yml)
- [STALLORA.FCT_ORDERS](../../tables/STALLORA/FCT_ORDERS.yml)
- [STALLORA.FCT_SALES_MONTHLY](../../tables/STALLORA/FCT_SALES_MONTHLY.yml)
- [STALLORA.GEOLOCATION](../../tables/STALLORA/GEOLOCATION.yml)
- [STALLORA.ORDERS](../../tables/STALLORA/ORDERS.yml)
- [STALLORA.ORDER_ITEMS](../../tables/STALLORA/ORDER_ITEMS.yml)
- [STALLORA.ORDER_PAYMENTS](../../tables/STALLORA/ORDER_PAYMENTS.yml)
- [STALLORA.ORDER_REVIEWS](../../tables/STALLORA/ORDER_REVIEWS.yml)
- [STALLORA.PRODUCTS](../../tables/STALLORA/PRODUCTS.yml)
- [STALLORA.SELLERS](../../tables/STALLORA/SELLERS.yml)

## Metrics
- [Active sellers](../../metrics/active_sellers.yml)
- [Average delivery time](../../metrics/average_delivery_time.yml)
- [Average order value (AOV)](../../metrics/average_order_value.yml)
- [Average review score](../../metrics/average_review_score.yml)
- [Business volume (BV)](../../metrics/business_volume.yml)
- [Late delivery rate](../../metrics/late_delivery_rate.yml)
- [On-time delivery rate](../../metrics/on_time_delivery_rate.yml)
- [Order cancellation rate](../../metrics/order_cancellation_rate.yml)
- [Repeat customer rate](../../metrics/repeat_customer_rate.yml)
<!-- cassis:nav:end -->
