{% snapshot sp500_companies_snapshot %}

    {{ config(
        strategy='check',
        unique_key='symbol',
        check_cols=['Shortname', 'Longname', 'Sector', 'Industry', 'City', 'State', 'Country'],
        dbt_valid_to_current='to_date("9999-12-31")',
        hard_deletes='new_record'
    ) }}

    select * from {{ source('sp500_raw', 'sp500_companies') }}

{% endsnapshot %}