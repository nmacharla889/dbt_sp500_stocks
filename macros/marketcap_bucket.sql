{%- macro marketcap_bucket(market_capitalization) -%}
    case
        when {{ market_capitalization }} < 20000000000 then 'large_cap'
        when {{ market_capitalization }} >= 20000000000 and {{ market_capitalization }} < 75000000000 then 'big_cap'
        when {{ market_capitalization }} >= 75000000000 and {{ market_capitalization }} < 200000000000 then 'mega_cap'
        else 'super_mega_cap'
    end

{%- endmacro -%}