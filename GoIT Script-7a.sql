-- Блок об'єднання даних із Facebook та Google Ads
WITH facebook_google_ads_combined AS (
    SELECT 
        ad_date,
        url_parameters,
        spend,
        impressions,
        reach,
        clicks,
        COALESCE(leads, 0) AS leads, -- Замінюємо NULL на 0
        value
    FROM facebook_ads_basic_daily
    UNION ALL
    SELECT 
        ad_date,
        url_parameters,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM google_ads_basic_daily
),
-- Блок обчислення метрик по днях
daily_metrics AS (
    SELECT 
        DATE_TRUNC('month', ad_date) AS ad_month, -- Початок місяця
        CASE
            WHEN LOWER(SUBSTRING(url_parameters, POSITION('campaign=' IN url_parameters) + 9, 30)) = 'nan' THEN NULL
            ELSE LOWER(SUBSTRING(url_parameters, POSITION('campaign=' IN url_parameters) + 9, 30))
        END AS utm_campaign,
        SUM(spend) AS spend_sum,
        SUM(impressions) AS impressions_sum,
        SUM(clicks) AS clicks_sum,
        SUM(value) AS value_sum,
        -- CTR: Уникаємо ділення на 0
        CASE 
            WHEN SUM(impressions) = 0 THEN NULL 
            ELSE ROUND(1000 * SUM(clicks) / SUM(impressions), 2)
        END AS CTR,
        -- CPC
        CASE 
            WHEN SUM(clicks) = 0 THEN NULL 
            ELSE SUM(spend) / SUM(clicks)
        END AS CPC,
        -- CPM
        CASE 
            WHEN SUM(impressions) = 0 THEN NULL 
            ELSE 1000 * SUM(spend) / SUM(impressions)
        END AS CPM,
        -- ROMI
        CASE 
            WHEN SUM(spend) = 0 THEN NULL 
            ELSE 100 * (SUM(value) - SUM(spend)) / SUM(spend)
        END AS ROMI
    FROM facebook_google_ads_combined
    WHERE ad_date IS NOT NULL
    GROUP BY ad_date, utm_campaign
),
-- Блок агрегації метрик по місяцях
monthly_metrics AS (
    SELECT 
        ad_month::date,
        utm_campaign,
        SUM(spend_sum) AS spend_sum_,
        SUM(impressions_sum) AS impressions_sum_,
        SUM(clicks_sum) AS clicks_sum_,
        SUM(value_sum) AS value_sum_,
        -- CTR
        CASE 
            WHEN SUM(impressions_sum) = 0 THEN NULL 
            ELSE ROUND(1000 * SUM(clicks_sum) / SUM(impressions_sum), 2)
        END AS CTR,
        -- CPC
        CASE 
            WHEN SUM(clicks_sum) = 0 THEN NULL 
            ELSE ROUND(SUM(spend_sum) / SUM(clicks_sum), 2)
        END AS CPC,
        -- CPM
        CASE 
            WHEN SUM(impressions_sum) = 0 THEN NULL 
            ELSE ROUND(1000 * SUM(spend_sum) / SUM(impressions_sum), 2)
        END AS CPM,
        -- ROMI
        CASE 
            WHEN SUM(spend_sum) = 0 THEN NULL 
            ELSE ROUND(100 * (SUM(value_sum) - SUM(spend_sum)) / SUM(spend_sum), 2)
        END AS ROMI
    FROM daily_metrics
    GROUP BY ad_month, utm_campaign
)
-- Фінальний запит з розрахунком динаміки метрик
SELECT 
    *,
    -- Динаміка CTR
    ROUND(100 * (CTR / LAG(CTR, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) - 1), 2) AS diff_CTR,
    -- Динаміка CPM
    ROUND(100 * (CPM / LAG(CPM, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) - 1), 2) AS diff_CPM,
    -- Динаміка ROMI
    ROUND(100 * (ROMI / LAG(ROMI, 1) OVER (PARTITION BY utm_campaign ORDER BY ad_month) - 1), 2) AS diff_ROMI
FROM monthly_metrics;
