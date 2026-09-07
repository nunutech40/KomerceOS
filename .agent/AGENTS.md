# Agent Rules — KomerceOS

## Knowledge Persistence (Memory Global)

**Setiap kali selesai mengerjakan sesuatu yang punya context penting** (fitur baru, bugfix, refactor, perubahan endpoint, arsitektur, dll), **wajib simpan ke Knowledge Items global**:

```
C:\Users\rilas\.gemini\antigravity-ide\knowledge\<nama-topik>\
├── metadata.json
└── artifacts\
    └── <nama-topik>.md
```

### Format metadata.json

```json
{
  "summary": "Ringkasan singkat 1-2 kalimat tentang apa yang dikerjakan",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ",
  "project": "NamaProject",
  "references": [
    "path/to/relevant/file1",
    "path/to/relevant/file2"
  ]
}
```

### Format artifact .md

Ikuti format skill `save-research`:
- Summary (2-3 kalimat)
- File yang relevan
- Architecture / Data Flow
- Patterns yang diikuti
- Risks & Edge Cases
- Notes
- Changelog

### Aturan Versioning

- **File sudah ada** → UPDATE konten, update `updated_at` dan `version`, tambah changelog entry. Jangan duplikat.
- **File belum ada** → Buat baru dengan `version: 1`

### Kapan Wajib Simpan

- Setelah mengubah endpoint / response format
- Setelah refactor arsitektur atau flow data
- Setelah menyelesaikan fitur baru
- Setelah fix bug non-trivial
- Setelah menemukan pattern/gotcha penting di codebase
