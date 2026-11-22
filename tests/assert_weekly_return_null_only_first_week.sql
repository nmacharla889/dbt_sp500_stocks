-- weekly_return needs last week's close, so it is null in each stock's first week.
-- Any other null means a broken calculation, for example an incremental run that did not
-- re-read enough earlier weeks, so a new week has no previous close. (A missing week does not
-- show up here: lag() would use the week before it.)
with weeks as (
    select
        company_key,
        stock_week_start_date,
        weekly_return,
        min(stock_week_start_date) over (partition by company_key) as first_week
    from {{ ref('fct_weekly_returns') }}
)
select *
from weeks
where weekly_return is null
  and stock_week_start_date <> first_week
