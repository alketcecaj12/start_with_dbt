# learning_dbt

A minimal dbt learning project using **dbt Core** and **DuckDB**. Built to understand the core concepts of dbt from first principles: seeds, models, materializations, tests, and the DAG.

---

## What this project does

Takes 10 rows of synthetic e-commerce order data and transforms it through two layers — staging and marts — into a clean customer summary table with revenue and return metrics.

```
seeds/raw_orders.csv          10 rows, plain text
        ↓  dbt seed
main.raw_orders               physical table in DuckDB
        ↓  stg_orders.sql
main.stg_orders               view — typed and cleaned
        ↓  fct_customer_summary.sql
main.fct_customer_summary     table — one row per customer, business metrics
```

---

## Data journey: how a single row travels through the pipeline

<p align="center">
<svg width="720" viewBox="0 0 720 540" xmlns="http://www.w3.org/2000/svg" font-family="monospace">
  <defs>
    <marker id="arr" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="#666" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- SEED -->
  <rect x="40" y="30" width="640" height="80" rx="10" fill="#f0f0f0" stroke="#aaa" stroke-width="1"/>
  <text x="60" y="56" font-size="13" font-weight="bold" fill="#333">seeds/raw_orders.csv — loaded by dbt seed → main.raw_orders</text>
  <text x="60" y="76" font-size="12" fill="#555">Raw text, no types enforced</text>
  <text x="60" y="96" font-size="12" fill="#222">order_id=3   customer_name="Alice"   amount="45.00"   status="returned"</text>

  <!-- arrow 1 -->
  <line x1="360" y1="110" x2="360" y2="138" stroke="#666" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- STAGING -->
  <rect x="40" y="140" width="640" height="140" rx="10" fill="#e6f4f1" stroke="#2a9d8f" stroke-width="1.2"/>
  <text x="60" y="165" font-size="13" font-weight="bold" fill="#1a6b63">models/staging/stg_orders.sql — materialized as VIEW</text>
  <text x="60" y="183" font-size="12" fill="#555">Cleans and types each column — no business logic</text>

  <!-- header row -->
  <rect x="60"  y="193" width="120" height="22" rx="3" fill="#2a9d8f" opacity="0.15" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="120" y="208" text-anchor="middle" font-size="11" fill="#1a6b63">order_id</text>
  <rect x="190" y="193" width="140" height="22" rx="3" fill="#2a9d8f" opacity="0.15" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="260" y="208" text-anchor="middle" font-size="11" fill="#1a6b63">customer_name</text>
  <rect x="340" y="193" width="120" height="22" rx="3" fill="#2a9d8f" opacity="0.15" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="400" y="208" text-anchor="middle" font-size="11" fill="#1a6b63">amount</text>
  <rect x="470" y="193" width="180" height="22" rx="3" fill="#2a9d8f" opacity="0.15" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="560" y="208" text-anchor="middle" font-size="11" fill="#1a6b63">status</text>

  <!-- value row -->
  <rect x="60"  y="215" width="120" height="22" rx="3" fill="#fff" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="120" y="230" text-anchor="middle" font-size="11" fill="#222">"3" → INTEGER 3</text>
  <rect x="190" y="215" width="140" height="22" rx="3" fill="#fff" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="260" y="230" text-anchor="middle" font-size="11" fill="#222">TRIM → "Alice"</text>
  <rect x="340" y="215" width="120" height="22" rx="3" fill="#fff" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="400" y="230" text-anchor="middle" font-size="11" fill="#222">DECIMAL 45.00</text>
  <rect x="470" y="215" width="180" height="22" rx="3" fill="#fff" stroke="#2a9d8f" stroke-width="0.5"/>
  <text x="560" y="230" text-anchor="middle" font-size="11" fill="#222">LOWER → "returned"</text>

  <text x="60" y="265" font-size="11" fill="#777">↑ same for all 10 rows — this is a view, no data stored, just a saved SQL query</text>

  <!-- arrow 2 -->
  <line x1="360" y1="282" x2="360" y2="310" stroke="#666" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="370" y="300" font-size="11" fill="#777">all 10 rows flow through</text>

  <!-- MART -->
  <rect x="40" y="312" width="640" height="160" rx="10" fill="#eef2ff" stroke="#4361ee" stroke-width="1.2"/>
  <text x="60" y="337" font-size="13" font-weight="bold" fill="#2c3e9e">models/marts/fct_customer_summary.sql — materialized as TABLE</text>
  <text x="60" y="355" font-size="12" fill="#555">Alice's 3 rows from stg_orders get collapsed into 1</text>

  <text x="60" y="378" font-size="11" fill="#444">Input rows:</text>
  <text x="60" y="394" font-size="11" fill="#222">#1  completed  120.50</text>
  <text x="60" y="410" font-size="11" fill="#222">#3  returned   45.00</text>
  <text x="60" y="426" font-size="11" fill="#222">#6  completed   60.00</text>

  <!-- arrow right -->
  <line x1="270" y1="408" x2="328" y2="408" stroke="#4361ee" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="274" y="400" font-size="10" fill="#4361ee">GROUP BY</text>

  <!-- output box -->
  <rect x="335" y="362" width="320" height="100" rx="6" fill="#fff" stroke="#4361ee" stroke-width="0.8"/>
  <text x="350" y="382" font-size="11" fill="#222">customer_name :  Alice</text>
  <text x="350" y="399" font-size="11" fill="#222">total_orders  :  3</text>
  <text x="350" y="416" font-size="11" fill="#222">total_revenue :  180.50</text>
  <text x="350" y="433" font-size="11" fill="#222">total_returned:   45.00</text>
  <text x="350" y="450" font-size="11" fill="#222">return_rate   :  33.3%</text>

  <!-- arrow 3 -->
  <line x1="360" y1="474" x2="360" y2="502" stroke="#666" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- ANALYST -->
  <rect x="40" y="504" width="640" height="26" rx="8" fill="#fef9c3" stroke="#ca8a04" stroke-width="1"/>
  <text x="360" y="521" text-anchor="middle" font-size="12" font-weight="bold" fill="#854d0e">analyst / BI tool / dashboard — queries main.fct_customer_summary</text>

</svg>
</p>

---

## Final output

```sql
SELECT * FROM main.fct_customer_summary;
```

| customer_name | total_orders | total_revenue | total_returned | return_rate_pct |
|---------------|--------------|---------------|----------------|-----------------|
| Diana         | 2            | 549.99        | NULL           | 0.0             |
| Bob           | 3            | 399.75        | 25.00          | 33.3            |
| Charlie       | 2            | 200.00        | 15.00          | 50.0            |
| Alice         | 3            | 180.50        | 45.00          | 33.3            |

---

## Project structure

```
learning_dbt/
├── dbt_project.yml              # project config and materialization settings
├── seeds/
│   └── raw_orders.csv           # 10 rows of synthetic order data
├── models/
│   ├── staging/
│   │   ├── stg_orders.sql       # cleans and types raw_orders → view
│   │   └── schema.yml           # tests: unique, not_null, accepted_values
│   └── marts/
│       └── fct_customer_summary.sql   # aggregates by customer → table
└── tests/
```

---

## Core dbt concepts covered

| Concept           | Where used                                      |
|-------------------|-------------------------------------------------|
| Seeds             | `raw_orders.csv` loaded with `dbt seed`         |
| Staging model     | `stg_orders.sql` — view, type casting, cleaning |
| Mart model        | `fct_customer_summary.sql` — table, aggregations|
| Materializations  | `view` for staging, `table` for marts           |
| `{{ ref() }}`     | links models, builds the DAG automatically      |
| Generic tests     | `unique`, `not_null`, `accepted_values`          |
| DAG               | `raw_orders → stg_orders → fct_customer_summary`|

---

## Setup

### Prerequisites

- Python 3.10+
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or virtualenv
- [DuckDB CLI](https://duckdb.org/docs/installation/) (optional, for direct querying)

### Install

```bash
# create and activate environment
conda create -n myenv python=3.10
conda activate myenv

# install dbt with DuckDB adapter
pip install dbt-duckdb
```

### Configure connection

Create `~/.dbt/profiles.yml`:

```yaml
learning_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: "learning_dbt.duckdb"
      threads: 1
```

### Run

```bash
cd learning_dbt

# test connection
dbt debug

# build everything: seed + models + tests
dbt build
```

### Query results

```bash
duckdb learning_dbt.duckdb
```

```sql
SELECT * FROM main.fct_customer_summary;
```

---

## Test results

```
PASS=9  WARN=0  ERROR=0  SKIP=0  TOTAL=9
```

All 6 data tests pass:
- `unique` and `not_null` on `order_id`
- `accepted_values` on `status` (`completed`, `returned`)
- `not_null` on `amount`
- `unique` and `not_null` on `customer_name`

---

## Tech stack

- [dbt Core](https://docs.getdbt.com/) 1.11.7
- [dbt-duckdb](https://github.com/duckdb/dbt-duckdb) 1.10.1
- [DuckDB](https://duckdb.org/) (local, file-based)
- Python 3.10
