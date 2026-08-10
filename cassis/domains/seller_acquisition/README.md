---
type: Domain
title: Seller acquisition
description: 'Marketing qualified leads and closed deals: how Stallora wins new sellers. Bridges to marketplace sellers.'
---

Prospective sellers enter as marketing qualified leads; the sales team closes some of them into deals; a closed deal creates a seller on the marketplace. This is the seller side only; there is no buyer-acquisition funnel in the data (buyers simply appear as customers placing orders).

## How sellers are acquired

1. A prospective seller signs up through a landing page and becomes a marketing qualified lead.
2. A sales development representative contacts the lead, confirms information and schedules a consultation.
3. A sales representative runs the consultation and either closes the deal or loses it.
4. The signed lead becomes a seller, builds a catalog, and their products are published on the marketplace.

## Tables

- **MARKETING_QUALIFIED_LEADS**: one row per lead (id, first contact date, landing page, acquisition channel).
- **CLOSED_DEALS**: one row per won deal, carrying the declared seller profile at acquisition (segment, type) and the sales reps who handled it.
- **FCT_SELLER_ACQUISITION**: the curated channel-grain rollup (leads, closed deals, conversion rate, average days to close per channel).

Classification axes, value lists, sparsity and date ranges live on the table and column descriptions: read them before writing SQL.

## Joining acquisition to the marketplace

The only bridge is CLOSED_DEALS.SELLER_ID to SELLERS.SELLER_ID, and it is partial: only about 4,560 of the 10,104 closed-deal sellers appear in the marketplace tables (different sampling windows). State this caveat whenever combining acquisition and marketplace data.

<!-- cassis:nav:begin (generated, do not edit) -->

## Tables
- [STALLORA.CLOSED_DEALS](../../tables/STALLORA/CLOSED_DEALS.yml)
- [STALLORA.FCT_SELLER_ACQUISITION](../../tables/STALLORA/FCT_SELLER_ACQUISITION.yml)
- [STALLORA.MARKETING_QUALIFIED_LEADS](../../tables/STALLORA/MARKETING_QUALIFIED_LEADS.yml)

## Metrics
- [Lead-to-deal conversion rate](../../metrics/lead_to_deal_conversion_rate.yml)
<!-- cassis:nav:end -->
