# Docs

Everything about how this repo is built, tested and run: for people and for AI agents (Claude, Codex, or any other).
The repo is the memory: nothing important lives only in a chat, a cloud session or someone's head.

## Read in this order

| # | File | Read it to learn |
| --- | --- | --- |
| 1 | [../AGENTS.md](../AGENTS.md) | The rules every agent follows, the layout, the build and test commands, the definition of done |
| 2 | [how-it-works.md](how-it-works.md) | What runs where (cloud sessions, Linux CI, Mac runners), every workflow, labels, secrets, outputs, versions |
| 3 | [playbook.md](playbook.md) | Step-by-step recipes and ready-to-paste prompts for everyday tasks |
| 4 | [decisions.md](decisions.md) | Why things are the way they are, and when to revisit each choice |
| 5 | [troubleshooting.md](troubleshooting.md) | Problems already hit, what caused them and the fix. Check it before debugging |
| 6 | [setup.md](setup.md) | The one-time setup of accounts, the cloud environment and the GitHub repo, so it can be redone |
| 7 | [history.md](history.md) | What happened when: milestones, PRs, current state, the IDs this repo uses |
| 8 | [original-guide.md](original-guide.md) | The plan this workflow started from (where reality differs, the docs above win) |

Also at the top level: [../README.md](../README.md) (overview and setup progress), [../LATER.md](../LATER.md) (parked
work) and [../specs/](../specs/) (one spec per feature).

## Where to write down what you learn

Agents start every session with no memory of earlier ones, so write things down in the same PR as the work:

| You… | Write it in |
| --- | --- |
| fixed a problem that could happen again (CI, toolchain, simulator, flaky test) | [troubleshooting.md](troubleshooting.md) |
| made or changed a choice others should not undo by accident | [decisions.md](decisions.md) |
| finished a milestone, merged a feature, changed an ID, key, secret name or version | [history.md](history.md) |
| found a repeatable way to do a task | [playbook.md](playbook.md) |
| parked something for later | [../LATER.md](../LATER.md) |
| changed a rule or command | [../AGENTS.md](../AGENTS.md) |

Never write secret values anywhere in the repo: only their names and where they are kept.
