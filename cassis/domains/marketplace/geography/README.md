---
type: Domain
title: Geography
description: Countries, market concentration, and where coordinates live.
---

# Geography

## Countries

Sellers and customers carry a postal-code prefix, a city and a country. Stallora operates across five European markets: Spain (ES), Italy (IT), the Netherlands (NL), Germany (DE) and France (FR).

Activity is concentrated in Spain: ES accounts for roughly 56% of customers and 69% of sellers, with Italy a distant second. Treat ES as the home market when reading geographic breakdowns.

## Coordinates

Area-level coordinates come from the GEOLOCATION table, which has many duplicate rows per postal-code prefix and must be collapsed to one row per prefix before joining (GROUP BY the prefix, AVG latitude and longitude in a subquery). Prefer the seller/customer city and country columns over GEOLOCATION's, which can disagree.
