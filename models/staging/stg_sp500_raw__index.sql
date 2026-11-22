with source as (

    select * from {{ source('sp500_raw', 'sp500_index') }}

),

renamed as (

    select
        date as index_value_date,
        `S&P500` as index_value

    from source

)

select * from renamed
