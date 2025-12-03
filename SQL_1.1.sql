WITH fb_complete AS (
SELECT * FROM facebook_ads_basic_daily fabd
JOIN facebook_campaign fbcamp ON fabd.campaign_id = fbcamp.campaign_id
JOIN facebook_adset fbadset ON fabd.adset_id = fbadset.adset_id),
ads_combined AS(SELECT ad_date, 'facebook' SOURCE, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM fb_complete
UNION ALL
SELECT ad_date, 'google' SOURCE, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM google_ads_basic_daily)
SELECT
	ad_date,
	SOURCE,
	AVG(spend) average_spend,
	MAX(spend) max_spend,
	MIN(spend) min_spend
FROM
	ads_combined
GROUP BY
	ad_date,
	SOURCE
ORDER BY
	ad_date,
	SOURCE
