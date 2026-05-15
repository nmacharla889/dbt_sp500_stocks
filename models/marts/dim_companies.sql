  with companies as (

    select * from
        {{ ref('stg_sp500_raw__companies') }}
  ),

renamed as (
  select {{ dbt_utils.generate_surrogate_key(['company_ticker']) }} as company_key,
  stock_exchange,
  company_ticker,
  company_short_name,
  company_long_name,  
  business_sector,
  business_industry,
  current_stock_price,
  market_capitalization,
  {{ marketcap_bucket('market_capitalization') }} as market_cap_bucket,
  ebidta_earnings,
  revenue_growth_rate,
  headquarters_city,
  headquarters_state,
  headquarters_country,
  fulltime_employees,
  sp500_weight
from companies

)

select * from renamed

