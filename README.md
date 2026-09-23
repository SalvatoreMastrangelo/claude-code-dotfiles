# claude-code-dotfiles

My Claude Code status line, kept here so every machine gets the same one.
Claude Code does not sync `~/.claude/settings.json` across machines, so this repo does it.

```
Fable 5.1 │ ctx ▓▓░░░░░░░░░░░░░░░░░ 12% │ 5h ▓▓▓▓░░░░░░░░░░░░░░░ 23% ↻ 16:40 │ 7d 41%
```

- **Model** currently in use
- **ctx**: share of the context window used
- **5h**: share of the 5-hour usage limit consumed, and the time the window resets
  (shows `--` until the first response of a session)
- **7d**: share of the weekly usage limit consumed, as a bare percentage with no bar so it
  takes as little room as possible (also `--` until the first response)

The bars stretch to fill the terminal width. Below 5 blocks each they are dropped
(`Fable 5.1 │ ctx 12% │ 5h 23% ↻ 16:40 │ 7d 41%`), and on very narrow terminals the reset time goes too.
Bars are gray until they warn you. The ctx bar turns yellow from 50% and red from 70%
(a filling context window is worth acting on early); the 5h bar and the 7d figure turn yellow from 75% and red from 90%.

## Subagent rows

`subagent-statusline.sh` adds the model to each row of the agent panel below the prompt,
which by default shows only `name · description · token count`:

```
Count lines in dotfiles · Haiku 4.5 · 21.9k tokens
```

The main status line always describes the main session, even while viewing a subagent's chat,
so this is where a subagent's model is visible. Model ids are shortened
(`claude-haiku-4-5-20251001` becomes `Haiku 4.5`), long labels are cut to the row width, and
a row whose model is not resolved yet keeps its default look.

## Install

Needs `jq` (`apt install jq` / `brew install jq`).

```sh
git clone git@github.com:SalvatoreMastrangelo/claude-code-dotfiles.git
cd claude-code-dotfiles
./install.sh
```

`install.sh` copies both scripts to `~/.claude/` and adds the `statusLine` and
`subagentStatusLine` entries to `~/.claude/settings.json`. Every other setting in that file is
left alone, and the previous version is saved as `settings.json.bak` when a change is made.

## Update

```sh
git pull && ./install.sh
```

After editing a script directly in `~/.claude/` on a machine, copy it back here and commit
so the other machines can pull it.

## Tuning

At the top of `statusline.sh`:

- `MIN_BAR`: narrowest bar before falling back to the compact form
- `MARGIN`: columns left free for Claude Code's own indentation; raise it if the line wraps

## Uninstall

Remove the `statusLine` and `subagentStatusLine` entries from `~/.claude/settings.json` and
delete `~/.claude/statusline.sh` and `~/.claude/subagent-statusline.sh`.
