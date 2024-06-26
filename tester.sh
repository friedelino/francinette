#! /usr/bin/env nix-shell
#! nix-shell -i bash /home/frido/bin/francinette-app/shell.nix
DIR="$HOME/bin/francinette-app"

current_dir=$PWD

# check for updates
version=68

cd "$current_dir" || exit
# source "$DIR"/venv/bin/activate

python "$DIR"/main.py "$@"
