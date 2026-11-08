# M0 Baseline — Hasil Rozie + Feedback (3 Nov 2026)

> File ini self-contained untuk dibawa ke Claude Code. Menggantikan `m0_baseline.md` dan `m0_answer_key.md` (isi keduanya sudah dilebur di sini).

## Konteks singkat

- Rozie (Oji): Product Analyst 6+ tahun, target Senior Analytics Engineer remote (global, harapan AU/SEA) dari Malang.
- Penilaian dari sesi sebelumnya: **modeling-strong, operations-weak**. Gap senior-AE: testing depth, incremental+snapshot dengan bukti, CI/CD+state, governance, Airflow reliability.
- Baseline ini: 16 soal original, 7 domain study guide dbt Analytics Engineering v1.11, dikerjakan tanpa docs/AI, dengan kolom confidence (1–3).
- Kondisi saat mengerjakan: lagi capek dan anxious setelah melihat banyak "gapaham". Bukan alasan untuk ngebut; lihat `m1_action_items.md` untuk ritme.

## Ringkasan hasil

- Benar penuh: Q1, Q7
- Setengah benar: Q5, Q12, Q15
- Kosong ("gapaham"): 11 soal
- **Salah tapi yakin: 0.** Kalibrasi dirinya bagus; gap-nya punya alamat jelas.
- Skor kasar ~3.5/16 (setengah benar = 0.5). Ini titik awal, dibandingkan dengan baseline ulang di M6.

| Domain | Skor | Modul |
| --- | --- | --- |
| 1 Develop & optimize | 1/3 | M2 |
| 2 Governance | 0.5/2 | M4 |
| 3 Debugging | 1/2 | M1, M3 |
| 4 Pipelines | 0/2 | M3, M5 |
| 5 Testing | 0.5/3 | M1 |
| 6 External deps | 0/2 | M1, M4 |
| 7 State | 0.5/2 | M3 |

Cocok dengan prediksi assessment; plan M1–M6 tidak berubah.

---

## Jawaban per soal: jawaban Rozie → verdict → koreksi

### Domain 1 — Develop & optimize

**Q1.** `fct_events` 200M baris, append-only, event telat sampai 2 hari. Pilihan terbaik?
- Rozie: **B** (confidence "8", skala sebenarnya 1–3, anggap tinggi). Alasan: tetap perlu fact sebagai table supaya siap/cepat saat run; cukup update 3 hari terakhir karena telatnya cuma 2 hari.
- Verdict: ✅ benar, reasoning benar.
- Catatan: incremental tetap tabel fisik; lookback 3 hari = buffer 1 hari; `unique_key` + `merge` bikin baris telat ke-update, bukan duplikat.

**Q2.** Flag untuk ngetes logic di subset waktu dari data asli (bukan data kosong), dan bedanya dengan `--empty`.
- Rozie: "kurang paham"
- Koreksi: `--sample` = jalan di subset berbasis waktu dari data asli (butuh `event_time` terdefinisi). `--empty` = 0 baris, cek SQL valid + schema. `--empty` = "SQL gue valid?"; `--sample` = "hasil gue masuk akal di data kecil?".

**Q3.** Kapan snapshot `check` bukan `timestamp`?
- Rozie: "kurang paham"
- Koreksi: `timestamp` bila ada kolom `updated_at` yang bisa dipercaya (default). `check` bila tidak ada; dbt membandingkan nilai kolom-kolom tertentu.

### Domain 2 — Governance

**Q4.** Contract enforced, kolom `status` dihapus dari SELECT → apa yang terjadi?
- Rozie: "kurang paham"
- Koreksi: build **gagal** karena shape ≠ kontrak. Contract dicek *sebelum* data terbentuk; test dicek *sesudah*.

**Q5.** Rename kolom di `fact_order` yang dipakai 3 tim downstream. Pendekatan aman?
- Rozie: "update naming berikut on its downstream, then info impacted/ related team for that"
- Verdict: ⚠️ setengah benar.
- Koreksi: informasi ke tim = benar dan tetap perlu. Kurangnya: rename serentak memaksa semua downstream ganti bareng. Mekanisme dbt: **model versions**. Buat `fact_order` v2, tandai v1 dengan `deprecation_date`, tiap tim pindah ke `ref('fact_order', v=2)` sesuai jadwal sendiri.

### Domain 3 — Debugging

**Q6.** Di `target/` mana SQL persis yang dikirim ke warehouse?
- Rozie: "kurang paham"
- Koreksi: `target/compiled/` = SELECT hasil render Jinja. `target/run/` = statement lengkap yang dikirim (termasuk `create table as` / `merge`). Error warehouse → lihat `run/`.

**Q7.** Jodohkan flag: `--fail-fast`, `--warn-error`, `--full-refresh`.
- Rozie: fail-fast = b (stop eksekusi di kegagalan pertama), warn-error = a (warning jadi error), full-refresh = rebuild model `is_incremental()` dari 0.
- Verdict: ✅ benar semua.

### Domain 4 — Pipelines

**Q8.** Apa yang dilakukan `dbt retry`?
- Rozie: "gapaham"
- Koreksi: mengulang dari node yang gagal (+ yang ke-skip karenanya), tanpa mengulang node sukses. Membaca `run_results.json` invocation terakhir di `target/`.

**Q9.** Beda `--defer` vs `dbt clone`; kapan pilih clone?
- Rozie: "gapahamgapaham"
- Koreksi: `--defer`: `ref()` ke node upstream yang tidak dibuild diarahkan ke objek di production (butuh `--state` + manifest prod). `dbt clone`: membuat salinan (zero-copy di warehouse yang support) objek prod *ke schema sendiri*. Pilih clone bila objeknya harus benar-benar ada di schema dev: incremental model (butuh tabel existing), atau BI tool yang menunjuk schema dev.

### Domain 5 — Testing

**Q10.** Unit test vs data test.
- Rozie: "gapaham"
- Koreksi: unit test = tes *logic transformasi* dengan input mock (`given`) dan output yang diharapkan (`expect`) di YAML; deterministik, murah, jalan sebelum build. Data test = cek data nyata setelah tabel terbentuk. Unit test untuk logic bercabang (CASE, window, date math, regex); jangan untuk select/rename/pass-through.

**Q11.** Test `assert_non_negative` dipakai di banyak kolom/model: tipe, lokasi, konstruk Jinja?
- Rozie: "gapaham"
- Koreksi: custom **generic** test: `{% test assert_non_negative(model, column_name) %} ... {% endtest %}` di `tests/generic/` (atau `macros/`), return baris yang melanggar; dipanggil dari YAML seperti test bawaan.

**Q12.** `warn_if: ">0"`, `error_if: ">100"`, 40 baris gagal → hasil? Apakah downstream jalan di `dbt build`?
- Rozie: "model tidak terbangun, downstream tetap jalan dengan data per kemarin / belum di update harusnya"
- Verdict: ⚠️ setengah benar.
- Koreksi: 40 baris lewat `warn_if` tapi belum lewat `error_if` → **WARN, bukan FAIL** → downstream tetap build dengan data hari ini. Jawabannya benar untuk kasus *FAIL* (mis. 150 baris): di `dbt build` downstream di-SKIP sehingga data stale. Pemahaman "fail menghalangi downstream" sudah ada; yang kurang: ambang `warn_if`/`error_if` menentukan kapan warn jadi fail.

### Domain 6 — External dependencies

**Q13.** Minimum YAML agar `dbt source freshness` jalan?
- Rozie: "gapaham"
- Koreksi: blok `freshness` dengan `warn_after`/`error_after` (count + period), plus kolom waktu muat `loaded_at_field` (di adapter tertentu bisa pakai metadata warehouse; cek sintaks sesuai versi dbt).

**Q14.** Apa yang dilakukan dan tidak dilakukan `exposure`?
- Rozie: "gapaham"
- Koreksi: mendokumentasikan *consumer* downstream (dashboard, app, model ML) di DAG: owner, tipe, `depends_on`. **Tidak** membangun apa pun di warehouse, tidak enforce apa pun. Gunanya: lineage + `dbt ls --select +exposure:nama`.

### Domain 7 — State

**Q15.** Jelaskan `dbt build --select state:modified+ --defer --state ./prod-artifacts`.
- Rozie (verbatim): "dbt build ini buat run dbt run dan dbt test secara bersamaan (artinya dbt run itu bikin model, dan dbt test itu melakukan test yang di define di yaml dari model tersebut, misal not_null, or unique) | --select atau -s state:modified (artinya melakukan build model dari yang dirumah dan semua di downstream) | kalo --defer ini kurang paham cuman AFAIK ini kita run table yang di downstream tapi yang udah ada di production kalo gasalah"
- Verdict: ⚠️ setengah benar, lumayan bagus.
- Koreksi:
  - `dbt build` = seed + run + snapshot + test dalam urutan DAG; poin kuncinya: test jalan *sebelum* downstream-nya, dan test gagal → downstream di-skip. ("Run + test bareng" = arah benar; urutannya detail penting.)
  - `state:modified` = **hanya node yang berubah** vs manifest pembanding; downstream baru ikut kalau `state:modified+`. Rozie menggabungkan keduanya.
  - `--defer`: arah benar (pakai yang ada di production), tapi yang di-defer itu **upstream** yang tidak dibuild, bukan downstream.
  - `--state ./prod-artifacts` = folder berisi `manifest.json` dari run production/main.

**Q16.** Hanya yang berubah tanpa downstream?
- Rozie: "ga paham"
- Koreksi: `state:modified` tanpa `+`.

---

## Insight utama

1. Tidak ada blind spot: tidak pernah yakin-tapi-salah.
2. Tiga jawaban setengah benar (Q5, Q12, Q15) sudah dekat; tinggal satu konsep tiap soal.
3. Sebelas "gapaham" = topik yang memang belum pernah dikerjakan (unit test, custom generic test, configs, freshness, exposures, retry/clone/defer, contracts, versions), bukan topik yang lupa.
4. Baseline ulang di M6 (Minggu 9–10) memakai 16 soal yang sama + 2–3 practice test v1.11.
