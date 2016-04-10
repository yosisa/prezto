# Return if requirements are not found.
if (( ! $+commands[peco] )); then
  return 1
fi

function peco-select-history {
  local tac='tail -r'
  if (( $+commands[gtac] )); then
    tac=gtac
  elif (( $+commands[tac] )); then
    tac=tac
  fi

  local sel="$(fc -ln 1 | eval $tac | peco --query "$LBUFFER")"
  if [[ -n "$sel" ]]; then
     BUFFER="$sel"
     CURSOR=$#BUFFER         # move cursor
  fi
  zle -R -c               # refresh
}

zle -N peco-select-history
bindkey '^R' peco-select-history


if (( $+commands[fasd] )); then
  function peco-recent-dirs-cmd { fasd -d }
else
  pmodload 'cdr'
  command -v cdr >/dev/null && function peco-recent-dirs-cmd { cdr -l }
fi
if command -v peco-recent-dirs-cmd >/dev/null; then
  function peco-recent-dirs {
    local dst="$(peco-recent-dirs-cmd | sed -e 's/^[0-9.]* *//' | peco --query "$LBUFFER")"
    if [[ -n "$dst" ]]; then
      BUFFER="cd '$dst'"
      zle accept-line
    else
      zle reset-prompt
    fi
  }

  zle -N peco-recent-dirs
  bindkey '^J' peco-recent-dirs
fi


if (( $+commands[ghq] )); then
  function peco-ghq {
    local dst="$(ghq list --full-path | peco --query \"$LBUFFER\")"
    if [[ -n "$dst" ]]; then
      BUFFER="cd '$dst'"
      zle accept-line
    else
      zle reset-prompt
    fi
  }

  zle -N peco-ghq
  bindkey '^O' peco-ghq
fi
