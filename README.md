# Try Cassis from your own agent

Cassis is a context layer between your warehouse and the agents that query it. Your definitions live in a git repository you own; Cassis grounds every question in them and keeps them true as people ask things.

Try it from your terminal on a sample marketplace warehouse: about fifteen minutes, nothing touching your own data. Asking, editing and proving are headless; two setup steps — the key, and connecting this repository — happen in the browser.

Start with **Use this template** at the top of this page, then clone your own copy. Step 5 connects that repository to Cassis, so it has to be one you own.

`cassis/` holds it already: six domains as Markdown, fifteen tables, thirteen joins and ten metrics as YAML, plus the `AGENTS.md` the text-to-SQL agent reads. Read it first — it is what a context layer looks like as code.

## 1. Get a sandbox and a key

Sign up at [app.getcassis.com](https://app.getcassis.com). You land in your own organization with a seeded project, **Demo — Stallora Marketplace**: a pan-European marketplace on Snowflake, ~37,000 sellers and 1.2M orders. The warehouse is already connected and this exact ontology is already published against it, so there is nothing to wire up.

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

Cassis does not pick a threshold and hand you a number. It returns a plan with the interpretations "at risk" could mean — low on-time rate, weak reviews, dormancy, combinations — one marked as default, and waits for you to choose. That is the moment a wrong number would otherwise reach whoever asked.

## 3. Bind the tree to your sandbox

```bash
pip install -U cassis-cli
cassis projects list                  # copy the sandbox project id
cassis ontology pull --project <id>
```

`pull` writes `cassis/project.yml`, recording which project this checkout belongs to so later commands need no `--project`. It should report no other change: the tree here is the one your sandbox was seeded with. A diff means someone already edited one side.

## 4. Settle a definition and prove it

Notice `cassis/metrics/` has no definition of an at-risk seller — that is why step 2 asked you instead of guessing. Add one, then:

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

The repository is now the source of truth: open a pull request, `.github/workflows/ontology.yml` runs the same gates, merging to `main` publishes. Add `CASSIS_API_KEY` as an Actions secret and `CASSIS_PROJECT_ID` as a variable so CI can reach the project.

## 6. Let it find its own gaps

Everything you asked in step 2 was recorded. Cassis clusters those conversations into issues — a missing definition, an ambiguous term, a join it had to guess — and proposes fixes as changes to these files. The sandbox opens with three; the analysis that adds yours runs nightly, or you can start it from the app.

Read the queue over MCP (`list_issues`, `get_issue`), or from the terminal:

```bash
cassis issues list                    # id, impact, occurrences, status, title
cassis issues show <id>               # diagnosis, suggested action, occurrences
```

Both read the same queue, so an agent with no browser has the whole loop: read the issue, fix the root cause in these files, prove it with `cassis verify`, open the pull request. `--json` on either command gives it parseable output. Merging is the one step it cannot take.

## Limits

The sandbox runs on our Snowflake copy of the marketplace, and Cassis executes the SQL there. Connecting your own warehouse is not self-serve yet — that starts with a conversation, and one domain's schema is enough to begin. When you get there, [cassis-ontology-starter](https://github.com/GetCassis/cassis-ontology-starter) is the same wiring with none of this content: the CI gates, the MCP config and the modeling guide, ready for your own schema. Each signup carries a small inference credit; tell us if you run out. `cassis ontology upload` publishes immediately unless you pass `--no-publish`.
