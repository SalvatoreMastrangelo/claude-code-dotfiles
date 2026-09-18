#!/bin/bash
# Claude Code subagent rows: the default "name · description · token count" plus the model,
#   Count lines in dotfiles · Haiku 4.5 · 21.9k tokens
# Receives every visible subagent row as one JSON object on stdin and prints one
# {"id", "content"} line per row it overrides
# (see https://code.claude.com/docs/en/statusline#subagent-status-lines).
# Rows whose model is not resolved yet are left to the default rendering.

exec jq -c '
  # "claude-haiku-4-5-20251001" -> "Haiku 4.5"; anything that is not a claude-* id is shown as is
  def pretty_model:
    sub("\\[[^]]*\\]$"; "") as $id
    | if ($id | test("^claude-")) then
        ($id | sub("^claude-"; "") | sub("-[0-9]{8}$"; "") | split("-")) as $parts
        | [ ($parts | map(select(test("^[0-9]+$") | not) | (.[0:1] | ascii_upcase) + .[1:]) | join(" ")),
            ($parts | map(select(test("^[0-9]+$"))) | join(".")) ]
        | map(select(. != "")) | join(" ")
      else $id end;

  # 842 -> "842 tokens", 21891 -> "21.9k tokens", 1234567 -> "1.2M tokens"
  def pretty_tokens:
    if . >= 1000000 then "\((. / 100000 | round) / 10)M tokens"
    elif . >= 1000 then "\((. / 100 | round) / 10)k tokens"
    else "\(.) tokens" end;

  # Shorten to $max characters, ending in an ellipsis
  def fit($max):
    if length <= $max then . elif $max < 1 then "" else .[0:$max - 1] + "…" end;

  "[2m" as $dim | "[0m" as $rst
  | (.columns // 80) as $cols
  | .tasks[]?
  | select(.model != null)
  | (.model | pretty_model) as $model
  | (if .tokenCount != null then (.tokenCount | pretty_tokens) else null end) as $tokens
  | ([.name, (.label // .description)] | map(select(. != null and . != "")) | join(" · ")) as $title
  # Whatever the fixed parts leave of the row goes to the title
  | ([$model, $tokens] | map(select(. != null)) | map(3 + length) | add) as $fixed
  | ($title | fit($cols - $fixed)) as $title
  | {
      id,
      content: (
        $title
        + "\($dim) · \($rst)" + $model
        + (if $tokens != null then "\($dim) · \($tokens)\($rst)" else "" end)
      )
    }
'
