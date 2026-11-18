with ordered as (
    select business_sector, week_start_date,
           datediff(week_start_date,
                    lag(week_start_date) over (
                        partition by business_sector
                        order by week_start_date)) as gap_days
    from {{ ref('fct_sector_weekly_returns') }}
)
select * from ordered where gap_days > 7