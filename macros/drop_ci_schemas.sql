{#-
    Drops the schemas a CI run created. Called by the CI workflow after every run, pass or fail:
        dbt run-operation drop_ci_schemas --profiles-dir ci
    Guard: refuses to run unless the target is "ci" and the schema starts with "sp500_ci",
    so it can never drop the dev schemas (sp500_dev, sp500_dev_raw, ...).
-#}
{% macro drop_ci_schemas() %}
    {% if target.name != 'ci' or not target.schema.startswith('sp500_ci') %}
        {{ exceptions.raise_compiler_error(
            "drop_ci_schemas only runs on the ci target with an sp500_ci* schema. Got target '"
            ~ target.name ~ "', schema '" ~ target.schema ~ "'."
        ) }}
    {% endif %}

    {% for suffix in ['', '_raw', '_stg', '_marts'] %}
        {% set schema_name = target.database ~ '.' ~ target.schema ~ suffix %}
        {% do log('Dropping schema ' ~ schema_name, info=true) %}
        {% do run_query('drop schema if exists ' ~ schema_name ~ ' cascade') %}
    {% endfor %}
{% endmacro %}
