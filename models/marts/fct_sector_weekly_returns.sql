with weekly_close as (
    select
        company_ticker,
        date_trunc('week', market_date) as week_start_date,
        max_by(adj_closing_price, market_date) as week_close_price
    from {{ ref('stg_sp500_raw__stocks') }}
    group by 1, 2
),
stock_returns as (
    select
        company_ticker,
        week_start_date,
        week_close_price
            / lag(week_close_price) over (
                partition by company_ticker order by week_start_date
            ) - 1 as stock_weekly_return
    from weekly_close
),
with_sector as (
    select c.business_sector, r.company_ticker, r.week_start_date, r.stock_weekly_return
    from stock_returns r
    inner join {{ ref('dim_companies') }} c
        on r.company_ticker = c.company_ticker
    where r.stock_weekly_return is not null
      and c.business_sector is not null
)
select
    business_sector,
    week_start_date,
    avg(stock_weekly_return) as sector_weekly_return,
    count(*) as ticker_count
from with_sector
group by 1, 2