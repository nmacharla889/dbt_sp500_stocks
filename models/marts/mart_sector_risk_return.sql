with base as (
    select
        business_sector,
        ticker_count,
        ln(1 + sector_weekly_return) as log_return,
        case
            when week_start_date < '2015-01-01' then '2010-2014'
            when week_start_date < '2020-01-01' then '2015-2019'
            else '2020-2024'
        end as sub_period
    from {{ ref('fct_sector_weekly_returns') }}
    where week_start_date >= '2010-01-01'
      and week_start_date <  '2025-01-01'
),
by_period as (
    select business_sector, sub_period,
           count(*) as weeks,
           round(avg(ticker_count), 0) as avg_tickers,
           exp(avg(log_return) * 52) - 1 as annualised_return,
           stddev(log_return) * sqrt(52) as annualised_volatility
    from base
    group by 1, 2
),
full_period as (
    select business_sector, 'full' as sub_period,
           count(*) as weeks,
           round(avg(ticker_count), 0) as avg_tickers,
           exp(avg(log_return) * 52) - 1 as annualised_return,
           stddev(log_return) * sqrt(52) as annualised_volatility
    from base
    group by 1
)
select *,
       annualised_return / nullif(annualised_volatility, 0) as return_per_volatility
from (select * from by_period union all select * from full_period)