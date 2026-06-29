# Olist E-Commerce Analysis

End-to-end data analysis project using the [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The project covers SQL-based data exploration in PostgreSQL and an interactive Power BI dashboard built on top of the cleaned data.
![Olist Dashboard](images/dashboard.png)
## Project Overview

This project analyzes order, customer, product, and review data from Olist, a Brazilian e-commerce marketplace, to answer key business questions:

- How has monthly revenue and order volume trended over time?
- Which product categories generate the most revenue?
- How satisfied are customers, based on review scores?
- How long does delivery typically take, and how does it vary month to month?
- How is revenue distributed geographically across Brazilian states?

## Tools Used

- **PostgreSQL** (via pgAdmin 4) — data storage, cleaning, and querying
- **Power BI Desktop** — data modeling, DAX measures, and dashboard visualization

## Dataset

The dataset consists of multiple relational tables, including:

- `orders` — order status and key timestamps (purchase, approval, delivery)
- `order_items` — items per order, price, and freight value
- `customers` — customer IDs and location
- `products` — product category and attributes
- `reviews` — customer review scores and comments

## SQL Analysis (`/sql/olist_analysis.sql`)

Key queries developed in PostgreSQL include:

- **Monthly revenue and order count** — aggregated revenue and distinct order counts by month for delivered orders
- **Top product categories by revenue** — ranked categories by total revenue, filtered to categories exceeding a revenue threshold
- **Customer satisfaction classification** — orders bucketed into Excellent / Good / Neutral / Poor / No Review based on review score, with percentage breakdowns
- **Average delivery time and month-over-month comparison** — average delivery duration per month, using window functions (`LAG`/`LEAD`) to compare against adjacent months

Notable data-cleaning steps handled along the way:
- Corrected a column-order mismatch in the `orders` table caused by a positional (rather than header-matched) CSV import
- Resolved a `WIN1252` vs. `UTF8` encoding conflict when importing the `reviews` table (needed for Portuguese-language review text)
- Cast `text`-typed timestamp columns to proper `timestamp`/`int` types for date and numeric operations

## Power BI Dashboard

The dashboard (`olist_pb.pbix`) includes:

- **KPI cards** — Total Revenue, Total Orders, Average Review Score
- **Monthly revenue table** — month-by-month revenue breakdown with a grand total
- **Revenue trend line chart** — total revenue by month
- **Top categories bar chart** — revenue by product category
- **Geographic map** — total revenue by customer state, with bubble size representing revenue

### Data Model
Relationships are built around `orders` as the central fact table, connected to `order_items`, `customers`, and `reviews` via `order_id`/`customer_id`. Key DAX measures include:

```dax
Total Revenue = SUM(order_items[price])
Total Orders = DISTINCTCOUNT(orders[order_id])
Avg Review Score = AVERAGE(reviews[review_score])
```

## Key Findings

- Revenue grew steadily from early 2017 through mid-2018, with a sharp, notable dip around September 2018.
- A small number of product categories account for a disproportionate share of total revenue.
- Average customer review score sits around 4.1 out of 5, indicating generally positive satisfaction.
- Revenue is concentrated in a handful of states, with São Paulo standing out as the largest contributor.

## Repository Structure

```
data-analyst-portfolio/
└── sql/
    └── olist_analysis.sql
    └── README.md
└── powerbi/
    └── olist_pb.pbix
```

## How to Reproduce

1. Import the Olist dataset CSVs into PostgreSQL, matching columns by header (not position) to avoid misalignment.
2. Run `olist_analysis.sql` to generate the core analysis tables/views.
3. Connect Power BI Desktop to the PostgreSQL database.
4. Build relationships between `orders`, `order_items`, `customers`, and `reviews` on their respective ID fields.
5. Create the DAX measures listed above and build out the visuals.
