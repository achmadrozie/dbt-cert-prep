{% docs int_order_financials %}
One row per order. Keeps source financial components, recalculates sales as subtotal minus discount plus delivery fee and GST, and exposes the reconciliation delta. `delivered_sales_amount` is zero for non-delivered orders.
{% enddocs %}
