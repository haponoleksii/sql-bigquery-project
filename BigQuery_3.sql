WITH init_data AS(SELECT 
  EXTRACT(DATE FROM TIMESTAMP_MICROS(event_timestamp)) event_date, 
  event_name, 
  user_pseudo_id||CAST((select value.int_value from dataset.event_params where key = 'ga_session_id') AS string) user_session_id, 
  traffic_source.source source, 
  traffic_source.medium medium, 
  traffic_source.name campaign 
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` dataset
WHERE event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase')),

count_data AS(SELECT 
  event_date,
  source, 
  medium, 
  campaign,
  COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN user_session_id END) session_count,
  COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) add_to_cart_count,
  COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) begin_checkout_count,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) purchase_count
FROM init_data
GROUP BY 1,2,3,4)

SELECT
  event_date,
  source, 
  medium, 
  campaign,
  session_count user_sessions_count, 
  add_to_cart_count/session_count visit_to_cart, 
  begin_checkout_count/session_count visit_to_checkout, 
  purchase_count/session_count visit_to_purchase  
FROM count_data
