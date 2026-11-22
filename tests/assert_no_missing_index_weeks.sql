-- Every stock week inside the index's date range must have an index row.
-- Before 2014-12-22 the index columns are null on purpose (the index source starts then),
-- so only weeks from the index's first week to its last date are checked.
-- (The earlier version inner-joined the index and then looked for missing index rows,
-- which can never return a row, so it could not fail.)
with index_range as (
    select
        date_trunc('week', min(index_value_date)) as first_index_week,
        max(index_value_date) as last_index_date
    from {{ ref('stg_sp500_raw__index') }}
)
select
    f.stock_week_start_date,
    f.company_key
from {{ ref('fct_weekly_returns') }} f
cross join index_range r
where f.stock_week_start_date >= r.first_index_week
  and f.stock_week_start_date <= r.last_index_date
  and f.index_week_start_date is null
