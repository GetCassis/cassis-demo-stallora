# Try Cassis from your own agent

[Website](https://getcassis.com) · [Documentation](https://docs.getcassis.com) · [Contact](https://getcassis.com/contact/)

Cassis is the data context layer that improves with use. Your agent asks Cassis; Cassis answers from definitions that live in a Git repository you own, and stops instead of guessing when a definition is missing.

This walkthrough uses Stallora, a fictional pan-European marketplace: about 37,000 sellers and 1.2M orders on our Snowflake. Nothing touches your own data.

## 1. Ask from your agent (2 minutes)

Sign up at [app.getcassis.com](https://app.getcassis.com). You get your own copy of the Stallora project.

Add Cassis to your agent as an MCP server:

```
https://app.getcassis.com/mcp/
```

In Claude: **Settings → Connectors → Add custom connector**, paste the URL, sign in when asked. Any MCP client works the same way; one that cannot open a browser (a Slack bot, an n8n agent) sends an API key as a bearer token instead.

Then ask:

> What is our on-time delivery rate?

A direct answer. `on_time_delivery_rate` is defined in the context, so every agent gets the same number.

> Which sellers are at risk?

**Your agent stops and asks.** Nobody at Stallora has defined "at risk", so Cassis returns the readings it could mean instead of picking one.

> A seller is at risk when it has at least 5 delivered orders and either an on-time delivery rate below 85% or an average review score below 3. How many are there?

The count, with your rule. But the rule now lives in this one conversation. The next person gets the same stop, or invents another threshold. Part 2 makes it shared.

## 2. Make it stick (10 minutes)

You need Python 3.10+ and an agent that can edit files and run commands (Claude Code, Cursor, Codex…).

Press **Use this template** at the top of this page, create your repository and clone it. [`cassis/`](cassis) holds the context: six [domains](cassis/domains) as Markdown; [tables](cassis/tables/STALLORA), [joins](cassis/joins.yml) and [metrics](cassis/metrics) as YAML; and [`AGENTS.md`](cassis/AGENTS.md), the guide your agent reads before editing.

In the app, under **Settings → API keys**, create a key. Your project id is at the bottom of the card on your sandbox's first chat. Then:

```bash
cp .env.example .env      # put your key in CASSIS_API_KEY, your project id in CASSIS_PROJECT_ID
set -a; . ./.env; set +a
pip install -U cassis-cli
cassis context pull
```

Now work with your agent, in your clone:

> List the open Cassis issues with `cassis issues list`, then show me the at-risk one with `cassis issues show`.

Your sandbox comes with issues from a fictional team's recent questions. The at-risk issue is the gap you just hit. On your own project, the issues come from your team's questions.

> Add the at-risk definition as a metric, following `cassis/AGENTS.md`. Then prove it answers with `cassis context test -q "How many sellers are at risk?"`.

Your agent writes `cassis/metrics/at_risk_sellers.yml` and links it from the sellers domain. `context test` asks the question against your local files, before anything is published.

> Run `cassis verify`, then publish with `cassis context upload`.

`verify` runs formatting, validation against the warehouse schema and the eval suite. `upload` publishes your working tree to your sandbox.

Back in your agent, **in a new chat** (each chat stays on the version it started with):

> Which sellers are at risk?

A direct answer, from the shared metric. Every agent connected to this project now gets it.

## 3. Ship it through review (optional)

On a real team, a context change goes through a pull request like code. This repository is wired for it:

1. In your repository settings, add `CASSIS_API_KEY` as an Actions secret and `CASSIS_PROJECT_ID` as an Actions variable.
2. Commit your change on a branch and open a pull request. [`ontology.yml`](.github/workflows/ontology.yml) validates the change and runs the eval suite against the branch.
3. Merge. [`publish.yml`](.github/workflows/publish.yml) publishes the new version.

## Your data next

See your own agent answer from your metrics and definitions. [Try it on your data](https://getcassis.com/contact/).

## Limits

- The sandbox runs on our Snowflake, and Cassis executes the SQL there. Connecting your own warehouse is not self-serve yet.
- Each signup carries a small inference credit. [Contact us](https://getcassis.com/contact/) if you run out.
