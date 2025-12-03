WITH fb_complete AS (
SELECT * FROM facebook_ads_basic_daily fabd
JOIN facebook_campaign fbcamp ON fabd.campaign_id = fbcamp.campaign_id
JOIN facebook_adset fbadset ON fabd.adset_id = fbadset.adset_id),
ads_combined AS(SELECT ad_date, 'facebook' source, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM fb_complete
UNION ALL
SELECT ad_date, 'google' source, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM google_ads_basic_daily),
daily_adset AS (
SELECT ad_date, adset_name FROM ads_combined
GROUP BY ad_date, adset_name
ORDER BY ad_date),
streak_data AS (
SELECT ad_date, adset_name, LAG(ad_date) OVER (PARTITION BY adset_name ORDER BY ad_date) AS prev_ad_date FROM daily_adset),
streak_id_data AS (
SELECT adset_name, ad_date, SUM(CASE WHEN ad_date - prev_ad_date > 1 THEN 1 ELSE 0 END) OVER (PARTITION BY adset_name ORDER BY ad_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + 1 AS streak_id FROM streak_data),
streak_lengths AS (
SELECT adset_name, streak_id, COUNT(*) AS streak_length FROM streak_id_data
GROUP BY adset_name, streak_id)
SELECT
	adset_name,
	MAX(streak_length) AS longest_streak
FROM
	streak_lengths
GROUP BY
	adset_name
ORDER BY
	longest_streak DESC
LIMIT 1
