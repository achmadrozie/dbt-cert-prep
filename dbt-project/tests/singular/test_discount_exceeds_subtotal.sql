select order_id
from {{ ref( 'stg_zomato__order') }}
where subtotal < discount