!set outputformat csv
!set showheader false

-- from 5.1 we need to include the schema as well as pump name, and exclude system pumps

select distinct s.object_schema as schema_name
from sys_aem."Pump"."Pump" p
left join sys_fem."Security"."User" u on p."PumpUser" = u."mofId"
join sys_boot.jdbc_metadata.schemas_view_internal s on p."namespace" = s."mofId"
where s.object_catalog = 'LOCALDB'
order by 1;

