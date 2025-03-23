#!/bin/sh
echo -ne '\033c\033]0;Petals and Potions\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Petals and Potions.x86_64" "$@"
