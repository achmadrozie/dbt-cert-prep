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

Repo kerja: `zomato-dbt-layer-refactor` (atau fork `zomato-production-grade`). Ini asumsi dari sesi sebelumnya; konfirmasi dengan `ls`/`dbt ls` sebelum menulis apa pun:
- model `int_order_financials`, mart `fact_order` / `fact_order_item`
- `_sources.yml` sudah ada
- ada 7 singular reconciliation test di `tests/`
- versi dbt target: Core 1.11 (unit tests butuh ≥1.8)

Sintaks YAML di bawah hanyalah skeleton; **cek terhadap docs untuk versi dbt di repo** (konfigurasi freshness/test config bisa berada di blok `config:` pada versi terbaru).

## 3. Loop A — Unit test (hari 1–2)

**Baca (≤20 menit):** dbt Learn *Unit Testing*; docs "Unit tests". Docs untuk dicari saat build, bukan dibaca tuntas.

**Build:**
1. Buka `int_order_financials`; tulis di kertas: kolom apa yang punya logic bercabang?
2. Tulis 2 unit test di YAML:
   - `discount > subtotal` (apa yang seharusnya terjadi pada net amount?)
   - `fee` null
3. Skeleton:
```yaml
unit_tests:
  - name: test_int_order_financials_discount_exceeds_subtotal
    model: int_order_financials
    given:
      - input: ref('<upstream_model>')
        rows:
          - {order_id: 1, <subtotal_col>: 100, <discount_col>: 150}
    expect:
      rows:
        - {order_id: 1, <expected_cols...>}
```
4. Jalankan: `dbt test --select int_order_financials,test_type:unit`.
5. **Sengaja rusakkan logic** sampai test merah, lihat diff output, lalu kembalikan.

**Selesai bila:** 2 unit test hijau; satu kali percobaan merah yang disengaja dan dipahami.

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
