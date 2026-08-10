---
type: Domain
title: Seller performance
description: The per-seller signals available in the data and how to read them.
---

# Seller performance

The per-seller signals available in the data. They live as columns on DIM_SELLER, one row per seller, rolled up over the seller's delivered orders. Where a signal is also a governed metric, use the metric definition exactly rather than re-deriving it.

## Sales activity

DELIVERED_ORDERS is the count of the seller's distinct delivered orders; GMV is the seller's business volume over those orders; PRODUCTS_SOLD is the number of distinct products the seller has sold. FIRST_SALE_DATE marks when the seller started selling. A seller's window matters: the catalog spans about two years, up to the most recent order date in the data.

## Delivery punctuality

ON_TIME_RATE is the share of the seller's distinct delivered orders that arrived on or before the estimated delivery date, as a fraction from 0 to 1. AVG_DELIVERY_DAYS is the seller's mean days from purchase to delivery.

## Review quality

AVG_REVIEW_SCORE is the seller's average order review score on a 1 to 5 scale, averaged per distinct order. When an order contains items from more than one seller, its score counts toward each of those sellers.

## Acquisition profile

For sellers that came through acquisition, CLOSED_DEALS carries their declared profile (segment, type). The bridge is partial: only about 4,560 of 10,104 closed-deal sellers appear in the marketplace tables.
