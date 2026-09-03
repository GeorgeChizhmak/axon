# 🧠 axon

An ultra-portable, dependency-free Bash CLI that serves as the central nervous system for your engineering workspace. It unifies **Software Architecture (Arc42 + C4)**, **Scientific R&D Logs**, and **Agile Day-to-Day Tasks** into a single, version-controlled git directory using AsciiDoc.

Inspired by [`adr-tools`](https://github.com/npryce/adr-tools).

## Why Axon?

Architecture docs, task boards, and experiment notebooks usually live in separate tools and drift apart. Axon treats them as one nervous system: decisions, work, and evidence stay linked in a single AsciiDoc workspace you own. Blueprints guide execution, science validates choices, and the trail stays in git—not locked in a SaaS silo.

---

## Features

- **`axon init`** — Scaffolds a complete Arc42 + C4 workspace in seconds: all 13 section files, `workspace.dsl`, subdirectories, `README.adoc`, and ADR #0001
- **`axon new`** — Adds any document type with auto-numbering, slug generation, and (for ADRs/TDRs) automatic injection into the Arc42 aggregator section
- **`axon generate`** — Builds HTML and PDF reports; exports Structurizr DSL → PlantUML via Docker
- **`axon board`** — Regenerates a visual Kanban `BOARD.adoc` (epic swimlanes) and compiles it to HTML
- **`axon list`** — Lists documents with status from NOTE blocks; tasks support a `--board` Kanban view

**Supported document types:**

| Type | Directory | Description |
|---|---|---|
| `adr` | `adrs/` | Architecture Decision Records |
| `tdr` | `tdrs/` | Technical Debt / Risk Records |
| `experiment` | `experiments/` | Tracked experiments (optional companion `.ipynb`) |
| `epic` | `epics/` | High-level project epics with PlantUML Gantt timelines |
| `task` | `tasks/` | Project & engineering tasks with class taxonomy |
| `meeting` | `meetings/` | Meeting agendas and minutes |
| `data-card` | `data-cards/` | Dataset documentation |
| `model-card` | `model-cards/` | ML model documentation |
| `runbook` | `runbooks/` | Operational runbooks |
| `guideline` | `guidelines/` | Coding & design guidelines |

**Task Classes** (set with `-c CLASS` on `axon new task`):

| Class | Category | Description |
|---|---|---|
| `BUG` | Standard | Flaws, errors, or unexpected behavior |
| `FEAT` | Standard | New features or functional enhancements |
| `TASK` | Standard | Routine engineering work *(default)* |
| `SPIKE` | Standard | Research or proof-of-concept exploration |
| `CHORE` | Standard | Operational updates (CI/CD, build scripts) |
| `EPIC` | Standard | Large objectives that split into sub-tasks |
| `HYPO` | Scientific | Hypothesis testing experiment design |
| `DATA` | Scientific | Data collection, cleaning, or curation |
| `CALIB` | Scientific | Calibration & alignment of models/instruments |
| `REPRO` | Scientific | Reproducibility check of prior results |
| `META` | Scientific | Meta-analysis or literature review |
| `ANLYS` | Scientific | Statistical analysis / post-processing |

---

## Installation

```bash
# Clone this repository
git clone https://github.com/GeorgeChizhmak/axon.git
cd axon

# Install system-wide (default: /usr/local/bin)
sudo make install

# Or install for current user only
make install PREFIX=~/.local
```

**Prerequisites (install once):**

```bash
gem install asciidoctor asciidoctor-pdf asciidoctor-diagram
# Docker must be running for `axon generate` (DSL export step)
```

### macOS

macOS ships with **Bash 3.2** (GPL restriction). Axon requires **Bash 4+** for full compatibility. Install a modern Bash via Homebrew:

```bash
brew install bash
# Verify:
bash --version   # should show 5.x
```

> **Note:** Axon scripts use `#!/usr/bin/env bash`, so as long as Homebrew bash is ahead of `/bin/bash` on your `PATH`, everything works without changing your default shell.

### Uninstall

```bash
sudo make uninstall
```

---

## Quick Start

```bash
# In your project directory:
axon init documentation -n "Order Service" -a "Jane Doe <jane@acme.com>"

# Add an Architecture Decision Record
axon new adr "Use PostgreSQL as the operational database"

# Add a Technical Debt/Risk Record
axon new tdr "No retry logic in payment processor"

# Add a project epic (with Gantt timeline template)
axon new epic "Migrate to event-driven architecture"

# Add tasks to the board (standard and scientific classes)
axon new task -c FEAT "Add OAuth2 login flow"
axon new task -c BUG "Memory leak in NLP worker"
axon new task -c HYPO "Validate caching latency improvement"

# View tasks as a Kanban board (grouped by status)
axon list task --board

# Build a visual HTML board (epic swimlanes + status columns)
axon board

# Add a meeting log (agenda + minutes)
axon new meeting "Sprint 12 Planning"

# Add a scientific experiment
axon new experiment "Redis vs Memcached for session storage"

# Add a scientific experiment with a Jupyter notebook companion
axon new experiment --notebook "Transformer fine-tuning benchmark"

# Add other document types
axon new data-card "Raw Order Events"

# Add a Model Card
axon new model-card "Fraud Detection Classifier"

# Add a Runbook
axon new runbook "Deploy to Kubernetes Production"

# Add a Coding/Design Guideline
axon new guideline "REST API Design Standards"

# Build HTML + PDF reports
axon generate

# List all ADRs with status
axon list adr

# List all document types and counts
axon list
```

---

## Commands

| Command | Description |
|---|---|
| `axon init [DIR] [-n NAME] [-a AUTHOR]` | Initialise workspace |
| `axon new <type> <title..> [-s NUM] [-c CLASS] [--notebook]` | Create a new document |
| `axon generate [--html\|--pdf\|--skip-dsl]` | Build architecture HTML and PDF |
| `axon board [--no-generate\|--html\|--pdf]` | Refresh visual task board and compile |
| `axon list [type] [--board]` | List documents |
| `axon promote <experiment-num> [-t TITLE]` | Promote experiment to ADR |
| `axon version` / `axon --version` | Print version and authorship |
| `axon help [command]` | Show help |

Run `axon help <command>` for detailed options.

---

## Workspace Structure

After running `axon init`, your project will contain:

```
your-project/
├── .axon-dir                  # Points to documentation root
├── README.adoc                # Project README
└── documentation/
    ├── <project>.adoc         # Master AsciiDoc aggregator (rendered to HTML+PDF)
    ├── BOARD.adoc             # Visual task board (generated by `axon board`)
    ├── workspace.dsl          # C4 Model (Structurizr DSL)
    ├── arc42/                 # All 13 Arc42 chapter files
    │   ├── _config.adoc
    │   ├── 01_introduction_and_goals.adoc
    │   ├── ...
    │   ├── 09_architecture_decisions.adoc   ← auto-updated by `new adr`
    │   ├── 11_technical_risks.adoc          ← auto-updated by `new tdr`
    │   └── 13_appendix.adoc
    ├── adrs/                  # Architecture Decision Records
    ├── tdrs/                  # Technical Debt/Risk Records
    ├── experiments/           # Tracked experiments (.adoc + optional .ipynb)
    ├── epics/                 # Project epics (with Gantt timeline)
    ├── tasks/                 # Tasks board (class + kanban)
    ├── meetings/              # Meeting agendas & minutes
    ├── data-cards/            # Dataset documentation
    ├── model-cards/           # ML model documentation
    ├── runbooks/              # Operational runbooks
    ├── guidelines/            # Coding & design guidelines
    └── diagrams/              # Generated C4 PlantUML diagrams
```

---

## Customising Templates

To override a built-in template for your project, create a `templates/` directory inside your docs root and place your custom template there:

```bash
mkdir -p documentation/templates
cp /usr/local/share/axon/templates/doc-types/adr.adoc documentation/templates/adr.adoc
# Edit as needed — axon will prefer this over the built-in template
```

---

## Generating Documentation

```bash
# Full architecture build (requires Docker for DSL export)
axon generate

# HTML only, skip DSL export (no Docker needed)
axon generate --html --skip-dsl

# PDF only
axon generate --pdf

# Skip cleaning stale SVG caches
axon generate --skip-clean
```

### Visual task board

```bash
# Regenerate BOARD.adoc from epics/ + tasks/ and compile to BOARD.html
axon board

# Write BOARD.adoc only (no AsciiDoc gems required)
axon board --no-generate

# Also produce BOARD.pdf
axon board --pdf
```

The board uses one swimlane per epic (plus an Unassigned lane) and columns
TODO / IN-PROGRESS / BLOCKED / DONE. Link a task to an epic by setting
`*Epic:* \`EPIC-0001\`` in the task NOTE block.

---

## Running Tests

```bash
make test
```

Tests run entirely in a temp directory — no Docker required.

---

## Design Decisions

- **Modelled on `adr-tools`**: Same dispatcher + sub-script + template pattern for maximum simplicity and hackability
- **AsciiDoc + Local Rendering**: Diagrams rendered locally — closed on-premise system with no external cloud dependencies
- **Auto-include injection**: New ADRs and TDRs are automatically wired into the Arc42 aggregator sections via `awk`
- **Zero framework dependencies**: Pure Bash — works on macOS and Linux with `bash` 4+, `sed`, `awk`, `find`
- **Cross-platform**: No `grep -P` (PCRE), no `sed -i` without extension; BSD and GNU userland both supported; `declare -A` replaced with portable `case` helpers

---

## Acknowledgements

- [arc42](https://arc42.org) by Gernot Starke (CC BY-SA 4.0)
- [C4 Model](https://c4model.com) by Simon Brown
- [adr-tools](https://github.com/npryce/adr-tools) by Nat Pryce (GPL-3.0)
- [Structurizr](https://structurizr.com) by Simon Brown

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for details.

Copyright (c) 2026 George Chizhmak
