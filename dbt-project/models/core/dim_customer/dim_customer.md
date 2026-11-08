{% docs dim_customer %}
Customer dimension with one row per customer. Selects staged user attributes and assigns an age segment from the customer's age.
{% enddocs %}

{% docs dim_customer_customer_id %}
Unique identifier of the customer, derived from the source user ID.
{% enddocs %}

{% docs dim_customer_customer_name %}
Customer name from the staged users model.
{% enddocs %}

{% docs dim_customer_email %}
Customer email, converted to lowercase during staging.
{% enddocs %}

{% docs dim_customer_age %}
Customer age converted to a number during staging. Invalid or missing source values become null.
{% enddocs %}

{% docs dim_customer_age_segment %}
Age category based on `age`: under 25 is Gen Z; 25-39 is Millennial; 40-54 is Gen X; 55 or older is Boomer; null is Unknown.
{% enddocs %}

{% docs dim_customer_gender %}
Gender value from the source user record.
{% enddocs %}

{% docs dim_customer_marital_status %}
Marital status value from the source user record.
{% enddocs %}

{% docs dim_customer_occupation %}
Occupation value from the source user record.
{% enddocs %}

{% docs dim_customer_income_band %}
Income band from the source `monthly_income` field.
{% enddocs %}

{% docs dim_customer_education %}
Educational qualification from the source user record.
{% enddocs %}

{% docs dim_customer_family_size %}
Family size converted to a number during staging. Invalid or missing source values become null.
{% enddocs %}
