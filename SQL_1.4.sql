WITH fb_complete AS (
SELECT * FROM facebook_ads_basic_daily fabd
JOIN facebook_campaign fbcamp ON fabd.campaign_id = fbcamp.campaign_id
JOIN facebook_adset fbadset ON fabd.adset_id = fbadset.adset_id),
ads_combined AS(SELECT ad_date, 'facebook' SOURCE, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM fb_complete
UNION ALL
SELECT ad_date, 'google' SOURCE, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value FROM google_ads_basic_daily)
SELECT
	DATE_TRUNC('months', ad_date)::date ad_month,
	campaign_name,
	SUM(reach) monthly_reach,
	COALESCE(LAG(SUM(reach)) OVER (PARTITION BY campaign_name ORDER BY DATE_TRUNC('months', ad_date)::date), 0) prev_monthly_reach,
	SUM(reach) - COALESCE(LAG(SUM(reach)) OVER (PARTITION BY campaign_name ORDER BY DATE_TRUNC('months', ad_date)::date), 0) reach_change
FROM
	ads_combined
GROUP BY
	ad_month,
	campaign_name
ORDER BY
	reach_change DESC
LIMIT 1
