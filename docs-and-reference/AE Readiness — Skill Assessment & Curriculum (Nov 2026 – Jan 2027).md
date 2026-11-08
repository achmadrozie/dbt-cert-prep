# AE Readiness — Skill Assessment & Curriculum

Nov 1, 2026 · @Achmad Rozie

## TL;DR

Lu bukan dbt beginner — lu itu **modeling-strong, operations-weak Analytics Engineer.** Yang kurang buat label "Senior" bukan modeling lagi, tapi bukti bahwa lu bisa *menjalankan* pipeline dengan aman di production: testing yang dalam, CI/CD, governance, dan orchestration yang reliable.

- **Readiness sekarang:** AE (mid) — interview-ready hari ini. Senior AE — butuh \~10 minggu kerja terarah buat nutup evidence gap.
- **Satu gap utama:** semua 3 repo lu belum punya CI, contracts, unit tests, source freshness, atau snapshot. Itu yang biasanya ditanya di senior AE loop.
- **Strategi:** jangan bikin project baru. Ambil `zomato-dbt-layer-refactor`, tambahin satu *production layer* per modul, satu PR per modul. Story-nya: *"From working pipeline to production-grade."*
- **dbt cert:** **Ambil — tapi di akhir, sebagai forcing function**, bukan tujuan utama. Syllabus 2026 (v1.11) kebetulan overlap hampir 1:1 sama gap lu. $200, 65 soal, 2 jam.
- **Bootcamp $2,400:** **Skip.** Setengah isinya udah lu kuasai, setengahnya lagi DE-leaning (CDC, Iceberg, Glue). Dua ide bagusnya (growth accounting, SCD) bisa lu ambil gratis.
- **Timeline (direvisi 7 Nov 2026):** M1–M4 dikerjakan **9 Nov – 1 Des**, practice test 3–5 Des, **exam Senin 7 Des 2026**. 4 hari builder/minggu, Minggu tetap off. Airflow (M5) diparkir sampai setelah cert.

## Skill assessment

Level lu tertinggi ada di metric design dan modeling (4/5); terendah di governance dan CI/CD (1/5). Penilaian ini dari bukti: 3 repo GitHub lu (gue clone dan scan), Notion notes (dbt Revamp, Testing, Materialization, Airflow, Semantic Layer), Medium/GDoc write-up, dan pengalaman Bolt yang lu ceritain.

**Skala:** 1 = aware · 2 = bisa dengan docs · 3 = independent · 4 = senior (bisa milih trade-off dan ngajarin) · 5 = expert.

| Area | Level | Evidence | Tag |
| --- | --- | --- | --- |
| Metric design, product analytics, experimentation | 4 | Beehive Metrics Tree, DiD, impact framework, 900-attempt AI experiment write-up | Fact |
| Data modeling & layering (grain, stg → int → core → marts) | 4 | Bolt production + 3 repo; mart naming by grain (`mart_order_city_currency_day_utc`); grain & reconciliation tests | Fact |
| Documentation | 3.5 | `.md` per model konsisten di semua repo, doc blocks | Fact |
| Semantic layer & MetricFlow | 3.5 | Bolt (dbt → Euno → LookML), 20+ metrics di repo, ratio & cross-fact metrics; notes lu bagus | Fact |
| SQL | 3.5–4 | 6 thn kerja + repo; belum teruji di live-coding interview sejak resign | Hypothesis |
| Communication & storytelling | 4 | 3 Medium articles, experiment write-up dengan limitations yang jujur | Fact |
| dbt testing | 2.5 | Generic tests + 7 singular reconciliation tests (cara mikir ini udah senior). **Nol** unit tests, custom generic tests, test configs (`severity`, `where`, `store_failures`), source freshness di repo Zomato | Fact |
| Materialization & incremental | 2.5–3 | Konsep di Notion kuat (5 strategy, microbatch, CI+clone). Implementasi: `merge` incremental di Project 0, tapi repo terbaru pakai `table` semua. Belum ada lookback window + bukti equivalence | Fact |
| Jinja & macros | 2 | `generate_schema_name`, `assert_project1_target` (on-run-start guard — nice), macros di dbt-refactor-sql. Belum nulis macro yang punya logic beneran | Fact |
| Snapshots / SCD2 | 1.5 | Folder `snapshots/` kosong di ketiga repo | Fact |
| Governance (contracts, constraints, versions, access, exposures) | 1 | Nol di repo | Fact |
| CI/CD, state, slim CI, defer/clone/retry | 1–1.5 | Nggak ada `.github/workflows` di repo manapun; exposure di Bolt lebih ke konsep | Fact |
| Git workflow | 2.5–3 | PR, branching, conflict di Bolt | Hypothesis |
| Orchestration (Airflow) | 1.5–2 | 1 DAG linear 4 task (`zomato_batch`). Belum ada retries, alerting, idempotency, backfill. `COPY INTO ... ON_ERROR='CONTINUE'` = baris rusak hilang diam-diam | Fact |
| Snowflake (warehouse ops) | 2.5 | Storage integration, stage, COPY INTO. Belum: RBAC, warehouse sizing, clustering, cost | Fact |
| Python | 2.5 | Script experiment, autograde, guards | Hypothesis |
| AI analytics layer | 3 | Text-to-SQL, RAG, layer experiment — differentiator, tapi tetap amplifier | Fact |

**Pola besarnya:** semua yang "design" (metric, grain, layer, semantic) udah 3.5–4. Semua yang "operate" (test depth, CI, governance, orchestration) masih 1–2.5. Senior AE dinilai dari dua-duanya.

## Review hipotesis lu

Mental model lu hampir benar, tapi lu nyari gap di tempat yang salah: lu fokus ke "belajar ulang konsep", padahal gap-nya ada di "bukti operasional".

**Yang bener:**

- Airflow memang terbatas. Setuju — tapi target lu *orchestration-literate AE*, bukan DE. Kedalaman yang dibutuhin jauh lebih dangkal dari curriculum bootcamp.
- Testing perlu di-revisit. Bener, dan ini prioritas #1.
- Data modeling lu udah kuat. Bener — repo lu buktiin itu, jangan belajar ulang.

**Yang agak meleset:**

- *"Revisit materialization"* — konsep lu udah lengkap (notes lu cover 5 strategy + CI clone). Yang kurang adalah **implementasi dengan bukti**: incremental + lookback window + bukti hasilnya sama dengan full refresh. Itu exercise, bukan chapter baru.
- *"Revisit Jinja & macro"* — jangan dipelajari sebagai topik sendiri. Pelajari lewat **nulis custom generic test** (itu macro). Satu exercise, dua skill.

**Yang belum ada di list lu (dan justru paling penting buat Senior):**

1. **CI/CD** — GitHub Actions, slim CI `state:modified+`, `--defer`, `dbt clone`, `dbt retry`. Ini yang bikin reviewer mikir "orang ini pernah kerja di tim".
2. **Governance** — model contracts, constraints, versions, exposures. Muncul di cert 2026 dan di diskusi "data product".
3. **Snapshots / SCD2** — pertanyaan klasik interview, dan kosong di repo lu.
4. **Source freshness** — ada di dbt-refactor-sql, hilang di repo Zomato.

**Temuan konkret di DAG lu** (bagus buat exercise pertama Airflow): `ON_ERROR='CONTINUE'` di `COPY INTO` artinya baris yang gagal parse di-skip tanpa error. Pipeline "hijau", data kurang. Senior AE harus bisa jelasin kenapa ini bahaya dan gimana nge-guard-nya.

## Gaps: now, later, ignore

Cuma 5 hal yang masuk "now"; sisanya sengaja ditunda biar lu nggak buka terlalu banyak branch.

| Bucket | Topik | Kenapa |
| --- | --- | --- |
| **Now** | Testing depth (unit, custom generic, configs, freshness) | Gap terbesar yang paling sering ditanya + fondasi CI |
| **Now** | Incremental dengan bukti + snapshots/SCD2 | Konsep udah ada, tinggal dibuktiin di repo |
| **Now** | CI/CD + dbt state (slim CI, defer, clone, retry, `--empty`) | Sinyal "pernah kerja di tim production" paling kuat |
| **Now** | Governance (contracts, constraints, versions, exposures) | Senior = owner data product, bukan cuma builder |
| **Now** | Airflow reliability (retries, alerting, idempotency, backfill, write-audit-publish) | Cukup buat AE-level; DAG lu sekarang "demo-grade" |
| Later | Growth accounting mart (new / retained / resurrected / churned) | Bagus banget buat PA + AE story, setelah fondasi kelar |
| Later | Snowflake cost & RBAC (warehouse sizing, clustering, roles) | Muncul di diskusi senior, tapi sekunder |
| Later | Python models di dbt, SQLFluff advanced rules | Cukup tahu; jarang jadi penentu |
| Later | Experimentation / causal inference deep-dive | Udah salah satu strength terkuat lu — maintenance aja |
| Ignore | CDC, Iceberg, Glue catalog, Spark, Kafka | DE territory, bukan AE |
| Ignore | Snowflake Cortex/AI agents, ontology/knowledge graph | Menarik, tapi itu branch AI — parkir sampai 2027 |
| Ignore | Bootcamp/kursus baru di tengah jalan | Ini pola FOMO; curriculum di bawah udah cukup |

## Curriculum: 6 modul, 1 repo, 1 PR per modul

Semua modul dikerjain di **satu repo** (`zomato-dbt-layer-refactor`, atau fork-nya jadi `zomato-production-grade`). Setiap modul selesai = 1 PR yang merged + 1 catatan pendek "decision memo" di `docs/`. Satu modul jalan dulu sampai selesai, baru buka yang berikutnya.

Resource utama semua gratis: [dbt Learn](https://learn.getdbt.com) (course on-demand), [dbt docs](https://docs.getdbt.com), dan [Astronomer Academy](https://academy.astronomer.io) buat Airflow. YouTube dipakai sebagai pelengkap, bukan jalur utama — video tanpa output itu jebakan yang lu sendiri udah tulis di learning style lu.

### M0 · Baseline check (2 hari, Minggu 1)

- **Problem:** biar kita nggak nebak level lu.
- **Do:** kerjain 10 sample questions di [official study guide](https://www.getdbt.com/dbt-assets/certifications/dbt-certificate-study-guide-version-1-11) tanpa buka docs, timer 20 menit. Catat mana yang salah per domain.
- **Build:** bersihin README repo + tambahin `profiles.yml.example` dan cara run. Ini PR #0.
- **Done when:** lu tau skor baseline per domain (prediksi gue: governance & state paling rendah).

### M1 · Testing depth (9–13 Nov, 4 hari)

- **Problem:** test lu sekarang ngecek bentuk data, belum ngecek *logic*. Senior ditanya "gimana lu tau transformasi ini benar sebelum di-merge?"
- **Learn:** test pyramid (source → model → unit), unit tests (dbt ≥1.8), custom generic test via macro (= Jinja lu kepakai di sini), test configs `severity`, `warn_if`/`error_if`, `where`, `store_failures`, source freshness.
- **Build (PR #1):** 2 unit tests buat `int_order_financials` (edge: discount > subtotal, null fee), 1 custom generic test `assert_non_negative` + 1 `assert_sum_matches`, freshness di `_sources.yml`, `where` filter di test fact besar.
- **Resources:** dbt Learn — *Advanced Testing*, *Unit Testing*; docs — "Writing custom generic data tests".
- **Done when:** lu bisa jelasin dalam 2 menit "test apa ditaruh di layer mana, dan kenapa" → tulis jadi `docs/testing_strategy.md`.

### M2 · Incremental + snapshots (16–19 Nov, 3 hari)

- **Problem:** `fact_order` 10 juta baris di-rebuild full tiap run. Dan lu belum punya history perubahan dimensi.
- **Learn:** lookback window buat late-arriving data, `unique_key` + `merge`, `on_schema_change`, kapan full refresh, microbatch (konsep), snapshot `check` vs `timestamp`.
- **Build (PR #2):** ubah `fact_order` jadi incremental + 3-day lookback; buktiin hasilnya identik sama full refresh pakai `audit_helper` (lu udah kenal). Snapshot `restaurant` → `dim_restaurant_scd2` dengan `valid_from`/`valid_to`.
- **Done when:** ada tabel "before/after" runtime + hasil audit 100% match di `docs/incremental_proof.md`.

### M3 · CI/CD + dbt state (20–26 Nov, 4 hari; CI pakai DuckDB)

- **Problem:** sekarang "benar" = "jalan di laptop gue". Tim butuh tiap PR dicek otomatis tanpa build ulang semuanya.
- **Learn:** GitHub Actions basics, schema per PR, `state:modified+`, `--defer`, `dbt clone`, `dbt retry`, `--empty` dry run, SQLFluff lint.
- **Build (PR #3):** workflow `ci.yml` (lint → `dbt build --select state:modified+ --defer --empty` → build beneran ke schema `pr_<n>`), artifact `manifest.json` dari main buat state, PR template.
- **Resources:** docs — "About state", "To defer or to clone", "dbt retry"; dbt Learn — *Advanced Deployment*.
- **Done when:** ada PR yang CI-nya merah karena test gagal, lalu hijau setelah fix. Screenshot itu = portfolio gold.

### M4 · Governance (27 Nov – 1 Des, 3 hari)

- **Problem:** consumer (BI, AI agent) butuh janji bahwa shape model nggak berubah diam-diam.
- **Learn:** model contracts, constraints, versions + deprecation, `access` & groups, exposures.
- **Build (PR #4):** contract + constraints di `fact_order` & `fact_order_item`; `fact_order` v2 (rename kolom) dengan v1 deprecated; exposure buat Streamlit app & AI text-to-SQL.
- **Resources:** dbt Learn — *dbt Mesh: Model Governance*.
- **Done when:** `dbt build` gagal kalau ada yang ngubah tipe kolom tanpa naikin versi. Lu bisa jelasin bedanya contract vs test.

### M5 · Airflow reliability (DIPARKIR: setelah cert, opsional, Des akhir / Jan awal)

> Keputusan 7 Nov 2026: cert tidak menguji Airflow, jadi M5 keluar dari sprint cert. Temuan `ON_ERROR='CONTINUE'` tetap jadi bahan cerita interview.

- **Problem:** DAG lu sekarang "demo-grade": nggak retry, nggak alert, dan `ON_ERROR='CONTINUE'` bisa diam-diam buang data.
- **Learn:** `default_args` (retries, retry\_delay, timeouts), `on_failure_callback`, idempotency, logical date & data interval, backfill, sensor dasar, write-audit-publish (build → test → baru expose), opsional: Cosmos (tiap dbt model jadi task).
- **Build (PR #5):** `zomato_batch` v2 — retries + alert, ganti ke `ON_ERROR='ABORT_STATEMENT'` + row-count check, `dbt source freshness` sebagai gate, `dbt build` per layer (stg → core → marts) biar kegagalan kelihatan di mana. `docs/runbook.md`: "kalau task X gagal, lakukan Y".
- **Resources:** Astronomer Academy — Airflow 3 Fundamentals; notes Airflow lu sendiri (udah bagus sebagai fondasi).
- **Done when:** lu sengaja rusak 1 file source, dan pipeline berhenti di tempat yang benar + ngasih tau kenapa.

### M6 · Cert sprint (3–5 Des, exam Senin 7 Des 2026)

- **Do:** ulang 16 soal baseline (3 Des), 2–3 practice tests v1.11 (free di [open-exam-prep](https://open-exam-prep.com/practice/dbt-analytics-engineering); opsional Udemy practice tests), review soal salah ke docs. Sabtu 5 Des = review ringan saja, Minggu off, tidak ada belajar baru H-1.
- **Gate:** exam jalan kalau practice test konsisten ≥75% (lulus ≥65%, margin 10 poin buat gugup). Kalau belum, geser 1 minggu; jangan dipaksa. Cek aturan reschedule dan jeda retake di study guide sebelum booking (Unknown).
- **H-2:** cek setup online proctored (kamera, koneksi, ruangan).
- **Setelah exam (bukan bagian sprint):** README utama jadi case study "From working pipeline to production-grade" + 1 Medium article; M5 Airflow opsional.
- **Done when:** cert lulus (≥65%); repo bisa dipresentasiin 10 menit di interview tanpa buka catatan (target setelah exam).

## dbt cert & bootcamp verdict

**dbt cert: ambil, exam Senin 7 Des 2026.** Bootcamp DataExpert: skip.

**Fakta cert** ([official study guide v1.11](https://www.getdbt.com/dbt-assets/certifications/dbt-certificate-study-guide-version-1-11)): 65 soal, 2 jam, lulus ≥65%, $200 per attempt (retake bayar lagi), berlaku 2 tahun, online proctored, versi dbt Core 1.11. dbt Labs rekomendasiin 6+ bulan pengalaman dbt — lu udah lewat itu.

| Faktor | Penilaian |
| --- | --- |
| Overlap syllabus vs gap lu | Tinggi: domain governance, state/retry/clone, testing, snapshots, microbatch, `--empty` = persis M1–M4 |
| Nilai di mata hiring manager | Sedang — tie-breaker di screening, bukan penentu. Repo + cerita Bolt lebih berat |
| Biaya | Rendah ($200), dibanding $2,400 bootcamp |
| Risiko | Jadi "exam cramming" yang geser portfolio. Makanya ditaruh di akhir, setelah build |

*Hypothesis:* buat remote role di luar negeri, cert ngebantu lolos filter recruiter non-teknis yang nyari keyword "dbt certified". *Unknown:* seberapa besar efeknya di market target lu — belum ada data.

**Bootcamp DataExpert ($2,400):** isinya terbagi dua. Yang udah lu punya: dbt basics, semantic layer, data modeling. Yang DE-leaning: CDC, Iceberg, Glue catalog, Snowflake AI agents. Value-nya buat lu adalah *struktur* dan *cohort*, bukan konten. Dua ide yang worth dicuri gratis:

- **Growth accounting** (new / retained / resurrected / churned users) → jadi "Later" mart setelah M6; nyambung banget ke PA background lu.
- **SCD / read streams** → udah masuk M2 lewat snapshot.

Kalau suatu saat lu butuh accountability eksternal (bukan konten), cari opsi yang jauh lebih murah dulu: dbt Slack `#dbt-certification`, study buddy, atau mentoring session per jam.

## Timeline

Direvisi 7 Nov 2026. M0 selesai 3 Nov (Selasa). M1 mulai 9 Nov. M1–M4 selesai 1 Des, practice test 3–5 Des, **exam Senin 7 Des 2026**. Sisa waktu sampai kelas OMSA (11 Jan 2027) jadi buffer retake kalau attempt pertama gagal. Setelah cert: M5 Airflow (opsional) + case study README + Medium. Ritme direvisi 7 Nov: 5 hari x 6 jam (pagi 4 jam inti + siang 2 jam flex, selesai ±15:00), Sabtu off/ringan, Minggu off. Tanggal modul tetap; jam ekstra = buffer, bukan tambahan scope. Tripwire dicek tiap Jumat (lihat `STATE.md`).

| Tanggal | Fokus |
| --- | --- |
| 9–13 Nov | M1 Testing (4 hari) |
| 16–19 Nov | M2 Incremental + snapshots (3 hari) |
| 20–26 Nov | M3 CI/CD + state (4 hari) |
| 27 Nov – 1 Des | M4 Governance (3 hari) |
| 3–5 Des | Baseline ulang + practice tests (gate ≥75%) |
| Sen 7 Des | Exam |

&#91;embedded content: AE readiness plan · 6 modules, 2 buffer weeks, 1 exam\]

Buffer week dari plan awal sudah dipakai untuk memadatkan jadwal. Kalau satu modul molor, pilihannya: potong scope modul itu, atau geser exam 1 minggu. Bukan malam hari atau hari Minggu.

**Ritme mingguan (nempel ke Personal OS lu):**

- **Immersion day (Sen, Sel, Kam, Jum):** satu objective modul, build → test → commit. Satu PR per modul, bukan per hari.
- **Split-swim day (Rab, Sab):** blok pertama = konsep / dbt Learn; blok kedua = lanjut objective yang sama.
- **Minggu:** off. Nggak ada "bayar utang" modul.
- **Interview lane:** interview yang beneran ada selalu menang atas modul. Di luar itu cukup 2 × 30 menit SQL drill per minggu.
- **Low-battery day:** baca satu halaman docs modul yang sedang jalan, atau nggak sama sekali. Nggak ada kompensasi malam.

## Open questions buat lu

- [ ] **Jam per minggu:** plan ini asumsi \~12–16 jam/minggu (4 builder day × \~3–4 jam). Masih realistis sambil interview jalan?
- [ ] **Snowflake account:** trial masih aktif? CI di M3 butuh warehouse. Kalau trial habis, opsi murah: CI pakai DuckDB (`dbt-duckdb`) di subset data, Snowflake cuma buat run manual.
- [ ] **OMSA Spring 2027:** masih lanjut? Kalau ya, kapan kelas pertama mulai — M6 cert sebaiknya kelar sebelum itu, bukan bareng.
- [ ] **Target market:** AU, EU, atau global remote? Ngaruh ke timezone dan seberapa penting cert buat filter recruiter.
- [ ] **Akses review:** mau gue review tiap PR langsung dari repo GitHub (lu tinggal minta gue attach repo-nya)?

Gue nggak butuh akses tambahan buat mulai M0–M1 — semua yang dibutuhin udah ada.
