-- "Essential Contacts API" should be Enabled and requires "Essential Contacts Viewer" at Organization level.
with categories as (
  select
    name,
    title,
    organization_id,
    notificationtype
  from
    gcp_organization,
    jsonb_array_elements(essential_contacts) as ec,
    jsonb_array_elements_text(ec -> 'notificationCategorySubscriptions') as notificationtype
)
select
  -- Required Columns
  name resource,
  case
    when jsonb_array_length('["LEGAL", "SECURITY", "SUSPENSION", "TECHNICAL", "TECHNICAL_INCIDENTS"]'::jsonb - array_agg(notificationtype)) = 0 then 'ok'
    when to_jsonb(array_agg(notificationtype)) @> '["ALL"]'::jsonb then 'ok'
    else 'alarm'
  end status,
  case
    when jsonb_array_length('["LEGAL", "SECURITY", "SUSPENSION", "TECHNICAL", "TECHNICAL_INCIDENTS"]'::jsonb - array_agg(notificationtype)) = 0
      then title || ' essential contacts are configured.'
    when to_jsonb(array_agg(notificationtype)) @> '["ALL"]'::jsonb
      then title || ' essential contacts are configured.'
    else title || ' essential contacts are not configured.'
  end reason,
  -- Additional Dimensions
  organization_id
from
  categories
group by
  name,
  title,
  organization_id;