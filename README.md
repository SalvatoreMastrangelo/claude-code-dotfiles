# claude-code-dotfiles

My Claude Code status line, kept here so every machine gets the same one.
Claude Code does not sync `~/.claude/settings.json` across machines, so this repo does it.

```
Fable 5.1 │ ctx ▓▓░░░░░░░░░░░░░░░░░ 12% │ 5h ▓▓▓▓░░░░░░░░░░░░░░░ 23% ↻ 16:40
```

- **Model** currently in use
- **ctx**: share of the context window used
- **5h**: share of the 5-hour usage limit consumed, and the time the window resets
  (shows `--` until the first response of a session)

The bars stretch to fill the terminal width. Below 5 blocks each they are dropped
(`Fable 5.1 │ ctx 12% │ 5h 23% ↻ 16:40`), and on very narrow terminals the reset time goes too.
Bars are gray, yellow from 75%, red from 90%.

## Install

Needs `jq` (`apt install jq` / `brew install jq`).

```sh
git clone git@github.com:SalvatoreMastrangelo/claude-code-dotfiles.git
cd claude-code-dotfiles
./install.sh
```

`install.sh` copies `statusline.sh` to `~/.claude/` and adds the `statusLine` entry to
`~/.claude/settings.json`. Every other setting in that file is left alone, and the previous
version is saved as `settings.json.bak` when a change is made.

## Update

```sh
git pull && ./install.sh
```

After editing `~/.claude/statusline.sh` directly on a machine, copy it back here and commit
so the other machines can pull it.

## Tuning

At the top of `statusline.sh`:

- `MIN_BAR`: narrowest bar before falling back to the compact form
- `MARGIN`: columns left free for Claude Code's own indentation; raise it if the line wraps

## Uninstall

Remove the `statusLine` entry from `~/.claude/settings.json` and delete `~/.claude/statusline.sh`.
