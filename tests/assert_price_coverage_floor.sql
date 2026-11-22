-- Price coverage guard on the raw stock table.
-- The Kaggle source has prices for only 172 of 502 tickers: the other 330 are empty on every day,
-- most likely from failed downloads when the dataset was last updated (see README, Known Limitations).
-- This test fails if a reload brings in a file with even fewer priced tickers.
-- Raise the floor if the prices are re-pulled with full coverage.
with coverage as (
    select count(distinct symbol) as tickers_with_prices
    from {{ source('sp500_raw', 'sp500_stocks') }}
    where `open` is not null
)
select tickers_with_prices
from coverage
where tickers_with_prices < 172
