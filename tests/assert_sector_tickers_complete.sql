-- Fails if the model never reaches the full number of tickers (loss)
-- or exceeds it (duplication).
with expected as (
    select count(distinct s.company_ticker) as n
    from {{ ref('stg_sp500_raw__stocks') }} s
    inner join {{ ref('dim_companies') }} c
        on s.company_ticker = c.company_ticker
    where c.business_sector is not null
),
actual as (
    select max(weekly_total) as n_max
    from (
        select week_start_date, sum(ticker_count) as weekly_total
        from {{ ref('fct_sector_weekly_returns') }}
        group by week_start_date
    )
)
select *
from expected, actual
where actual.n_max <> expected.n