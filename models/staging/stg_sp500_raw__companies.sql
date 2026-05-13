with source as (

    select * from {{ source('sp500_raw', 'sp500_companies') }}

),

renamed as (

    select
        Exchange as stock_exchange,
        Symbol as company_ticker,
        Shortname as company_short_name,
        Longname as company_long_name,
        Sector as business_sector,
        Industry as business_industry,
        Currentprice as current_stock_price,
        Marketcap as market_capitalization,
        Ebitda as ebidta_earnings,
        Revenuegrowth as revenue_growth_rate,
        City as headquarters_city,
        "State" as headquarters_state,
        Country as headquarters_country,
        Fulltimeemployees as fulltime_employees,
        "Weight" as sp500_weight

    from source

)

select * from renamed
