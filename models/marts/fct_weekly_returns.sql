{{ config(
    materialized = 'incremental',
    unique_key = 'weekly_return_key',
    incremental_strategy = 'merge'
) }}

{#-
    Grain: one row per stock per week (weeks start on Monday), from 2010.
    weekly_return is close to close on adjusted prices, in percent:
        this week's last adjusted close / last week's last adjusted close - 1.
    It is null in each stock's first week, because there is no earlier close.
    Index columns are null before 2014-12-22, because the index source starts then.

    Incremental runs re-read the last LOOKBACK_WEEKS weeks so the return, the 4-week average
    and the 12-week volatility of new weeks see a full window, then keep only the new weeks.
-#}
{% set lookback_weeks = 14 %}

with companies as (
    select
        company_key,
        company_ticker,
        market_cap_bucket
    from {{ ref('dim_companies') }}
),

index_weekly as (
    select
        date_trunc('week', index_value_date) as index_week_start_date,
        avg(index_value) as avg_index_value,
        min(index_value) as min_index_value,
        max(index_value) as max_index_value
    from {{ ref('stg_sp500_raw__index') }}
    group by date_trunc('week', index_value_date)
),

stocks_daily as (
    select *
    from {{ ref('stg_sp500_raw__stocks') }}
    {% if is_incremental() %}
    where market_date >= (
        select date_sub(max(stock_week_start_date), 7 * {{ lookback_weeks }}) from {{ this }}
    )
    {% endif %}
),

stocks as (
    select
        {{ dbt_utils.generate_surrogate_key(["date_trunc('week', market_date)", 'company_ticker']) }} as weekly_return_key,
        date_trunc('week', market_date) as stock_week_start_date,
        company_ticker,
        min(lowest_price) as week_lowest_price,
        max(highest_price) as week_highest_price,
        min_by(opening_price, market_date) as week_opening_price,      -- unadjusted open, first trading day
        max_by(adj_closing_price, market_date) as week_closing_price,  -- adjusted close, last trading day
        avg(adj_closing_price) as avg_stock_price,
        sum(volume_traded) as total_volume_traded
    from stocks_daily
    group by date_trunc('week', market_date), company_ticker
),

stocks_with_metrics as (
    select
        *,
        (week_closing_price
            / lag(week_closing_price) over (partition by company_ticker order by stock_week_start_date)
            - 1) * 100 as weekly_return,
        {{ rolling_avg('week_closing_price', 'company_ticker', 'stock_week_start_date', 4) }} as rolling_4w_avg_price,
        {{ calc_volatility('week_closing_price', 'company_ticker', 'stock_week_start_date', 12) }} as rolling_12w_volatility
    from stocks
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
    i.min_index_value,
    i.max_index_value,
    s.week_opening_price,
    s.week_closing_price,
    s.weekly_return,
    s.rolling_4w_avg_price,
    s.rolling_12w_volatility
from stocks_with_metrics s
inner join companies c
    on c.company_ticker = s.company_ticker
left join index_weekly i
    on i.index_week_start_date = s.stock_week_start_date
{% if is_incremental() %}
where s.stock_week_start_date > (select max(stock_week_start_date) from {{ this }})
{% endif %}
