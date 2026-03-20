# Traffic Analyst Portfolio — iGaming / Media Buying Analytics

> **Тимофей Медведев** · Data Analyst · Traffic & Marketing Analytics  
> [timofey.m.medvedev@gmail.com](mailto:timofey.m.medvedev@gmail.com) · [github.com/timofeymmedvedev](https://github.com/timofeymmedvedev)

---

## О проекте

Практическое портфолио аналитика трафика в сфере **iGaming / Media Buying**.  
9 аналитических кейсов — от базового анализа источников трафика до построения вероятностных LTV-моделей (BG/NBD).

Весь стек: **Python · SQL · pandas · matplotlib · scipy · numpy**.  
Все модели реализованы с нуля — без внешних ML-библиотек.

---

## Структура репозитория

```
traffic-analyst-portfolio/
│
├── README.md
│
├── data/
│   ├── traffic_performance_daily.csv   # grain: date × source × campaign × geo
│   ├── players.csv                     # grain: player (с флагом фрода)
│   ├── player_deposits.csv             # grain: deposit (все транзакции)
│   ├── cohort_metrics.csv              # grain: cohort_month × source
│   ├── geo_performance.csv             # grain: month × geo × source
│   ├── fraud_signals.csv               # grain: date × source × geo + alert_type
│   └── data_dictionary.csv             # справочник всех полей
│
├── notebooks/
│   ├── 01_source_analysis.ipynb
│   ├── 02_cac_ltv_payback.ipynb
│   ├── 03_geo_analysis.ipynb
│   ├── 04_funnel_analysis.ipynb
│   ├── 05_fraud_detection.ipynb
│   ├── 06_scale_pause.ipynb
│   ├── 07_cohort_ltv.ipynb
│   ├── 08_weekly_report.ipynb
│   └── 09_ltv_forecast_bgnbd.ipynb
│
└── sql/
    ├── 06_scale_pause_decisions.sql
    └── 08_weekly_report.sql
```

---

## Датасет

Синтетический датасет, моделирующий реальную среду iGaming media buying.

| Таблица | Строк | Описание |
|---|---|---|
| `traffic_performance_daily` | 7 644 | Ежедневные метрики по source × campaign × geo |
| `players` | 15 000 | Профиль каждого игрока с attribution и флагом фрода |
| `player_deposits` | 26 168 | Все депозиты: FTD и редепозиты |
| `cohort_metrics` | 42 | Предагрегированные когортные метрики |
| `geo_performance` | 252 | Месячные метрики по GEO × source |
| `fraud_signals` | 7 654 | Сигналы качества трафика с аномалиями |

**Источники трафика:** Google Search · Facebook · Affiliate/SEO · Native Ads · TikTok · Push Network  
**GEO:** DE · CA · AU (Tier 1) · PL · BR (Tier 2) · IN · NG (Tier 3)  
**Период:** Q1–Q2 2024 (январь — июнь)

---

## Кейсы

### Кейс 1 — Анализ эффективности источников трафика
**`notebooks/01_source_analysis.ipynb`**

Сравнение 6 источников трафика по полному набору метрик: CTR, c2r, r2d, CPA, ROI, NGR/FTD, fraud rate, approval rate.

- Агрегация: impression → click → registration → FTD
- Scatter-позиционирование: CPA vs NGR/FTD
- Недельная динамика по 4 метрикам
- Итоговая таблица: **Scale / Watch / Hold / Pause**

**Ключевой вывод:** Дешёвый CPA ≠ хороший трафик. Push Network при CPA $12.6 имеет fraud rate 14% и approval 86% — реальная стоимость качественного FTD кратно выше.

---

### Кейс 2 — CAC vs LTV: окупаемость источников
**`notebooks/02_cac_ltv_payback.ipynb`**

Анализ окупаемости трафика через призму юнит-экономики.

- CAC, LTV 30d/90d, Payback Period по источникам
- Накопительные LTV-кривые из raw-данных депозитов
- Redeposit rate как главный индикатор качества
- Когортная матрица LTV 30d

**Ключевой вывод:** В iGaming краткосрочный ROI всегда отрицательный — норма. Реальная окупаемость наступает через 6–22 месяца. Оценивать нужно по redeposit rate и форме LTV-кривой.

---

### Кейс 3 — GEO Анализ
**`notebooks/03_geo_analysis.ipynb`**

Сравнение эффективности трафика по 7 странам трёх тиров.

- Tier-система: T1 (DE, CA, AU) / T2 (PL, BR) / T3 (IN, NG)
- Тепловые карты ROI и NGR/FTD по матрице GEO × Source
- CPA vs NGR/FTD scatter-позиционирование
- Итоговые решения: Scale / Grow / Watch / Hold / Review

**Ключевой вывод:** T1 GEO оправдывают высокий CPA — NGR/FTD в 5–8× выше T3. Google Search в DE: CPA $17, NGR/FTD $104, ROAS 9.76×.

---

### Кейс 4 — Анализ воронки
**`notebooks/04_funnel_analysis.ipynb`**

Поэтапный анализ конверсий: Impression → Click → Registration → FTD → Redeposit.

- Waterfall-воронка для каждого источника
- Сравнение c2r и r2d с benchmark-линиями
- Drop-off на каждом этапе
- Скорость конверсии: распределение дней от регистрации до FTD

**Ключевой вывод:** r2d — главный диагностический показатель. Низкий r2d при нормальном c2r = проблема в онбординге (KYC/оплата). Оба низких = некачественная аудитория.

---

### Кейс 5 — Антифрод анализ
**`notebooks/05_fraud_detection.ipynb`**

Rule-based система детекции мошеннического трафика.

- 5 правил: CTR > 12%, fraud rate > 10%, approval < 75%, c2r/r2d gap
- Метрики качества: **Precision 93.4%, Recall 100%, F1 0.97**
- Паттерны: CTR Spike (Push Network) и Click Injection (TikTok/BR)
- Итоговая таблица: Approved / Monitor / Review / Pause

**Ключевой вывод:** Push Network — системная проблема (fraud 14% стабильно 6 месяцев, не спайк). Click injection у TikTok — техническая атака, требует проверки CTIT и SDK.

---

### Кейс 6 — Scale vs Pause: решения о масштабировании
**`notebooks/06_scale_pause.ipynb`** · **`sql/06_scale_pause_decisions.sql`**

Scoring-модель (0–100 баллов) для принятия решений по каждой связке source × GEO.

- 5 компонентов: ROI (30 pts) · Fraud (25 pts) · CPA vs Target (20 pts) · r2d (15 pts) · Approval (10 pts)
- CPA-таргеты: T1 $18 / T2 $8 / T3 $3
- Полная матрица решений: 35 комбинаций source × GEO
- Рекомендация по перераспределению бюджета

**Ключевой вывод:** Google Search — score 95–100 по всем GEO, SCALE. Push Network — score 12–20, PAUSE немедленно.

---

### Кейс 7 — Когортный анализ LTV
**`notebooks/07_cohort_ltv.ipynb`**

Анализ качества трафика во времени через призму когорт.

- Retention D1/D7/D30/D90 по источникам
- Тепловые карты Retention и LTV 90d
- Payback Period по источникам (в днях и месяцах)
- Простой прогноз LTV (линейная экстраполяция D90+)

**Ключевой вывод:** Retention D30 — лучший ранний индикатор LTV. Когорты июня 2024 слабее у всех источников — сезонный эффект или изменение welcome-бонуса.

---

### Кейс 8 — Еженедельный отчёт для тимлида
**`notebooks/08_weekly_report.ipynb`** · **`sql/08_weekly_report.sql`**

Полный pipeline еженедельного отчёта: SQL-запросы + Python-визуализация + автогенерация текста.

- WoW сравнение всех KPI (FTD, Spend, CPA, ROI, Fraud)
- GEO разбивка, топ-5 кампаний
- Детекция аномалий за неделю
- Дашборд 3×3 с delta-индикаторами
- **Автоматическая генерация текстового отчёта** с тревогами и рекомендациями

SQL-файл содержит 6 готовых запросов для PostgreSQL / BigQuery / SQLite.

---

### Кейс 9 — LTV Forecast: BG/NBD + Kaplan-Meier
**`notebooks/09_ltv_forecast_bgnbd.ipynb`**

Вероятностное моделирование LTV — реализация с нуля через `scipy.optimize`.

**BG/NBD (Beta-Geometric / NBD):**
- Два вложенных процесса: транзакции (Poisson/Gamma) + отток (Beta-Geometric)
- MLE-оптимизация через L-BFGS-B с log-space параметрами
- `P(alive | x, t_x, T)` и `E[Y(t) | x, t_x, T]` для каждого игрока
- CLV = E[транзакций] × avg deposit × house edge

**Kaplan-Meier Survival Analysis:**
- Реализация с нуля (без внешних библиотек)
- S(t) — вероятность быть активным через t недель
- Сравнение по источникам: S(1w), S(4w), S(13w)

**Ключевой вывод:** P(alive) у Affiliate/SEO = 0.52 vs Push Network = 0.12 — математическое подтверждение разницы в качестве трафика через поведение игроков, а не через fraud flags.

---

## Технологии

```
Python 3.11       pandas · numpy · matplotlib · scipy.optimize · scipy.special
SQL               PostgreSQL / BigQuery / SQLite совместимый синтаксис
Методы            BG/NBD · Kaplan-Meier · Cohort Analysis · Rule-Based Detection
                  A/B Testing · Unit Economics · Funnel Analytics · Scoring Models
Метрики           CTR · CPC · CPA · CPM · CVR · c2r · r2d · ROI · ROAS · LTV
                  CAC · ARPU · Retention · Churn · FTD · GGR · NGR · RevShare
```

---

## Запуск

```bash
# 1. Клонировать репозиторий
git clone https://github.com/timofeymmedvedev/traffic-analyst-portfolio.git
cd traffic-analyst-portfolio

# 2. Установить зависимости
pip install pandas numpy matplotlib scipy jupyter

# 3. Запустить Jupyter
jupyter notebook

# 4. Открыть любой notebook из папки notebooks/
#    Kernel → Restart & Run All
```

> Все пути к данным прописаны как `../data/` — файлы CSV должны лежать в папке `data/`.

---

## Контакты

**Тимофей Медведев**  
Data Analyst | Traffic & Marketing Analytics  
[timofey.m.medvedev@gmail.com](mailto:timofey.m.medvedev@gmail.com)  
[@timeranchik](https://t.me/timeranchik)
