-- Recompute weekly_return a different way and compare.
-- The model takes the last adjusted close of each week and divides by last week's.
-- This test chains daily returns instead: the product of (1 + daily return) over a week's
-- trading days equals the close-to-close weekly return. A wrong formula (for example mixing
-- adjusted and unadjusted prices, which the earlier version did) fails here, while a range
-- test on weekly_return would let it through.
with daily as (
    select
        company_ticker,
        date_trunc('week', market_date) as week_start,
        ln(adj_closing_price
           / lag(adj_closing_price) over (partition by company_ticker order by market_date)) as daily_log_return
    from {{ ref('stg_sp500_raw__stocks') }}
),

weekly as (
    select
        company_ticker,
        week_start,
        (exp(sum(daily_log_return)) - 1) * 100 as weekly_return_check
    from daily
    group by company_ticker, week_start
),

model as (
    select
        c.company_ticker,
        f.stock_week_start_date,
        f.weekly_return
    from {{ ref('fct_weekly_returns') }} f
    inner join {{ ref('dim_companies') }} c
        on c.company_key = f.company_key
    where f.weekly_return is not null
)

select
    m.company_ticker,
    m.stock_week_start_date,
    m.weekly_return,
    w.weekly_return_check
from model m
left join weekly w
    on w.company_ticker = m.company_ticker
   and w.week_start = m.stock_week_start_date
where w.weekly_return_check is null
   or abs(m.weekly_return - w.weekly_return_check) > 1e-6
