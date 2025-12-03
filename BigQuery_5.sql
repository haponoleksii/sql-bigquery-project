WITH eng_time_stat AS(SELECT 
  user_pseudo_id||CAST((select value.int_value from dataset.event_params where key = 'ga_session_id') AS string) user_session_id,
  COALESCE((SELECT value.int_value FROM dataset.event_params WHERE key = 'engagement_time_msec'), 0) as eng_time,
  COALESCE(
  (SELECT value.int_value FROM dataset.event_params WHERE key = 'session_engaged'),
  CAST((SELECT value.string_value FROM dataset.event_params WHERE key = 'session_engaged') AS int), 0) session_engaged
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` dataset),

purchase_stat AS(SELECT 
  user_pseudo_id||CAST((select value.int_value from dataset.event_params where key = 'ga_session_id') AS string) user_session_id,
  MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchase_event
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as dataset
GROUP BY 1)

SELECT
CORR(t.eng_time, p.purchase_event) time_purch_corr,
CORR(t.session_engaged, p.purchase_event) eng_purch_corr
FROM eng_time_stat t LEFT JOIN purchase_stat p ON t.user_session_id = p.user_session_id
