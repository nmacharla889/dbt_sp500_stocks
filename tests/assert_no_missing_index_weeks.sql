select f.stock_week_start_date from
{{ ref('fct_weekly_returns')}} f
join {{ref('stg_sp500_raw__index')}} i
on f.stock_week_start_date = date_trunc('week', i.index_value_date)
where i.index_value_date is null