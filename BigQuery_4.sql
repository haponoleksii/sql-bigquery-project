WITH landing_page AS(SELECT
  event_name,
  user_pseudo_id||CAST((select value.int_value from dataset.event_params where key = 'ga_session_id') AS string) user_session_id,
  (SELECT value.string_value FROM dataset.event_params WHERE key = 'page_location') page_location
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` dataset
WHERE event_name = 'session_start' AND _table_suffix LIKE '2020%'),

purchase_event AS(SELECT
event_name,
user_pseudo_id||CAST((select value.int_value from dataset.event_params where key = 'ga_session_id') AS string) user_session_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` dataset
WHERE event_name = 'purchase' AND _table_suffix LIKE '2020%'),

count_data AS(SELECT 
  page_location,
  COUNT(DISTINCT CASE WHEN lp.event_name = 'session_start' THEN lp.user_session_id END) session_count,
  COUNT(DISTINCT CASE WHEN pe.event_name = 'purchase' THEN pe.user_session_id END) purchase_count
FROM landing_page lp LEFT JOIN purchase_event pe ON lp.user_session_id = pe.user_session_id
GROUP BY 1)

SELECT
  page_location page_path,
  session_count, purchase_count,
  purchase_count/session_count conversion_rate 
FROM count_data


