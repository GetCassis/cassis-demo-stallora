# Try Cassis from your own agent

Cassis is a context layer between your warehouse and the agents that query it. Your business definitions live in a git repository you own; Cassis grounds every question in them and keeps them true as people ask things.

Use this repository to try that headless, from your own terminal, on a sample marketplace warehouse. About fifteen minutes, and nothing here touches your own data.

## 1. Get a sandbox and a key

Sign up at [app.getcassis.com](https://app.getcassis.com). You land in your own organization with a seeded project, **Demo — Stallora Marketplace**: a pan-European marketplace on Snowflake, ~37,000 sellers and 1.2M orders, already modeled and published.

Under Settings, open **API keys** and create one (`sk-k6-…`). One key serves both the CLI and the MCP server.

```bash
cp .env.example .env      # put your key in CASSIS_API_KEY
set -a; . ./.env; set +a
```

## 2. Ask from your own agent

The MCP server needs no key when your client can do a browser sign-in:

```bash
claude mcp add --transport http cassis https://app.getcassis.com/mcp/
```

`.mcp.json` here does the same for Claude Code. An agent that cannot open a browser — a Slack bot, a Dust or n8n agent — sends the key as a bearer token instead.

Ask something easy first, like average order value: you get the number, the SQL, and the ontology objects behind it. Then ask something the business has not defined:

> which sellers are at risk?

Cassis does not pick a threshold and hand you a number. It returns a plan with the interpretations "at risk" could mean — low on-time rate, weak reviews, dormancy, combinations — one marked as the default, and waits for you to choose. That is the moment a wrong number would otherwise reach whoever asked.

## 3. Bring the ontology into this repository

```bash
pip install -U cassis-cli
cassis projects list                  # copy the sandbox project id
cassis ontology pull --project <id>
```

That writes `cassis/` — domains as Markdown, tables, joins and metrics as YAML — plus `cassis/project.yml` recording which project this checkout belongs to, so later commands need no `--project`. Read `cassis/AGENTS.md` first: it is the modeling doctrine the text-to-SQL agent itself reads, and the CLI keeps it current.

## 4. Settle a definition and prove it

Add the definition the question above was missing, as a metric under `cassis/metrics/`. Then:

```bash
cassis ontology fmt      # canonical form; refreshes AGENTS.md and domain navigation
cassis verify            # fmt --check, then check, then the eval suite
```

`verify` is the gate. Run `fmt` first: `check` fails on its own if a new metric is not yet linked into its domain README. The eval suite scores the project's gold questions and links the run.

To see the effect before publishing anything, run questions through your local files:

```bash
cassis ontology test -q "how many sellers are at risk?"
```

The generated SQL now uses your definition. `test` executes its own default choice instead of asking you — it is a regression probe for CI, not the interactive surface from step 2.

## 5. Make merging the way it publishes

In Cassis, under Settings → GitHub, click **Connect GitHub** and install the Cassis Sync app on this repository. Then in Project configuration select the sandbox project, enter the repository as `owner/name` with path `cassis`, and save.

The repository is now the source of truth: open a pull request, `.github/workflows/ontology.yml` runs the same gates, merging to `main` publishes. Add `CASSIS_API_KEY` as an Actions secret and `CASSIS_PROJECT_ID` as a variable so CI can reach the project. Push the tree from step 3 to finish the handshake.

## 6. Let it find its own gaps

Everything you asked in step 2 was recorded. Cassis clusters those conversations into issues — a missing definition, an ambiguous term, a join it had to guess — and proposes fixes as changes to these files. Your agent reads that queue over MCP (`list_issues`, `get_issue`), fixes the root cause here, proves it with `cassis verify`, and opens the pull request. Merging is the one step it cannot take.

## Limits

The sandbox runs on our Snowflake copy of the marketplace, and Cassis executes the SQL there. Connecting your own warehouse is not self-serve yet — that starts with a conversation, and one domain's schema is enough to begin. Each signup carries a small inference credit; tell us if you run out. `cassis ontology upload` publishes immediately unless you pass `--no-publish`.
