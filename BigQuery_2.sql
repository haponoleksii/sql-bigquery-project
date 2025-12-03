SELECT 
  TIMESTAMP_MICROS(event_timestamp) event_timestamp, 
  user_pseudo_id, 
  (select value.int_value from dataset.event_params where key = 'ga_session_id') session_id, 
  event_name, 
  geo.country country, 
  device.category device_category, 
  traffic_source.source source, 
  traffic_source.medium medium, 
  traffic_source.name campaign 
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` dataset
WHERE event_name IN ('session_start','view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase') AND _table_suffix LIKE '2021%'
ORDER BY event_timestamp
