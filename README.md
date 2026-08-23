# arc42-c4

A portable, `adr-tools`-style Bash CLI for initialising and managing **Arc42 + C4 Model** architecture documentation workspaces using AsciiDoc.

Inspired by [`adr-tools`](https://github.com/npryce/adr-tools) and the documentation conventions of [emonito](https://github.com/SentimentGroup/emonito).

---

## Features

- **`arc42-c4 init`** — Scaffolds a complete Arc42 + C4 workspace in seconds: all 13 section files, `workspace.dsl`, subdirectories, `README.adoc`, and ADR #0001
- **`arc42-c4 new`** — Adds any document type with auto-numbering, slug generation, and (for ADRs/TDRs) automatic injection into the Arc42 aggregator section
- **`arc42-c4 generate`** — Builds HTML and PDF reports; exports Structurizr DSL → PlantUML via Docker
- **`arc42-c4 list`** — Lists documents with status from NOTE blocks; tasks support a `--board` Kanban view

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

**Task Classes** (set with `-c CLASS` on `arc42-c4 new task`):

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
git clone https://github.com/yourorg/arc42-c4.git
cd arc42-c4

# Install system-wide (default: /usr/local/bin)
sudo make install

# Or install for current user only
make install PREFIX=~/.local
```

**Prerequisites (install once):**

```bash
gem install asciidoctor asciidoctor-pdf asciidoctor-diagram
# Docker must be running for `arc42-c4 generate` (DSL export step)
```

### Uninstall

```bash
sudo make uninstall
```

---

## Quick Start

```bash
# In your project directory:
arc42-c4 init documentation -n "Order Service" -a "Jane Doe <jane@acme.com>"

# Add an Architecture Decision Record
arc42-c4 new adr "Use PostgreSQL as the operational database"

# Add a Technical Debt/Risk Record
arc42-c4 new tdr "No retry logic in payment processor"

# Add a project epic (with Gantt timeline template)
arc42-c4 new epic "Migrate to event-driven architecture"

# Add tasks to the board (standard and scientific classes)
arc42-c4 new task -c FEAT "Add OAuth2 login flow"
arc42-c4 new task -c BUG "Memory leak in NLP worker"
arc42-c4 new task -c HYPO "Validate caching latency improvement"

# View tasks as a Kanban board (grouped by status)
arc42-c4 list task --board

# Add a meeting log (agenda + minutes)
arc42-c4 new meeting "Sprint 12 Planning"

# Add a scientific experiment
arc42-c4 new experiment "Redis vs Memcached for session storage"

# Add a scientific experiment with a Jupyter notebook companion
arc42-c4 new experiment --notebook "Transformer fine-tuning benchmark"

# Add other document types
arc42-c4 new data-card "Raw Order Events"

# Add a Model Card
arc42-c4 new model-card "Fraud Detection Classifier"

# Add a Runbook
arc42-c4 new runbook "Deploy to Kubernetes Production"

# Add a Coding/Design Guideline
arc42-c4 new guideline "REST API Design Standards"

# Build HTML + PDF reports
arc42-c4 generate

# List all ADRs with status
arc42-c4 list adr

# List all document types and counts
arc42-c4 list
```

---

## Commands

| Command | Description |
|---|---|
| `arc42-c4 init [DIR] [-n NAME] [-a AUTHOR]` | Initialise workspace |
| `arc42-c4 new <type> <title..> [-s NUM] [-c CLASS] [--notebook]` | Create a new document |
| `arc42-c4 generate [--html\|--pdf\|--skip-dsl]` | Build HTML and PDF |
| `arc42-c4 list [type] [--board]` | List documents |
| `arc42-c4 help [command]` | Show help |

Run `arc42-c4 help <command>` for detailed options.

---

## Workspace Structure

After running `arc42-c4 init`, your project will contain:

```
your-project/
├── .arc42-c4-dir              # Points to documentation root
├── README.adoc                # Project README
└── documentation/
    ├── <project>.adoc         # Master AsciiDoc aggregator (rendered to HTML+PDF)
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
cp /usr/local/share/arc42-c4/templates/doc-types/adr.adoc documentation/templates/adr.adoc
# Edit as needed — arc42-c4 will prefer this over the built-in template
```

---

## Generating Documentation

```bash
# Full build (requires Docker for DSL export)
arc42-c4 generate

# HTML only, skip DSL export (no Docker needed)
arc42-c4 generate --html --skip-dsl

# PDF only
arc42-c4 generate --pdf

# Skip cleaning stale SVG caches
arc42-c4 generate --skip-clean
```

---

## Running Tests

```bash
make test
```

Tests run entirely in a temp directory — no Docker required.

---

## Design Decisions

- **Modelled on `adr-tools`**: Same dispatcher + sub-script + template pattern for maximum simplicity and hackability
- **AsciiDoc + Kroki.io**: Diagrams rendered server-side — no local PlantUML install required for HTML builds
- **Auto-include injection**: New ADRs and TDRs are automatically wired into the Arc42 aggregator sections via `awk`
- **Zero framework dependencies**: Pure Bash — works on any Unix system with `bash`, `sed`, `awk`, `find`

---

## Acknowledgements

- [arc42](https://arc42.org) by Gernot Starke (CC BY-SA 4.0)
- [C4 Model](https://c4model.com) by Simon Brown
- [adr-tools](https://github.com/npryce/adr-tools) by Nat Pryce (GPL-3.0)
- [Structurizr](https://structurizr.com) by Simon Brown
