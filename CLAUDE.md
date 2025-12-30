# Watchmen

## Project Overview

Community-driven, transparent watchlist repository for the Hive blockchain. Aggregates lists of suspicious accounts (scam, AML, fraud) and DMCA URLs from multiple sources into unified output formats. Serves as a reference for exchanges, dApps, and community tools to identify bad actors.

**Note:** This watchlist only covers Hive-native accounts. Accounts on forked networks (Steem, etc.) are not covered.

## Tech Stack

- **Languages:** Bash scripts
- **Tools:** wget (for fetching upstream sources), grep, sort, standard Unix utilities
- **Input formats:** JavaScript (.js), TypeScript (.ts), JSON (.json), plain text (.txt)
- **Output formats:** Flat text lists (one account per line)

## Directory Structure

```
input/              # Raw input files from various sources
├── community/      # Community-contributed lists (.txt)
├── condenser/      # From openhive-network/condenser (BadActorList, DMCA, GDPR)
├── condenser-wallet/  # From condenser-wallet
├── denser/         # From openhive-network/denser
└── ecency/         # From ecency/hivescript

output/             # Generated output (do not edit manually)
└── flat/
    └── badactors.txt  # Consolidated, sorted, deduplicated list

scripts/            # Processing scripts
├── compile_badactors.sh  # Merge all inputs into output/flat/badactors.txt
└── update_inputs.sh      # Fetch latest from upstream sources
```

## Development Commands

### Update inputs from upstream sources
```bash
./scripts/update_inputs.sh
```
Reads `sources.list` files in each `input/<provider>/` directory and downloads latest versions via wget.

### Compile consolidated bad actors list
```bash
./scripts/compile_badactors.sh
```
Processes all input files (JS, TS, JSON, TXT) and outputs deduplicated sorted list to `output/flat/badactors.txt`.

## Key Files

| File | Purpose |
|------|---------|
| `scripts/compile_badactors.sh` | Main aggregation script |
| `scripts/update_inputs.sh` | Upstream source fetcher |
| `input/*/sources.list` | URLs for upstream data sources |
| `output/flat/badactors.txt` | Final consolidated output |

## Coding Conventions

- Input files organized by provider/source in `input/<provider>/`
- Each provider directory may contain a `sources.list` with upstream URLs
- Community contributions go in `input/community/` as `.txt` files
- One account name per line in text files
- Scripts use `set -euo pipefail` for strict error handling

## Adding New Data

1. **From existing source:** Add URL to appropriate `input/<provider>/sources.list`
2. **Community submission:** Add `.txt` file to `input/community/`
3. **New provider:** Create `input/<provider>/` directory with `sources.list`

After adding, run:
```bash
./scripts/update_inputs.sh      # If using sources.list
./scripts/compile_badactors.sh  # Regenerate output
```

## CI/CD Notes

No `.gitlab-ci.yml` present. Pipeline automation could be added to:
- Periodically run `update_inputs.sh` to fetch upstream changes
- Run `compile_badactors.sh` to regenerate outputs
- Commit and push updated `output/flat/badactors.txt`

## License

MIT License - see LICENSE file.
