-- ============================================================
-- Кейс 8: Еженедельный отчёт для тимлида
-- Файл: sql/08_weekly_report.sql
-- База данных: traffic_performance_daily (SQLite / PostgreSQL)
-- ============================================================

-- ----------------------------------------------------------------
-- ПАРАМЕТРЫ: задай нужные даты здесь
-- ----------------------------------------------------------------
-- current_week : '2024-06-24' -- '2024-06-30'
-- previous_week: '2024-06-17' -- '2024-06-23'
-- ----------------------------------------------------------------


-- ================================================================
-- ЗАПРОС 1: Сводка по источникам за текущую неделю
-- ================================================================
SELECT
    source,
    SUM(spend)                                             AS spend,
    SUM(clicks)                                            AS clicks,
    SUM(registrations)                                     AS registrations,
    SUM(ftd)                                               AS ftd,
    SUM(ngr)                                               AS ngr,
    ROUND(SUM(spend) / NULLIF(SUM(ftd), 0), 2)            AS cpa,
    ROUND(
        (SUM(ngr) - SUM(spend)) / NULLIF(SUM(spend), 0)
        * 100, 1
    )                                                      AS roi_pct,
    ROUND(SUM(registrations) * 100.0
          / NULLIF(SUM(clicks), 0), 2)                    AS c2r_pct,
    ROUND(SUM(ftd) * 100.0
          / NULLIF(SUM(registrations), 0), 2)             AS r2d_pct,
    ROUND(SUM(fraud_clicks) * 100.0
          / NULLIF(SUM(clicks), 0), 2)                    AS fraud_rate_pct,
    ROUND(AVG(approval_rate), 3)                          AS avg_approval
FROM traffic_performance_daily
WHERE date BETWEEN '2024-06-24' AND '2024-06-30'
GROUP BY source
ORDER BY roi_pct DESC NULLS LAST;


-- ================================================================
-- ЗАПРОС 2: WoW сравнение (текущая vs предыдущая неделя)
-- ================================================================
WITH current_week AS (
    SELECT
        source,
        SUM(spend)                                         AS spend_cur,
        SUM(ftd)                                           AS ftd_cur,
        SUM(ngr)                                           AS ngr_cur,
        ROUND(SUM(spend) / NULLIF(SUM(ftd), 0), 2)        AS cpa_cur,
        ROUND(
            (SUM(ngr) - SUM(spend)) / NULLIF(SUM(spend), 0)
            * 100, 1
        )                                                  AS roi_cur,
        ROUND(SUM(fraud_clicks) * 100.0
              / NULLIF(SUM(clicks), 0), 2)                AS fraud_cur
    FROM traffic_performance_daily
    WHERE date BETWEEN '2024-06-24' AND '2024-06-30'
    GROUP BY source
),
prev_week AS (
    SELECT
        source,
        SUM(spend)                                         AS spend_prev,
        SUM(ftd)                                           AS ftd_prev,
        SUM(ngr)                                           AS ngr_prev,
        ROUND(SUM(spend) / NULLIF(SUM(ftd), 0), 2)        AS cpa_prev,
        ROUND(
            (SUM(ngr) - SUM(spend)) / NULLIF(SUM(spend), 0)
            * 100, 1
        )                                                  AS roi_prev
    FROM traffic_performance_daily
    WHERE date BETWEEN '2024-06-17' AND '2024-06-23'
    GROUP BY source
)
SELECT
    c.source,
    -- FTD
    c.ftd_cur,
    p.ftd_prev,
    ROUND((c.ftd_cur - p.ftd_prev) * 100.0
          / NULLIF(p.ftd_prev, 0), 1)                     AS ftd_wow_pct,
    -- Spend
    ROUND(c.spend_cur, 2)                                  AS spend_cur,
    ROUND(p.spend_prev, 2)                                 AS spend_prev,
    ROUND((c.spend_cur - p.spend_prev) * 100.0
          / NULLIF(p.spend_prev, 0), 1)                   AS spend_wow_pct,
    -- CPA
    c.cpa_cur,
    p.cpa_prev,
    ROUND(c.cpa_cur - p.cpa_prev, 2)                      AS cpa_delta,
    -- ROI
    c.roi_cur,
    p.roi_prev,
    ROUND(c.roi_cur - p.roi_prev, 1)                      AS roi_delta,
    -- Fraud
    c.fraud_cur
FROM current_week c
LEFT JOIN prev_week p USING (source)
ORDER BY c.roi_cur DESC NULLS LAST;


-- ================================================================
-- ЗАПРОС 3: GEO разбивка за текущую неделю
-- ================================================================
SELECT
    geo,
    tier,
    ROUND(SUM(spend), 2)                                  AS spend,
    SUM(ftd)                                              AS ftd,
    ROUND(SUM(spend) / NULLIF(SUM(ftd), 0), 2)           AS cpa,
    ROUND(
        (SUM(ngr) - SUM(spend)) / NULLIF(SUM(spend), 0)
        * 100, 1
    )                                                     AS roi_pct,
    ROUND(SUM(ngr) / NULLIF(SUM(ftd), 0), 2)             AS ngr_per_ftd,
    ROUND(SUM(fraud_clicks) * 100.0
          / NULLIF(SUM(clicks), 0), 2)                   AS fraud_rate_pct
FROM traffic_performance_daily
WHERE date BETWEEN '2024-06-24' AND '2024-06-30'
GROUP BY geo, tier
ORDER BY roi_pct DESC;


-- ================================================================
-- ЗАПРОС 4: Топ-5 кампаний недели по FTD
-- ================================================================
SELECT
    source,
    campaign,
    SUM(ftd)                                              AS ftd,
    ROUND(SUM(spend), 2)                                  AS spend,
    ROUND(SUM(spend) / NULLIF(SUM(ftd), 0), 2)           AS cpa,
    ROUND(
        (SUM(ngr) - SUM(spend)) / NULLIF(SUM(spend), 0)
        * 100, 1
    )                                                     AS roi_pct
FROM traffic_performance_daily
WHERE date BETWEEN '2024-06-24' AND '2024-06-30'
  AND spend > 0
GROUP BY source, campaign
ORDER BY ftd DESC
LIMIT 5;


-- ================================================================
-- ЗАПРОС 5: Дневная динамика FTD за неделю
-- ================================================================
SELECT
    date,
    source,
    SUM(ftd)                                              AS ftd,
    ROUND(SUM(spend), 2)                                  AS spend,
    ROUND(SUM(spend) / NULLIF(SUM(ftd), 0), 2)           AS cpa
FROM traffic_performance_daily
WHERE date BETWEEN '2024-06-24' AND '2024-06-30'
GROUP BY date, source
ORDER BY date, source;


-- ================================================================
-- ЗАПРОС 6: Сигналы качества трафика за неделю
-- ================================================================
SELECT
    source,
    geo,
    date,
    clicks,
    registrations,
    ftd,
    ROUND(ctr * 100, 2)                                   AS ctr_pct,
    ROUND(c2r * 100, 2)                                   AS c2r_pct,
    ROUND(r2d * 100, 2)                                   AS r2d_pct,
    ROUND(fraud_clicks * 100.0 / NULLIF(clicks, 0), 2)   AS fraud_rate_pct,
    ROUND(approval_rate, 3)                               AS approval_rate,
    -- Флаг аномалии
    CASE
        WHEN ctr > 0.12
          OR (fraud_clicks * 1.0 / NULLIF(clicks, 0)) > 0.10
          OR approval_rate < 0.75
          OR (r2d < 0.02 AND c2r > 0.15)
        THEN 'ANOMALY'
        ELSE 'NORMAL'
    END                                                   AS quality_flag
FROM traffic_performance_daily
WHERE date BETWEEN '2024-06-24' AND '2024-06-30'
  AND (
        ctr > 0.12
     OR (fraud_clicks * 1.0 / NULLIF(clicks, 0)) > 0.10
     OR approval_rate < 0.75
     OR (r2d < 0.02 AND c2r > 0.15)
  )
ORDER BY date, source, geo;
