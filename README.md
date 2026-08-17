# Try Cassis from your own agent

[Website](https://getcassis.com) · [Product](https://getcassis.com/product) · [Documentation](https://docs.getcassis.com) · [Contact](https://getcassis.com/contact/)

Cassis is a context layer between your warehouse and the agents that query it. Your definitions live in a git repository you own; Cassis grounds every question in them and keeps them true as people ask things.

This walkthrough runs the full loop on Stallora, a fictional pan-European marketplace. About fifteen minutes, and nothing touches your own data. You will:

- **Ask a question with no agreed definition** and watch Cassis refuse to guess.
- **Supply the definition** and get the answer.
- **Ship it as a governed metric** through a pull request, with an eval pinning it.
- **Ask again** and get the number directly.

**You need:** a GitHub account, Python 3.10+, and an agent that speaks MCP. The prompts work in any MCP client; Claude Code is the one this repository is pre-wired for.

## Setup

### 1. Create your repository

Press **Use this template** at the top of this page, create your repository, and clone it. You will wire CI to it and open a pull request against it, so it has to be one you own.

[`cassis/`](cassis) already holds the context:

- six [domains](cassis/domains) as Markdown
- fifteen [tables](cassis/tables/STALLORA), thirteen [joins](cassis/joins.yml) and ten [metrics](cassis/metrics) as YAML
- [`AGENTS.md`](cassis/AGENTS.md), the modeling guide an agent must read before editing these files

Open [`cassis/metrics/on_time_delivery_rate.yml`](cassis/metrics/on_time_delivery_rate.yml): an expression, its filters, a description, the synonyms agents match on. That file is why on-time delivery questions get a grounded answer. In the loop, you will add one just like it for a term nobody has defined yet.

### 2. Create a sandbox and an API key

Sign up at [app.getcassis.com](https://app.getcassis.com). You land in your own organization with a seeded project, **Demo — Stallora Marketplace**: ~37,000 sellers and 1.2M orders on our Snowflake, already connected, with this exact ontology published against it. The sandbox also carries the issues Cassis detected from a fictional team's recent activity, so the queue you will read in the loop has content on day one. On a live project, those come from your own team's questions.

Under **Settings → API keys**, create a key (`sk-k6-…`). One key serves the CLI, the MCP server and CI.

```bash
cp .env.example .env      # put your key in CASSIS_API_KEY
set -a; . ./.env; set +a
```

### 3. Install the CLI

```bash
pip install -U cassis-cli
cassis projects list                  # copy the sandbox project id
cassis ontology pull --project <id>
```

`pull` writes `cassis/project.yml`, recording which project this checkout belongs to, so later commands need no `--project`.

> [!NOTE]
> Expect `pull` to report an up-to-date tree: your sandbox was seeded with exactly the files in this repository.

### 4. Connect your agent

If your agent is Claude Code, there is nothing to do: [`.mcp.json`](.mcp.json) in this repository already registers the server. Point any other MCP client at:

```
https://app.getcassis.com/mcp/
```

No key needed when your client can do a browser sign-in. An agent that cannot open a browser — a Slack bot, a Dust or n8n agent — sends the key as a bearer token instead.

### 5. Add the CI secrets

In your repository's settings, add:

| Name | Add it as |
|---|---|
| `CASSIS_API_KEY` | Actions **secret** |
| `CASSIS_PROJECT_ID` | Actions **variable** |

[`.github/workflows/ontology.yml`](.github/workflows/ontology.yml) is already written: it validates and runs the eval suite on pull requests, and publishes on merge to `main`. Nothing to install, nothing to connect in a browser.

Setup is done. Everything below is one conversation with your agent, in your clone.

## The loop

### 1. Ask something nobody has defined

> which sellers are at risk?

**Expect a plan, not a number.** Cassis does not pick a threshold for you. It returns the interpretations "at risk" could mean — low on-time rate, weak reviews, dormancy, combinations — one marked as default, and waits for you to choose.

### 2. Answer it yourself

> a seller is at risk when it has at least 5 delivered orders and either an on-time delivery rate below 85% or an average review score below 3. A null on-time rate or null review score never trips its criterion. Return the count of at-risk sellers. Use that definition.

**Expect the count in one turn.**

> [!TIP]
> If the number comes back without your thresholds, your agent approved the earlier plan instead of passing your definition. Have it send the definition as a new question, not as an approval.

The definition now lives in exactly one conversation — this one. The next person gets the same gate, or worse, invents a different threshold and reports a different number. The rest of the loop makes it governed.

### 3. List the open issues

> List the open Cassis issues on this project.

Cassis clusters the questions people ask into issues: a missing definition, an ambiguous term, a join it had to guess. In your sandbox the queue comes from the seeded team history, and the at-risk issue sits at the top, carrying a proposed fix.

### 4. Read the proposed fix

> What's Cassis proposing for the at-risk issue?

**Expect a new `at_risk_sellers` metric:** the SQL expression, filters carrying the thresholds you just used, a description, the synonyms agents will match on. On a live project this is the maintenance loop: a definition given in a conversation comes back as a reviewable patch.

### 5. Apply it and check

> Looks right. Apply it on a branch and run checks.

Your agent writes the files and validates them locally: `cassis ontology fmt` puts them in canonical form and refreshes the domain navigation, then `cassis ontology check` runs the same validation as the PR gate, cross-checking every reference against the warehouse's own schema.

### 6. Pin it with an eval

> Pin it with an eval: add a case with the question "How many sellers are at risk?", read the gold SQL from demo-gold.sql, then run only that new case to prove it.

One question, plus the SQL you agree is right ([demo-gold.sql](demo-gold.sql)). The gold reads the raw tables; the metric answers off `DIM_SELLER`. The case passes because the *results* match, not the text — so a future edit that quietly changes what the number means goes red instead of shipping.

### 7. Open a pull request

> Commit this on the branch and open a PR.

### 8. Review it on GitHub

**Files changed** is the review: two files, the new metric and the domain README that now links it. The checks run beside it:

- **ontology validation** — structure, round-tripping, and schema references
- **eval suite** — the full suite against this branch's files, so a change that breaks a definition anywhere goes red in front of a reviewer rather than in front of a user
- **publish to Cassis** — shows *skipped*: publish only runs on `main`

### 9. Merge

CI publishes the new version. Merging is the deploy — no console, no separate step.

### 10. Ask again, in a new conversation

> which sellers are at risk?

**Expect a direct answer** — the same number, this time through the governed `at_risk_sellers` metric, with no gate. Start a *new* chat for this: each conversation is pinned to the ontology version it started on, so publishing never rewrites answers in a conversation already underway. A new chat picks up the latest version.

### 11. Close the issue

```bash
cassis issues resolve <id>
```

`<id>` is in the list your agent printed in loop step 3. The other issues stay open. CLI and MCP read the same queue, so an agent with no browser has the whole loop: read the issue, fix the root cause in these files, prove it with `cassis verify` (format, validation and the eval suite in one command), open the pull request. `--json` on either command gives it parseable output. Merging is the one step it cannot take.

## Limits

- The sandbox runs on our Snowflake, and Cassis executes the SQL there. Connecting your own warehouse is not self-serve yet — [talk to us](https://getcassis.com/contact/); one domain's schema is enough to begin. When you get there, [cassis-ontology-starter](https://github.com/GetCassis/cassis-ontology-starter) is the same wiring with none of this content, ready for your own schema.
- Each signup carries a small inference credit — [contact us](https://getcassis.com/contact/) if you run out.
- `cassis ontology upload` publishes straight from your working tree, no pull request — pass `--no-publish` to upload without publishing.

## Links

- [docs.getcassis.com](https://docs.getcassis.com) — the product documentation
- [cassis-ontology-starter](https://github.com/GetCassis/cassis-ontology-starter) — start an ontology on your own schema
- [cassis-ontology-examples](https://github.com/GetCassis/cassis-ontology-examples) — two complete worked ontologies
- [getcassis.com](https://getcassis.com) — what Cassis is
- [getcassis.com/product](https://getcassis.com/product) — context maintenance for analytics agents, the loop this sandbox runs
