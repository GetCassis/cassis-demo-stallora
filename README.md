# Try Cassis from your own agent

Cassis is a context layer between your warehouse and the agents that query it. Your definitions live in a git repository you own; Cassis grounds every question in them and keeps them true as people ask things.

This walkthrough runs one full loop on Stallora, a fictional pan-European marketplace: a question nobody can answer, a definition you supply, and a governed metric shipped through a pull request so the next person gets the number directly. About fifteen minutes. Nothing touches your own data.

**You need:** a GitHub account, Python 3.10+, and an agent that speaks MCP. The prompts below work in any of them; Claude Code is the one this repository is pre-wired for.

> [!IMPORTANT]
> Do all of the setup before starting the loop. The loop is one continuous conversation, and stopping in the middle of it to create a key or wire up CI breaks the thread.

---

## Setup

### 1. Your own copy of this repository

Press **Use this template** at the top of this page, create your repository, and clone it. Step 5 wires that repository to CI, so it has to be one you own.

`cassis/` already holds the context:

- six domains as Markdown
- fifteen tables and ten metrics as YAML, plus thirteen joins
- `AGENTS.md`, the modeling guide an agent must read before editing these files

Open `cassis/metrics/on_time_delivery_rate.yml`: an expression, its filters, a description, the synonyms agents match on. That file is why on-time delivery questions get a grounded answer. The gap you are about to fill is the absence of one just like it.

### 2. A sandbox and a key

Sign up at [app.getcassis.com](https://app.getcassis.com). You land in your own organization with a seeded project, **Demo — Stallora Marketplace**: ~37,000 sellers and 1.2M orders on our Snowflake, already connected, with this exact ontology published against it. The sandbox also carries a fictional team's recent activity — a few conversations, and the issues Cassis clustered from them — so the queue you will read in the loop has content on day one. On a live project, that history is your own team's.

Under **Settings → API keys**, create a key (`sk-k6-…`). One key serves the CLI, the MCP server and CI.

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

`pull` writes `cassis/project.yml`, recording which project this checkout belongs to, so later commands need no `--project`.

> [!NOTE]
> Expect `pull` to report no other change: the tree in this repository is the one your sandbox was seeded with. A diff means someone already edited one side.

### 4. Your agent, over MCP

```bash
claude mcp add --transport http cassis https://app.getcassis.com/mcp/
```

For Claude Code specifically, `.mcp.json` in this repository already does this. No key needed when your client can do a browser sign-in. An agent that cannot open a browser — a Slack bot, a Dust or n8n agent — sends the key as a bearer token instead.

### 5. CI, so that merging publishes

In your repository's settings, add:

| Name | Add it as |
|---|---|
| `CASSIS_API_KEY` | Actions **secret** |
| `CASSIS_PROJECT_ID` | Actions **variable** |

`.github/workflows/ontology.yml` is already written: it validates and runs the eval suite on pull requests, and publishes on merge to `main`. Nothing to install, nothing to connect in a browser.

Setup is done. Everything below is one conversation with your agent, in your clone.

---

## The loop

### 1. Ask something nobody has defined

> which sellers are at risk?

**Expect a plan, not a number.** Cassis does not pick a threshold for you. It returns the interpretations "at risk" could mean — low on-time rate, weak reviews, dormancy, combinations — one marked as default, and waits for you to choose. That gate is where a wrong number would otherwise reach whoever asked.

### 2. Answer it yourself

> a seller is at risk when it has at least 5 delivered orders and either an on-time delivery rate below 85% or an average review score below 3. A null on-time rate or null review score never trips its criterion. Return the count of at-risk sellers. Use that definition.

**Expect the count in one turn.** The null sentence settles the one thing SQL would otherwise decide silently, so there is nothing left for Cassis to ask.

> [!TIP]
> If the number comes back without your thresholds, your agent approved the earlier plan instead of passing your definition. Have it send the definition as a new question, not as an approval.

The definition now lives in exactly one conversation — this one. The next person gets the same gate, or worse, invents a different threshold and reports a different number. The rest of the loop makes it governed.

### 3. See what Cassis already knows about the gap

> List the open Cassis issues on this project.

Cassis clusters the questions people ask into issues: a missing definition, an ambiguous term, a join it had to guess. In your sandbox the queue comes from the seeded team history, and the at-risk issue sits at the top, carrying a proposed fix.

### 4. Read what it is proposing

> What's Cassis proposing for the at-risk issue?

**Expect a new `at_risk_sellers` metric:** the SQL expression, filters carrying the thresholds you just used, a description, the synonyms agents will match on. This is the shape of the maintenance loop on a live project: a definition given in a conversation comes back as a reviewable patch, not a wiki note.

### 5. Apply it and check

> Looks right. Apply it on a branch and run checks.

Two turns on purpose: you read the proposal, then you accept it. The files are written and validated locally — `cassis ontology fmt` puts them in canonical form and refreshes the domain navigation, then `cassis ontology check` runs the same validation as the PR gate, cross-checking every reference against the warehouse's own schema.

### 6. Pin it with an eval

> Pin it with an eval: add a case with the question "How many sellers are at risk?", read the gold SQL from demo-gold.sql, then run only that new case to prove it.

One question, plus the SQL you agree is right. The gold reads the raw tables; the metric answers off `DIM_SELLER`. The case passes because the *results* match, not the text — so a future edit that quietly changes what the number means goes red instead of shipping.

### 7. Open a pull request

> Commit this on the branch and open a PR.

### 8. Review it on GitHub

**Files changed** is the review: two files, the metric and the domain rule. The checks run beside it:

- **ontology validation** — structure, round-tripping, and schema references
- **eval suite** — the full suite against this branch's files, so a change that breaks a definition anywhere goes red in front of a reviewer rather than in front of a user
- **publish to Cassis** — shows *skipped*: publish only runs on `main`

### 9. Merge

CI publishes the new version. Merging is the deploy — no console, no separate step.

### 10. Ask again, in a new conversation

> which sellers are at risk?

**Expect a direct answer** — the same number, this time through the governed `at_risk_sellers` metric, with no gate. Start a *new* chat for this: each conversation is pinned to the ontology version it started on, so a publish mid-conversation never changes an answer under someone; a new chat picks up the latest.

### 11. Close the issue

```bash
cassis issues resolve <id>
```

The other issues stay open on purpose — a real queue is never empty. CLI and MCP read the same queue, so an agent with no browser has the whole loop: read the issue, fix the root cause in these files, prove it with `cassis verify`, open the pull request. `--json` on either command gives it parseable output. Merging is the one step it cannot take.

---

## Limits

- The sandbox runs on our Snowflake, and Cassis executes the SQL there. Connecting your own warehouse is not self-serve yet — [talk to us](https://getcassis.com/contact/); one domain's schema is enough to begin. When you get there, [cassis-ontology-starter](https://github.com/GetCassis/cassis-ontology-starter) is the same wiring with none of this content, ready for your own schema.
- Your sandbox also opens with a pending source change in its queue: a column rename that would break the average order value metric, waiting for review in the app under **Review**. The CLI and MCP do not read that queue yet.
- Each signup carries a small inference credit — [email us](mailto:contact@getcassis.com) if you run out.
- `cassis ontology upload` publishes immediately unless you pass `--no-publish`.

## Where next

- [docs.getcassis.com](https://docs.getcassis.com) — the product documentation
- [cassis-ontology-starter](https://github.com/GetCassis/cassis-ontology-starter) — start an ontology on your own schema
- [cassis-ontology-examples](https://github.com/GetCassis/cassis-ontology-examples) — two complete worked ontologies
- [getcassis.com](https://getcassis.com) — what Cassis is
