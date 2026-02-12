# Ralph

![Ralph](ralph.webp)

Ralph is an autonomous AI agent loop that runs [Codex CLI](https://github.com/openai/codex) repeatedly until all PRD items are complete. Each iteration is a fresh instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

[Read my in-depth article on how I use Ralph](https://x.com/ryancarson/status/2008548371712135632)

## Codex Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed
- Codex authenticated (`codex login`)
- `jq` installed (`brew install jq` on macOS)
- A git repository for your target project

## Codex Installation

Install Codex CLI with one of these:

```bash
# npm
npm install -g @openai/codex

# or Homebrew
brew install --cask codex
```

Verify and authenticate:

```bash
codex --version
codex login
jq --version
```

## Install Ralph Into Your Project (Codex)

1. Clone this repo somewhere local:

```bash
git clone https://github.com/Beryl-18/ralph-codex.git ~/tools/ralph-codex
```

2. Copy Codex Ralph files into your project:

```bash
cd /path/to/your/project
mkdir -p scripts/ralph
cp ~/tools/ralph-codex/ralph.sh scripts/ralph/
cp ~/tools/ralph-codex/CODEX.md scripts/ralph/
cp ~/tools/ralph-codex/prd.json.example scripts/ralph/prd.json
chmod +x scripts/ralph/ralph.sh
```

3. Edit `scripts/ralph/prd.json` for your feature:
   - Set `project`, `branchName`, `description`
   - Add right-sized `userStories`
   - Keep unfinished stories as `"passes": false`

## Run Ralph With Codex

From your project root:

```bash
./scripts/ralph/ralph.sh --tool codex 10
```

Arguments:

- `--tool codex` tells Ralph to run Codex CLI each iteration
- `10` is max iterations (optional, default is 10)

Recommended runs:

```bash
# Short run while tuning prompts/PRD
./scripts/ralph/ralph.sh --tool codex 3

# Normal run
./scripts/ralph/ralph.sh --tool codex 10

# Long run for many stories
./scripts/ralph/ralph.sh --tool codex 20
```

Ralph loop behavior:

1. Reads `scripts/ralph/prd.json`
2. Picks highest-priority story with `passes: false`
3. Runs one fresh Codex session for that story
4. Verifies checks and commits when successful
5. Marks story complete in `prd.json`
6. Appends iteration notes to `progress.txt`
7. Stops when all stories pass or max iterations is reached

## Key Files (Codex)

| File | Purpose |
|------|---------|
| `ralph.sh` | Loop runner (`--tool codex`) |
| `CODEX.md` | Prompt template used by Codex each iteration |
| `prd.json` | Task list and completion status |
| `progress.txt` | Iteration log and reusable learnings |
| `archive/` | Previous run snapshots when feature branch changes |
| `flowchart/` | Interactive visualization of the Ralph loop |

## Flowchart

[![Ralph Flowchart](ralph-flowchart.png)](https://snarktank.github.io/ralph/)

**[View Interactive Flowchart](https://snarktank.github.io/ralph/)** - Click through to see each step with animations.

The `flowchart/` directory contains the source code. To run locally:

```bash
cd flowchart
npm install
npm run dev
```

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new Codex instance** with clean context. The only memory between iterations is:
- Git history (commits from previous iterations)
- `progress.txt` (learnings and context)
- `prd.json` (which stories are done)

### Small Tasks

Each PRD item should be small enough to complete in one context window. If a task is too big, the LLM runs out of context before finishing and produces poor code.

Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

Too big (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### AGENTS.md Updates Are Critical

After each iteration, Ralph updates the relevant `AGENTS.md` files with learnings. This is key because AI coding tools automatically read these files, so future iterations (and future human developers) benefit from discovered patterns, gotchas, and conventions.

Examples of what to add to AGENTS.md:
- Patterns discovered ("this codebase uses X for Y")
- Gotchas ("do not forget to update Z when changing W")
- Useful context ("the settings panel is in component X")

### Feedback Loops

Ralph only works if there are feedback loops:
- Typecheck catches type errors
- Tests verify behavior
- CI must stay green (broken code compounds across iterations)

### Browser Verification for UI Stories

Frontend stories must include "Verify in browser using dev-browser skill" in acceptance criteria. Ralph will use the dev-browser skill to navigate to the page, interact with the UI, and confirm changes work.

### Stop Condition

When all stories have `passes: true`, Ralph outputs `<promise>COMPLETE</promise>` and the loop exits.

## Debugging

Check current state:

```bash
# See which stories are done
cat scripts/ralph/prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings from previous iterations
cat scripts/ralph/progress.txt

# Check git history
git log --oneline -10
```

## Customizing the Prompt

After copying `CODEX.md` to your project, customize it for your project:
- Add project-specific quality check commands
- Include codebase conventions
- Add common gotchas for your stack

## Archiving

Ralph automatically archives previous runs when you start a new feature (different `branchName`). Archives are saved to `archive/YYYY-MM-DD-feature-name/`.

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Codex CLI repository](https://github.com/openai/codex)
