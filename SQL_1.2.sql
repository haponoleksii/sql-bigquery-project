WITH fb_complete AS (
SELECT * FROM facebook_ads_basic_daily fabd
JOIN facebook_campaign fbcamp ON fabd.campaign_id = fbcamp.campaign_id
JOIN facebook_adset fbadset ON fabd.adset_id = fbadset.adset_id),
ads_combined AS(SELECT ad_date, 'facebook' SOURCE, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM fb_complete
UNION ALL
SELECT ad_date, 'google' SOURCE, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM google_ads_basic_daily)
SELECT
	ad_date,
	SUM(spend) total_spend,
	SUM(value) total_value,
	SUM(value)::float / SUM(spend)::float romi
FROM
	ads_combined
WHERE
	spend > 0
GROUP BY
	ad_date
ORDER BY
	romi DESC
LIMIT 5
