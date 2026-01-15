# watchmen

[![Powered by Hive](https://img.shields.io/badge/Powered%20by-Hive-green?logo=hive_blockchain&logoColor=e31337)](https://hive.io)
[![Development on Community GitLab](https://img.shields.io/badge/Development%20on-Community%20GitLab-orange)](https://gitlab.syncad.com/hive/watchmen)

Community-driven, transparent watchlist of suspicious Hive accounts & DMCA URLs; a reference for scam, AML, and DMCA monitoring

---

## Overview

Watchmen is a simple repository for collecting and sharing lists of Hive accounts (and specific post URLs) that have been flagged for potential fraud, money laundering, or copyright issues. Contributors can add raw input files, which will later be processed and published in various formats.

Use our community-run gitlab instance to contribute: https://gitlab.syncad.com/hive/watchmen

---

### Important Note on Forked Networks

Accounts on Steem 💩™, or any other fork are **not** covered by this watchlist. Always assume non-Hive–native accounts are untrustworthy.

---

## Directory Structure

```
.
├── input/
│ ├── ecency/
│ │ └── <your‐files‐here>
│ ├── hiveabuse/
│ │ └── <your‐files‐here>
│ └── …
├── output/ # (generated automatically by pipelines)
│ ├── flat/
│ ├── json/
│ └── csv/
├── scripts/ # (scripts for processing inputs)
│ └── …
├── schemas/ # (optional validation schemas)
│ └── …
├── README.md
└── LICENSE
```

---

### Adding Input Files

**Community submissions:**
Add your file to `input/community/` and submit a merge request.

- One account per line, plain text (`.txt`)
- Use a single file with a short, meaningful name
- Append new entries to your existing file, i.e. don't create numbered versions

A 10-account update should show 10 new lines, not thousands of reshuffled ones.

Sorting: not required for append-only updates; sort alphabetically if reorganizing the entire file.

**Automated feeds:**
If you maintain a programmatic list, open an issue so we can add a fetch script.

---

## Disclaimer

Entries are community‐submitted and may not be 100% accurate. Downstream consumers (exchanges, dApps) should verify before taking any permanent blocking actions. Corrections and removals can be requested via issues or pull requests.
Operated purely on AS_IS_OR_GTFO basis.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
