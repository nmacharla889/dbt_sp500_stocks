with source as (

    select * from {{ source('sp500_raw', 'sp500_stocks') }}

),

renamed as (

    select
        date as market_date,
        symbol as company_ticker,
        adj_close as adj_closing_price,
        `close` as closing_price,
        high as highest_price,
        low as lowest_price,
        `open` as opening_price,
        volume as volume_traded

    from source
 WHERE `open` IS NOT NULL
)

select * from renamed