# West Virginia K-12 Board-Meeting Document Corpus

**Academic / public-interest release · School Year 2024-2025**

This dataset is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0). You are free to use this data for academic, research, or journalistic purposes, with attribution. Commercial use is not permitted.

- Please cite this corpus if you use it (see Citation below).
- If you need more than raw data, Noosphere Analytics offers AI-assisted tools for building targeted datasets and uncovering insights. Demo links and contact info are at the end of this file.

```bibtex
@dataset{m_foster_2025_wv_board_corpus,
  author = {Morgan Foster},
  title  = {West Virginia K-12 School-Board Meeting Document Corpus (SY 2024-2025)},
  year   = {2025},
  url    = {https://github.com/noosphereanalytics/WV_2024_2025},
  note   = {Version 1.0. Please cite if used.}
}
```

---

## 1. Overview

This archive contains the most complete public collection (to date) of board-meeting material published by all 55 regular school districts in West Virginia during the 2024-2025 school year.

Documents were gathered by an automated pipeline that:

- crawls district websites,
- scrapes agendas, minutes, contracts, transcripts, etc.,
- classifies each file (by date and document type),
- applies sanity checks,
- stores structured metadata in two SQLite databases.

Document types and descriptions were inferred with the assistance of large language models (LLMs) and manually audited for accuracy.

Raw artifacts (PDFs, TXT conversions, etc.) are available via a separate download link (see Raw Archives).

| Item                   | Count  |
| ---------------------- | ------ |
| Districts covered      | 55     |
| Files discovered       | \~9100 |
| Files in database      | 8100   |
| Download metadata rows | 9094   |

---

## 2. Folder Layout

```
/.
├─ wv_2024_2025.db.gz                    ← main dataset
├─ wv_2024_2025_download_metadata.db.gz ← download metadata
├─ data.tree.txt                         ← tree view of raw archive
├─ queries/                              ← example SQL queries
```

Run:

```
gunzip wv_2024_2025.db.gz wv_2024_2025_download_metadata.db.gz
```

To decompress the SQLite files before use.

---

## 3. Database Schema

### entities

Represents each public body (e.g., a school district).

| Column       | Description                                         |
| ------------ | --------------------------------------------------- |
| entity\_id   | Primary key                                         |
| name         | Canonical name (e.g. `jackson_county_schools`)      |
| entity\_type | Always `school_boards` for this corpus              |
| country      | Country (e.g. `usa`)                                |
| state        | State abbreviation (e.g. `wv`)                      |
| county       | Lowercased/underscored county name (e.g. `jackson`) |
| url          | Public-facing site (optional)                       |
| address      | Contact or mailing address (if available)           |

Unique constraint:

```
(name, country, state, county, entity_type)
```

### meeting\_documents

Each row represents a meeting document (e.g., minutes, proposals, contracts).

| Column                | Description                                              |
| --------------------- | -------------------------------------------------------- |
| meeting\_document\_id | Primary key                                              |
| entity\_id            | Foreign key to `entities`                                |
| date                  | Associated meeting/publication date                      |
| doctype               | Labeled document type (e.g. `MINUTES`, `CONTRACT`, etc.) |
| filename              | Canonical filename of processed file                     |
| source\_url           | Original public-facing file link                         |
| text                  | Extracted text (if available)                            |
| raw\_filename         | Original file name                                       |
| raw\_md5sum           | MD5 of the raw file                                      |
| text\_md5sum          | MD5 of the cleaned text                                  |
| is\_supplementary     | Boolean (0/1) — is this a referenced attachment?         |
| parent\_document\_id  | Optional: links to the document this file supplements    |

### download\_metadata

Tracks provenance for every downloaded file.

| Column                 | Description                                            |
| ---------------------- | ------------------------------------------------------ |
| download\_metadata\_id | Primary key                                            |
| meeting\_document\_id  | Foreign key to canonical document                      |
| download\_url          | Direct download link                                   |
| saved\_as              | Filename used for saving                               |
| source\_page           | Page link from which the file was extracted (optional) |
| md5                    | MD5 of downloaded file                                 |
| downloaded\_utc        | UTC timestamp                                          |
| version                | Download attempt version                               |
| module                 | Python module responsible                              |

---

## 4. Query Example

```sql
SELECT e.name,
       md.date,
       md.filename,
       md.source_url
FROM   meeting_documents md
JOIN   entities e USING (entity_id)
WHERE  LOWER(md.text) LIKE '%executive order%'
   OR  LOWER(md.text) LIKE '%tariff%'
ORDER  BY md.date;
```

---

## 5. Doctype Glossary

| Doctype    | Description                            |
| ---------- | -------------------------------------- |
| AGENDA     | Board meeting agendas                  |
| MINUTES    | Official meeting proceedings           |
| MEMO       | Memoranda or internal reports          |
| PROPOSAL   | Bids, policy drafts, or budget docs    |
| CONTRACT   | Awarded contracts or RFPs              |
| RESOLUTION | Formal board resolutions               |
| ANCILLARY  | Attachments to other meeting materials |
| CALENDAR   | Academic or board calendars            |
| AMENDMENT  | Modified or superseding documents      |
| TRANSCRIPT | Speech-to-text transcriptions          |
| OTHER      | Unclassified/unknown documents         |

---

## 6. Raw Archives

All of the raw data including the database files found here are available at:

https://archive.org/details/wv_2024_2025_noosphere_analytics

---

## 7. Data Directory Structure

Each entity has a canonical path:

```
data/countries/usa/states/wv/counties/<county>/<entity_type>/<entity_name>
```

Inside each:

- `year/` → raw files grouped by year (mostly 2024 & 2025)
- `supplementary/` → extracted files referenced within others
- `processed/` → cleaned and classified `.txt` files

### Processed Filenames

Format: `YYYY-MM-DD-<md5hash>-<document-type>.txt`

### .download

A `.download` file is a JSON record of how a file was downloaded:

```json
{
  "download_url": "https://...",
  "saved_as": "foo.pdf",
  "source_page": null,
  "md5": "abc123...",
  "downloaded_utc": "2025-06-17T03:19:25Z",
  "version": 0,
  "module": "src.interfaces.cli.board_meetings.scrape.pdf_link_extractor"
}
```

### .rename

Each `.rename` file contains two lines:

1. Fully classified `.txt` file path
2. LLM's reasoning for the classification

These serve as a transparent trace of how the classification was done.

---

## 8. Limitations

- Some in-page HTML minutes were not parsed cleanly.
- GPT-4o-mini was used instead of GPT-4o — expect \~25% more classification error.
- \~1,000 documents failed processing (due to OCR or structure).

---

## 9. About Noosphere Analytics

This project is powered by Noosphere Analytics.

Beyond raw data, we build:

- AI-powered scrapers for hard-to-reach data
- Tools that outperform general-purpose LLM notebooks
- End-to-end pipelines for civic transparency

**Demos:**

- [https://noosphereanalytics.com/demos/MOU/](https://noosphereanalytics.com/demos/MOU/)
- [https://noosphereanalytics.com/demos/gender-identity/](https://noosphereanalytics.com/demos/gender-identity/)
- [https://noosphereanalytics.com/demos/book-discussions/](https://noosphereanalytics.com/demos/book-discussions/)

**Contact:**

- Email: [morgan@noosphereanalytics.com](mailto\:morgan@noosphereanalytics.com)
- Web: [https://noosphereanalytics.com](https://noosphereanalytics.com)

---

## 10. Feedback

- Open an issue: [https://github.com/noosphereanalytics/WV\_2024\_2025/issues](https://github.com/noosphereanalytics/WV_2024_2025/issues)
- Email feedback or improvements

**Happy researching!**

