# Try Cassis from your own agent

Cassis is a context layer between your warehouse and the agents that query it. Your definitions live in a git repository you own; Cassis grounds every question in them and keeps them true as people ask things.

This walkthrough runs one full loop on a sample marketplace warehouse: a question nobody can answer, a definition you supply, and a governed metric shipped through a pull request so the next person gets the number directly. About fifteen minutes, nothing touching your own data.

**Do all of the setup first.** The loop below is one continuous story, and stopping in the middle of it to create a key or wire up CI breaks the thread.

---

## Setup

### 1. Your own copy of this repository

Press **Use this template** at the top of this page, create your repository, and clone it. Step 5 wires that repository to CI, so it has to be one you own.

`cassis/` already holds the context: six domains as Markdown, fifteen tables, thirteen joins and ten metrics as YAML, plus the `AGENTS.md` the text-to-SQL agent reads. Open `cassis/metrics/on_time_delivery_rate.yml` — an expression, its filters, a description, the synonyms agents match on. That file is why on-time delivery questions get a grounded answer. The gap you are about to fill is the absence of one just like it.

### 2. A sandbox and a key

Sign up at [app.getcassis.com](https://app.getcassis.com). You land in your own organization with a seeded project, **Demo — Stallora Marketplace**: a pan-European marketplace on Snowflake, ~37,000 sellers and 1.2M orders. The warehouse is already connected and this exact ontology is already published against it, so there is nothing to wire up.

Under Settings, open **API keys** and create one (`sk-k6-…`). One key serves the CLI, the MCP server and CI.

```bash
cp .env.example .env      # put your key in CASSIS_API_KEY
set -a; . ./.env; set +a
```

### 3. The CLI, bound to your sandbox

```bash
pip install -U cassis-cli
cassis projects list                  # copy the sandbox project id
cassis ontology pull --project <id>
```

`pull` writes `cassis/project.yml`, recording which project this checkout belongs to so later commands need no `--project`. It should report no other change: the tree here is the one your sandbox was seeded with. A diff means someone already edited one side.

### 4. Your agent, over MCP

```bash
claude mcp add --transport http cassis https://app.getcassis.com/mcp/
```

No key needed when your client can do a browser sign-in. `.mcp.json` here does the same for Claude Code. An agent that cannot open a browser — a Slack bot, a Dust or n8n agent — sends the key as a bearer token instead.

### 5. CI, so that merging publishes

In your repository's settings, add `CASSIS_API_KEY` as an Actions secret and `CASSIS_PROJECT_ID` as a variable. `.github/workflows/ontology.yml` is already written: it validates and runs the eval suite on pull requests, and publishes on merge to `main`. Nothing to install, nothing to connect in a browser.

Setup is done. Everything below is the loop.

---

## The loop

### Ask something nobody has defined

> which sellers are at risk?

Cassis does not pick a threshold and hand you a number. It returns a plan with the interpretations "at risk" could mean — low on-time rate, weak reviews, dormancy, combinations — one marked as default, and waits for you to choose. That is the moment a wrong number would otherwise reach whoever asked.

### Answer it yourself

> a seller is at risk when it has at least 5 delivered orders and either an on-time delivery rate below 85% or an average review score below 3. A null on-time rate or null review score never trips its criterion. Return the count of at-risk sellers. Use that definition.

You get your answer in one turn — the null sentence settles the one thing SQL would otherwise decide silently, so there is nothing left for Cassis to ask. If the number comes back without your thresholds, your agent approved the earlier plan instead of passing your definition — have it send the definition as a new question, not as approval. But that definition now lives in exactly one conversation — yours. The next person to ask gets the same gate, or worse, invents a different threshold and reports a different number. Let's make it governed.

### See what Cassis already knows about the gap

> List the open Cassis issues on this project.

You were not the first to hit this. Cassis clusters the questions people actually asked into issues — a missing definition, an ambiguous term, a join it had to guess — and the at-risk one already carries a fix derived from the definition an asker gave in-thread.

### Read what it is proposing

> What's Cassis proposing for the at-risk issue?

A new `at_risk_sellers` metric: the SQL expression, the filters carrying the thresholds, a description, and the synonyms agents will match on. You never typed those thresholds. Someone who asked the question wrote the definition, and Cassis turned it into a reviewable patch.

### Apply it and check

> Looks right. Apply it on a branch and run checks.

Two turns on purpose — you read the proposal, then you accept it. The files are written and validated locally: `cassis ontology fmt` puts them in canonical form and refreshes the domain navigation, then `cassis ontology check` runs the same validation as the PR gate, cross-checking every reference against the warehouse's own schema.

### Pin it with an eval

> Pin it with an eval: add a case with the question "How many sellers are at risk?", read the gold SQL from demo-gold.sql, then run only that new case to prove it.

One question, plus the SQL you agree is right. The gold reads the raw tables; the metric answers off `DIM_SELLER`. It passes because the *results* match, not the text — so a future edit that quietly changes what the number means goes red instead of shipping.

### Open a pull request

> Commit this on the branch and open a PR.

### Review it on GitHub

Open the PR. **Files changed** is the review: two files, the metric and the domain rule. The checks run beside it — `ontology validation` for structure and schema references, then `eval suite`, the full suite against this branch's files, so a change that breaks a definition anywhere goes red in front of a reviewer rather than in front of a user. The `publish to Cassis` row shows *skipped*: publish only runs on `main`.

### Merge

CI publishes the new version. Merging is the deploy — no console, no separate step.

### Ask again, in a new conversation

> which sellers are at risk?

Answered directly now, off the governed definition. Start a *new* chat for this: each conversation is pinned to the ontology version it started on, so a publish mid-conversation never changes the answer under someone, and a new chat picks up the latest.

### Close the issue

```bash
cassis issues resolve <id>
```

The other issues stay open on purpose — a real queue is never empty. CLI and MCP read the same queue, so an agent with no browser has the whole loop: read the issue, fix the root cause in these files, prove it with `cassis verify`, open the pull request. `--json` on either command gives it parseable output. Merging is the one step it cannot take.

---

## Limits

The sandbox runs on our Snowflake copy of the marketplace, and Cassis executes the SQL there. Connecting your own warehouse is not self-serve yet — that starts with a conversation, and one domain's schema is enough to begin. When you get there, [cassis-ontology-starter](https://github.com/GetCassis/cassis-ontology-starter) is the same wiring with none of this content: the CI gates, the MCP config and the modeling guide, ready for your own schema.

Your sandbox also opens with a pending source change — a detected rename awaiting review that would break the average order value metric. That queue is in the app under Review; the CLI and MCP do not read it yet.

Each signup carries a small inference credit; tell us if you run out. `cassis ontology upload` publishes immediately unless you pass `--no-publish`.
