# M1 · Testing Depth — Action Items

Periode: Minggu 1–2 (mulai 3 Nov 2026). Output: **PR #1** di repo + `docs/testing_strategy.md`.

## 0. Cara kerja bareng Rozie (untuk Claude Code sebagai mentor)

**Gaya belajar:** concept-first, example-driven, mentor-guided. Urutan penjelasan: masalah apa yang diselesaikan → posisi di workflow → analogi sederhana → contoh nyata dari repo → kapan dipakai / tidak → mini exercise → validasi mental model. Jangan mulai dari definisi buku atau dump dokumentasi.

**Loop belajar tiap konsep:** (1) Rozie coba/tulis sendiri dulu, (2) dia jelaskan dengan kata sendiri, (3) mentor koreksi pakai format: *yang sudah benar → yang agak salah → yang kurang → mental model yang benar → contoh → latihan berikutnya*, (4) dia tes sendiri, (5) bukti disimpan di repo. Jangan tulis solusi penuh sebelum dia mencoba; jangan sekadar setuju kalau asumsinya salah.

**Anti-overwhelm:** satu konsep, satu contoh, satu latihan. Jangan buka cabang lain (CI, governance, Airflow, AI/LLM, experimentation) sebelum M1 selesai. Kalau dia melompat topik, tarik balik ke M1.

**Guardrail (dari preferensi dan konteks pemulihannya):**
- Ritme: 4 hari immersion (Sen/Sel/Kam/Jum), ~3–4 jam, ≈16 jam/minggu. Rab/Sab opsional. **Minggu libur, tanpa "bayar utang".** Jangan naikkan ke 5×8 jam; dia baru recovery.
- Heavy work berhenti setelah Maghrib. Tidak ada kompensasi malam.
- Low-battery day: baca satu halaman docs modul, atau tidak sama sekali.
- Jangan ambil keputusan besar saat dia capek/anxious/overwhelmed (termasuk soal OMSA dan arah karier); tunda.
- Kalau dia belajar dari panik, marah ke diri sendiri, atau membandingkan diri dengan orang lain: bilang langsung.
- Salah satu aturannya: macet > 20 menit di satu error → minta dia tempel error-nya ke mentor.
- Experimentation/causal inference diparkir sampai M6 selesai.
- Gaya bahasa: Indonesia-English santai, "gue/lu", gentle tapi direct. Gunakan Fact / Hypothesis / Unknown bila membantu.

## 1. Target M1

**Problem:** test saat ini mengecek *bentuk* data, belum mengecek *logic*. Pertanyaan senior: "gimana lu tau transformasi ini benar sebelum di-merge?"

**Posisi tes di workflow:**
```text
source ──► staging/int ──► marts ──► consumers
  │            │             │
freshness   unit test     data test
+ source     (logic,       (grain, reconciliation,
 tests        data palsu)   not_null/unique pada data nyata)
```
Analogi dapur: freshness = cek bahan masuk; unit test = tes resep dengan bahan palsu; data test = cicip masakan sebelum keluar.

**Gap M1 (dari baseline):** unit tests, custom *generic* test (macro), test configs (`severity`, `warn_if`/`error_if`, `where`, `store_failures`), source freshness. Konsep dasar test sudah dipegang lewat catatan Notion "DBT - Testing"; **jangan dibaca ulang dari awal**, cukup skim 10 menit.

## 2. Repo dan asumsi (verifikasi dulu)

Repo kerja: `dbt-cert-prep/dbt-project/` (dbt Core 1.10.22 + DuckDB). Model `int_order_financials`, `fact_order`, dan `fact_order_item` sudah dimigrasikan. Input staging saat ini berasal dari seeds, bukan `_sources.yml`. Asumsi lama tentang source freshness dan 7 singular reconciliation test perlu dicek ulang saat sampai ke Loop C; jangan jadikan itu penghalang Loop A.

Sintaks YAML di bawah hanyalah skeleton; **cek terhadap docs untuk versi dbt di repo** (konfigurasi freshness/test config bisa berada di blok `config:` pada versi terbaru).

## 3. Loop A — Unit test (hari 1–2)

**Tujuan:** buktikan bahwa logika `int_order_financials` menghasilkan output yang disepakati untuk input yang sengaja kita pilih. Unit test menjalankan SQL model dengan beberapa baris **buatan** (`given`), lalu membandingkan hasilnya dengan **ekspektasi** (`expect`). Test merah berarti hasil SQL berbeda dari ekspektasi; cek apakah aturan bisnis, ekspektasi, atau SQL yang perlu dikoreksi. Edge case adalah cara memilih input yang kemungkinan membuka bug, bukan tujuan test itu sendiri.

**Beda dari data test:** unit test memeriksa hubungan input → output tertentu tanpa mengandalkan isi DuckDB saat itu. Generic data test memeriksa aturan pada data model yang sudah dibangun; misalnya `unique` pada seluruh `order_id` yang benar-benar ada. Keduanya menjawab pertanyaan yang berbeda.

**Baca (≤20 menit):** dbt Learn *Unit Testing*; docs "Unit tests". Cukup cari sintaks yang diperlukan saat menulis test.

**Kerjakan satu kasus dulu (`discount > subtotal`):**
1. Buka SQL `int_order_financials`. Catat kolom yang dibaca dari `stg_zomato__order` dan kolom output yang dihitung.
2. Buat satu order di atas kertas. Tulis kalimat: “Jika input-nya X, output Y seharusnya Z, karena aturan bisnis ...”. Tentukan apakah diskon yang dibatasi, total akhir yang dibatasi, atau aturan lain. Jangan mengambil hasil SQL saat ini sebagai jawaban otomatis.
3. Baru tulis unit test di `int_order_financials.yml`: `unit_tests:` berada di level teratas, sejajar dengan `models:`. `model` menunjuk ke `int_order_financials`; `given.input` menunjuk ke `ref('stg_zomato__order')`. Isi `given.rows` dengan seluruh kolom input yang dibaca SQL, dan `expect.rows` dengan output yang ingin dibuktikan. Jangan menyalin placeholder bertanda `<...>` sebagai nama kolom.
4. Jalankan `dbt test --select int_order_financials,test_type:unit`. Jika merah, baca selisih actual vs expected dan jelaskan penyebabnya sebelum mengubah kode.
5. Setelah hijau, **ubah satu nilai di `expect` menjadi salah dengan sengaja**, jalankan lagi sampai merah, pahami selisihnya, lalu kembalikan. Ini membuktikan test mampu mendeteksi hasil yang salah tanpa perlu merusak SQL model.

**Kasus kedua (`delivery_fee` null):** ulangi urutan yang sama. Tentukan dulu apakah fee yang hilang seharusnya dianggap nol, menghasilkan NULL, atau mengikuti aturan bisnis lain. Tulis ekspektasinya sebelum menulis YAML.

**Selesai bila:** dua unit test hijau, satu percobaan merah yang disengaja dan dipahami, serta aturan bisnis untuk kedua edge case bisa dijelaskan dengan kata sendiri.

**Jelaskan balik (3–4 kalimat, tulis sendiri):** beda unit test vs data test; kapan unit test layak dan kapan tidak.

## 4. Loop B — Custom generic test (hari 3)

**Baca:** docs "Writing custom generic data tests".

**Build:**
1. `tests/generic/assert_non_negative.sql`:
```sql
{% test assert_non_negative(model, column_name) %}
select * from {{ model }} where {{ column_name }} < 0
{% endtest %}
```
2. Pasang di beberapa kolom nominal (mis. revenue, fee) pada ≥2 model via YAML.
3. Tambah `assert_sum_matches` (argumen: dua model/kolom yang totalnya harus sama) sebagai latihan argumen tambahan.
4. Rusakkan satu data (atau seed) agar test merah; lihat `target/run/` dan `target/compiled/` untuk melihat SQL test yang dieksekusi.

**Selesai bila:** dua custom generic test dipakai di ≥2 model; Rozie bisa menjelaskan kenapa ini macro Jinja dan beda dari singular test.

## 5. Loop C — Configs + freshness (hari 4–5)

**Baca:** docs "Data test configurations"; "Source freshness".

**Build:**
1. Di test untuk fact besar: tambahkan `where` (mis. hanya N hari terakhir) agar tidak scan seluruh tabel.
2. Satu test dengan `warn_if` / `error_if` (mis. `warn_if: ">0"`, `error_if: ">100"`), lalu buktikan: 40 baris gagal → WARN dan downstream tetap build; 150 baris → FAIL dan downstream SKIP (di `dbt build`).
3. `store_failures` pada satu test; lihat tabel baris-gagalnya di warehouse.
4. Tambah freshness di `_sources.yml` (`loaded_at_field` + `warn_after`/`error_after`). Jalankan `dbt source freshness`.

**Selesai bila:** Rozie bisa menjelaskan sendiri perbedaan warn vs error vs fail-skip pada `dbt build` (ini sekaligus menutup Q12).

## 6. Loop D — Dokumen strategi (hari 6, tulis ≤ 1 jam)

Tulis `docs/testing_strategy.md`, maksimal ±1 halaman:
- Tabel: layer → jenis test → contoh → alasan.
- "Test apa ditaruh di layer mana, dan kenapa" harus bisa dijelaskan dalam 2 menit.
- Bagian "yang sengaja tidak dites" (unit test tidak untuk pass-through).
- Satu paragraf: pelajaran dari test merah yang disengaja.

## 7. PR #1

Satu PR untuk seluruh M1. Template deskripsi:
```markdown
## Problem
Apa yang tadinya tidak terjaga?

## Perubahan
- 2 unit tests: ...
- Custom generic tests: assert_non_negative, assert_sum_matches
- Test configs: where, warn_if/error_if, store_failures
- Freshness di _sources.yml

## Bukti
- output `dbt test` hijau
- bukti merah yang disengaja (screenshot/log)
- hasil warn vs fail-skip

## Yang masih gue ragu
(bagian paling penting untuk review)
```
Sebelum meminta review, Rozie menjelaskan PR-nya dengan kata sendiri; mentor mengoreksi *mental model*-nya, bukan hanya kodenya.

## 8. Jadwal usulan (bukan kewajiban; ada slack)

| Hari | Fokus |
| --- | --- |
| Sel 3 Nov | Loop A saja, ≤90 menit, stop sebelum Maghrib |
| Rab 4 Nov | Selesaikan Loop A; mulai baca Loop B |
| Kam 5 Nov | Loop B |
| Jum 6 Nov | Loop C bagian 1–2 |
| Sen 9 Nov | Loop C bagian 3–4 |
| Sel 10 Nov | Loop D + merapikan PR |
| Kam 12 Nov | PR #1 siap; review mentor |
| 13 Nov (+ minggu 2) | Buffer. Kalau molor, pakai buffer, **bukan malam/Minggu** |

## 9. Selesai M1 bila

- PR #1 merged, `docs/testing_strategy.md` ada.
- Rozie bisa menjelaskan dalam 2 menit: test apa di layer mana dan kenapa.
- Q10, Q11, Q12, Q13 dari baseline bisa dijawab tanpa docs.
- Baru setelah itu buka M2 (incremental + snapshots).

## 10. Di luar scope M1

CI/CD & state (M3), governance (M4), Airflow (M5), growth accounting, Snowflake cost/RBAC, AI/LLM, experimentation, OMSA, video YouTube panjang tanpa output.

## 11. Pertanyaan terbuka (jangan diputuskan sekarang)

- OMSA Spring 2027 (kelas mulai 11 Jan 2027; opsi diundur). Cert dbt ditarget sebelum 11 Jan, atau OMSA diundur. Bahas saat Rozie sudah lebih tenang.
- Apakah "muak experimentation" itu capek/jenuh atau arah karier. M0–M2 jadi data awal; tidak ada kesimpulan sebelum itu.
- Snowflake: trial vs akun baru; CI di M3 sebaiknya pakai DuckDB pada subset data.


## Personal Response M1

### Loop A 091126

_beda unit test vs data test; kapan unit test layak dan kapan tidak_

1. Loop A - beda unit test vs data test; kapan unit test layak dan kapan tidak
   1. Unit Test ini lebih ke ketika kita pengen check output dari logic dari model kita sesuai dengan input kita / nggak
      1. dimana kita perlu define sendiri input dan outputnya
      2. Kapan model ini layak digunakan - semisal ada perhitungan kompleks within the model - ini ideal untuk kita gunakan sebelum value masuk ke downstream yang lebih jauh

   2. While Data Test - dimana ini dibagi 2 - generic dan singular
      1. generic ini ada 2 juga:
         1. generic, built-in: unique, not null, accepted_values, relationship
         2. generic, custom: sedangkan ini ketika kita bikin generic tapi based on our internal defined query 
         3. sebenernya both generic diatas ini kuncinya lebih ke gimana kita bisa pake berkali-kali sih dari data test ini
      2. Terakhir ada singular 
         1. ini mirip sebenernya sama custom, generic - bedanya lebih specified untuk certain use case / model aja.
      3. Kapan data test ini layak digunakan - ketika kita ingin menguji kebeneran suatu value/ combinedd -
   3. In conclusion, what the difference between unit test and data test
      1. dimana value -> data test, while logic -> unit test
      FEEDBACK
      2. The main difference is not limited on the value / logic check, but it's more than that. 
        1. Unit test checks based on GIVEN INPUT AND OUTPUT
        2. While data test checks based on ACTUAL DATA

### Loop B 091126

_Rozie bisa menjelaskan kenapa ini (Loop B: Generic, Custom Test) macro Jinja dan beda dari singular test._

1. What does macro Jinja does there:
  1. assert_non_negative(model, column_name) is similar with def function(var_a, var_b) on python.
  2. the flow is:
    1. assert_non_negative is defined on certain column.
    2. dbt fill the render for each SQL based on certain model and column
    3. then, the data test run
  3. It's become reusable since there is a macro there {{ model}} or {{ column_name }} where dbt can replace later once SQL will be run for each column that attributed with the data test.
2. Perbedaan mendasar between Generic, Custom Test dengan Singular Test
  1. Custom, Generic - ini harapannya logic ini bisa diterapkan di banyak kondisi untuk menguji suatu value sesuai atau nggga. (Analogi: Generic means banyak, repateable usage.)
  2. Singular test: misal untuk menguji apakah ada value yang dimana is_delivered is true, dan sub_discount nya negative (not expected) -> karna ini udah spesifik (penggunaannya) better langsung mengunakan singular test (analoginya dari kata SINGULAR, Single)

### Loop C 091126
#### Tasls
1. Di test untuk fact besar: tambahkan where (mis. hanya N hari terakhir) agar tidak scan seluruh tabel
2. Satu test dengan warn_if / error_if (mis. warn_if: ">0", error_if: ">100"), lalu buktikan: 40 baris gagal → WARN dan downstream tetap build; 150 baris → FAIL dan downstream SKIP (di dbt build).
3. store_failures pada satu test; lihat tabel baris-gagalnya di warehouse.
4. Tambah freshness di sources.yml (loaded_at_field + warn_after/error_after). Jalankan dbt source freshness._

#### Output: 
#### Loop C.1 — Add where for more specific test
- **Test:** added where into `not_null` on `not_null_fact_order_item_order_item_id`
- **Config:** `where order_date between "2026-06-24" and "2026-06-30"`
- **Output:** 
   - Test passed because no order_item_id was NULL among the rows selected by the date filter
   - the output of the query is available on [target/run/dbt_cert_prep/models/core/fact_order_item/fact_order_item.yml](../dbt-project/target/run/dbt_cert_prep/models/core/fact_order_item/fact_order_item.yml/not_null_fact_order_item_order_item_id.sql)
      - the query contained select order_item_id from (select * from "dbt"."main"."fact_order_item" where order_date >= date '2026-06-24' and order_date <= date '2026-06-30') dbt_subquery where order_item_id is null
- **Command:** dbt test -s not_null_fact_order_item_order_item_id 
- **What I learned:** 
  - Even generic, built-in test can be configured/ specified (using WHERE)
  - the production code should be guaranteed using dyanmic time range (e.g. last 3 days: where order_date >= current_date - 
  7 days') -- DON'T FORGET TO SHOW THE FALSE (using >= instead of <= or <)
  - The SQL output is available on target/run/-<model>

**YAML config example:**
```yml
- name: order_item_id
  data_tests:
    - not_null:
        config:
          where: "order_date >= date '2026-06-24' and order_date <= date '2026-06-30'"
```
This limits the test to that date range; PASS does not prove the range contains any orders.


#### Loop C.2 — Warning and error thresholds

- **Test:** `unique_dim_restaurant_restaurant_id` and `unique_restaurant_id`
- **Config:** `warn_if: >= 1`, `error_if: >3, store_failures: true`
- **Warning experiment:** 1 failing rows → [observed status]; downstream model [built] with warn.
- **Command:** dbt test -s +dim_restaurant
- **What I learned:** The test counts failing results and compares that count with the configured thresholds. In `dbt build`, an error can cause dependent nodes to be skipped; a warning lets them continue.

**YAML config example:**
```yml
- name: restaurant_id
  data_tests:
    - unique:
        config:
          severity: error
          warn_if: ">=1"
          error_if: ">3"
```
1–3 duplicated IDs → WARN; 4 or more → ERROR.

#### C.3 — store_failures

- **Test:** `unique_dim_restaurant_restaurant_id`
- **Experiment:** Intentionally duplicated `restaurant_id` 531342.
- **Command:** 
   - run the test: `dbt test -s +dim_restaurant`
   - examine the failure output:   select * from "dbt"."main_dbt_test__audit"."unique_dim_restaurant_restaurant_id"
- **Result:** This test reported `WARN 1`. Its audit table recorded `restaurant_id = 531342` with `n_records = 2`.
- **What I learned:** The test counted one duplicated ID as one failure, even though the ID appeared in two rows.
- **Cleanup:** [Record the result after removing the duplicate and rerunning the test.]

**YAML config example:**
```yml
- name: restaurant_id
  data_tests:
    - unique:
        config:
          store_failures: true
```
dbt saves failing IDs to an audit table when this test runs.

#### Loop C.4 — Source freshness

- **Source:** `zomato_seed`, pointing to tables created from seeds in DuckDB.
- **Default rule:** Use `order_timestamp`; WARN after 1 day and ERROR after 180 days.
- **`orders`:** Inherits the default rule. Result: **WARN**.
- **`reviews`:** Overrides the time field with `cast(review_date as timestamp)` and sets ERROR after 3 days. Result: **ERROR STALE**.
- **`users`:** Sets `freshness: null`, so dbt does not check it.
- **Command:** `dbt source freshness`
- **What I learned:**
  - dbt compares the current time with the latest (`MAX`) timestamp on defined column (e.g. `ingested_at`) for each checked table. 
  - A table can inherit (mewarisi tingkat diatasnya) the source-level rule, override it (specify lebih detail), or opt out (freshness: null).
  - Here the timestamps represent order/review dates, not when the CSV files were loaded.
  - example is here: [_sources.yml](../dbt-project/seeds/_sources.yml)

**YAML config example (current `_sources.yml`):**
```yml
sources:
  - name: zomato_seed
    schema: main
    config:
      loaded_at_field: order_timestamp
      freshness:
        warn_after: {count: 1, period: day}
        error_after: {count: 3, period: day}
    tables:
      - name: orders
      - name: reviews
        config:
          loaded_at_field: cast(review_date as timestamp)
          freshness:
            warn_after: {count: 1, period: day}
            error_after: {count: 3, period: day}
      - name: users
        config:
          freshness: null
```
The current source-level ERROR threshold is 3 days; the WARN result recorded above came from an earlier run with a 180-day threshold.
