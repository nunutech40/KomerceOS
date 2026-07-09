---
description: Build rich context before coding. Adapted from HumanLayer's Context Engineering methodology (Factor 3 + Factor 13).
---

# 🧠 Context Engineering Workflow

Memastikan AI punya konteks yang cukup sebelum mulai ngoding.
Diadaptasi dari HumanLayer's **"Own Your Context Window" + "Pre-fetch All Context"**.

**Output: File research di `.agent/outputs/research/[topik].md`**

---

## Kapan Pakai Workflow Ini?

- Mengerjakan fitur baru (sebelum `/add_feature`)
- Debugging masalah yang kompleks (sebelum `/solve-hard-problems`)
- Refactoring kode yang saling terkait
- Onboarding ke fitur yang belum pernah disentuh

---

## Step 1: Pre-fetch Context

**→ Jalankan skill `pre-fetch-context`**

Skill ini akan:
- Scan file terkait (features, core, DI, router)
- Trace data flow end-to-end
- Cek KI dan previous outputs
- Cari referensi pattern internal

---

## Step 2: Impact Analysis

**→ Jalankan skill `independence-check`**

Tentukan apakah perubahan isolated atau menyenggol shared code.

---

## Step 3: Synthesize & Confirm

### 3.1 Rangkum Temuan
```
Sampaikan ke user:
- "Layer yang terlibat: ..."
- "Pattern yang diikuti: ... (referensi: <file>)"
- "File shared yang terpengaruh: ..."
- "Potential risks: ..."
```

### 3.2 Confirm
```
"Pemahaman sudah benar? Ada yang perlu dipertimbangkan?"
```

---

## Step 4: Simpan Research

**→ Jalankan skill `save-research`**

---

## Tips

### DO ✅
- **Baca dulu, coding belakangan**
- **Pre-fetch aggressively** — lebih baik kebanyakan context
- **Ikuti pattern yang sudah ada**
- **Simpan research** — selalu save ke `.agent/outputs/research/`

### DON'T ❌
- **Jangan langsung edit** tanpa baca file terkait
- **Jangan asumsi** pattern yang belum diverifikasi
- **Jangan buang research** — simpan untuk sesi berikutnya
