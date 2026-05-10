with source as (

    select * from {{ source('sp500_raw', 'sp500_companies') }}

),

renamed as (

    select
        exchange as stock_exchange,
        symbol as company_ticker,
        shortname as company_short_name,
        longname as company_long_name,
        sector as business_sector,
        industry as business_industry,
        currentprice as current_stock_price,
        marketcap as market_capitalization,
        ebitda as ebidta_earnings,
        revenuegrowth as revenue_growth_rate,
        city as headquarters_city,
        "state" as headquarters_state,
        country as headquarters_country,
        fulltimeemployees as fulltime_employees,
        longbusinesssummary as business_summary,
        "weight" as sp500_weight

    from source

)

select * from renamed
