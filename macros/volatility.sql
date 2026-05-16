{% macro calc_volatility(
    price_col, 
    ticker_col, 
    date_col, 
    window_rows=12
) %}
    STDDEV(
        LN({{ price_col }} / LAG({{ price_col }}, 1) OVER (
            PARTITION BY {{ ticker_col }} 
            ORDER BY {{ date_col }}
        ))
    ) OVER (
        PARTITION BY {{ ticker_col }}
        ORDER BY {{ date_col }}
        ROWS BETWEEN {{ window_rows - 1 }} PRECEDING AND CURRENT ROW
    ) * SQRT(52)
{% endmacro %}