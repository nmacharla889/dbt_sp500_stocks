{{ config(
    materialized = 'incremental',
    unique_key = 'weekly_return_key',
    incremental_strategy = 'merge'
) }}

with companies as (
    select company_key, 
    company_ticker, 
    market_cap_bucket from {{ ref('dim_companies') }}
),
index_weekly as (
    select 
    date_trunc('week', index_value_date) as index_week_start_date,
    avg(index_value) as avg_index_value,
    sum(index_value) as sum_index_value,
    min(index_value) as min_index_value,
    max(index_value) as max_index_value
    from {{ ref('stg_sp500_raw__index') }}
    group by date_trunc('week', index_value_date)
),
stocks_daily as (
    select
        market_date,
        company_ticker,
        opening_price,
        adj_closing_price,
        lowest_price,
        highest_price,
        volume_traded,
        date_trunc('week', market_date) as week_start,
        first_value(opening_price) over (partition by company_ticker, date_trunc('week', market_date) order by market_date) as week_opening_price,
        last_value(adj_closing_price) over (partition by company_ticker, date_trunc('week', market_date) order by market_date rows between unbounded preceding and unbounded following) as week_closing_price
    from {{ ref('stg_sp500_raw__stocks') }}
    {% if is_incremental() %}
    where date_trunc('week', market_date) > (select max(stock_week_start_date) from {{ this }})
    {% endif %}
),
stocks as (
    select
        {{ dbt_utils.generate_surrogate_key(['week_start', 'company_ticker']) }} as weekly_return_key,
        week_start as stock_week_start_date,
        company_ticker,
        min(lowest_price) as week_lowest_price,
        max(highest_price) as week_highest_price,
        min(week_opening_price) as week_opening_price,
        min(week_closing_price) as week_closing_price,
        avg(adj_closing_price) as avg_stock_price,
        sum(volume_traded) as total_volume_traded
    from stocks_daily
    group by week_start, company_ticker
)

select 
c.company_key,
c.market_cap_bucket,
s.weekly_return_key,
s.stock_week_start_date,
s.week_lowest_price,
s.week_highest_price,
s.avg_stock_price,
s.total_volume_traded,
i.index_week_start_date,
i.avg_index_value,
i.sum_index_value,
i.min_index_value,
i.max_index_value,
s.week_opening_price,
s.week_closing_price,
(s.week_closing_price - s.week_opening_price) / s.week_opening_price * 100 as weekly_return
from
companies c join stocks s on c.company_ticker = s.company_ticker
join index_weekly i on s.stock_week_start_date = i.index_week_start_date
