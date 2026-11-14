

-- analyses/fact_order/audit_fallback_except.sql
select 'only_in_old' as side, count(*) as n
from (select * from {{ ref('fact_order', v=1) }}
      except
      select * from {{ ref('fact_order', v=2) }})
union all
select 'only_in_new', count(*)
from (select * from {{ ref('fact_order', v=2) }}
      except
      select * from {{ ref('fact_order', v=1) }})