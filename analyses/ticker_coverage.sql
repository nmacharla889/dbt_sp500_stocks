-- Per-ticker price coverage, one row per company in the index.
-- Rebuilds data/ticker_coverage.csv, which the notebook reads in section 2.
-- Run: dbt compile --select ticker_coverage --profiles-dir .
-- then run the compiled SQL (target/compiled/...) in Databricks and export the result to data/ticker_coverage.csv.
with prices as (
    select
        symbol,
        count(`open`) as price_days,
        min(case when `open` is not null then date end) as first_price_date,
        max(case when `open` is not null then date end) as last_price_date
    from {{ source('sp500_raw', 'sp500_stocks') }}
    group by symbol
)
select
    c.symbol as company_ticker,
    c.sector as business_sector,
    c.weight as index_weight,
    coalesce(p.price_days, 0) as price_days,
    p.first_price_date,
    p.last_price_date
from {{ ref('sp500_companies') }} c
left join prices p
    on p.symbol = c.symbol
order by c.weight desc
