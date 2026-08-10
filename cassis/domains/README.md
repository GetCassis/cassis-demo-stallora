---
type: Domain
title: Stallora marketplace
description: Global context for the Stallora pan-European marketplace dataset.
---

Stallora is a pan-European online marketplace where independent sellers list products across many categories (home and garden, electronics, fashion, health and beauty, sports and leisure, and more) and customers across Europe place orders. An order contains one or more order items, and each order item is one product sold and fulfilled by a single seller.

## How the data is organized

Two connected domains:

- [marketplace](marketplace): the transactional core (orders, order items, products, sellers, customers, payments, reviews, geolocation) plus curated rollup tables.
- [seller_acquisition](seller_acquisition): how new sellers are won (marketing qualified leads and closed deals).

The only bridge between the two domains is closed deal to seller. The marketplace domain carries topic docs as child domains; open them with get() like any domain path. Table-level rules (grain, dedup keys, value lists, data gaps, lineage) live on the tables and columns themselves.

## Raw vs curated tables

The raw transactional tables are the source of truth. Four curated rollup tables are pre-aggregated for common questions and carry their lineage in the table description: FCT_ORDERS (one row per order), DIM_SELLER (one row per seller), FCT_SALES_MONTHLY (one row per month) and FCT_SELLER_ACQUISITION (one row per acquisition channel). Prefer the table whose grain matches the question; raw and curated reconcile to the same governed metrics.

## Rules that apply to every question

- Monetary amounts are in EUR. Always render amounts with the EUR currency (the euro symbol or 'EUR'); never use '$' or any other currency symbol.
- Realized sales are delivered orders: unless the user asks otherwise, restrict revenue, sales and business-volume questions to orders whose status is 'delivered'.
- A customer id is issued per order, so the same real person appears under many customer ids over time. Count distinct customers by CUSTOMER_UNIQUE_ID, never by the per-order CUSTOMER_ID.
- The data is a static historical snapshot spanning about two years of orders, up to the most recent order date in the data. Measure any recency window (e.g. 'the last 90 days') relative to the latest order date in the data, not today's calendar date; there is no data beyond it.

## Governed metrics

Business volume (BV / GMV), average order value (AOV), on-time delivery rate, late delivery rate, order cancellation rate, average delivery time, average review score, repeat customer rate, active sellers and lead-to-deal conversion rate are governed metrics. When a question uses one of these terms, use the metric definition exactly; do not re-derive or approximate it.
