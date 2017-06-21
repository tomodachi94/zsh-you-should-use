#!/bin/zsh

function ysu_message() {
  local BOLD='\033[1m'
  local RED='\e[31m'
  local NONE='\033[00m'
  echo "${BOLD}Found existing alias for \"$1\". You should use: \"$2\"${NONE}"
}


function _check_global_aliases() {
  IFS="\n"
  local global_aliases="$(alias -g)"
  for entry in $global_aliases; do
    local tokens=("${(@s/=/)entry}")
    local k="${tokens[1]}"
    # Need to remove leading and trailing '
    local v="${tokens[2]:1:-1}"

    if [[ "$1" = *"$v"* ]]; then
      ysu_message $v $k
    fi
  done
}


function _check_aliases() {
  local found_aliases=()
  local best_match=""

  # Find alias matches
  for k in "${(@k)aliases}"; do
    local v="${aliases[$k]}"
    if [[ "$1" = "$v" || "$1" = "$v "* ]]; then

      # if the alias is the same length as its command
      # we assume that it is there to cater for typos.
      # If not, then the alias would not save any time
      # for the user and so doesnt hold much value anyway
      if [[ "${#v}" -eq "${#k}" ]]; then
        break
      fi

      found_aliases+="$k"

      if [[ "${#v}" -gt "${#best_match}" ]]; then
        best_match="$k"
      fi
    fi
  done

  # Print result matches based on current mode
  if [[ -z "$YSU_MODE" || "$YSU_MODE" = "ALL" ]]; then
    for k in $found_aliases; do
      local v="${aliases[$k]}"
      ysu_message "$v" "$k"
    done

  elif [[ "$YSU_MODE" = "BESTMATCH" && -n "$best_match" ]]; then
    local v="${aliases[$best_match]}"
    ysu_message "$v" "$best_match"
  fi

  # Prevent command from running if hardcore mode enabled
  if [[ "$YSU_HARDCORE" = 1 && -n "$found_aliases" ]]; then
      echo "${BOLD}${RED}You Should Use hardcore mode enabled. Use your aliases!${NONE}"
      kill -s INT $$
  fi
}

add-zsh-hook preexec _check_aliases
add-zsh-hook preexec _check_global_aliases
