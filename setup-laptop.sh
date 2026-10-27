#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

for command_name in git python3 julia; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Error: %s is required. Install it with your Linux distribution package manager, then rerun this script.\n' "$command_name" >&2
        exit 1
    fi
done

if ! python3 -c 'import sys; sys.exit(sys.version_info < (3, 11))'; then
    printf 'Error: Python 3.11 or newer is required.\n' >&2
    exit 1
fi

if ! julia -e 'VERSION >= v"1.10" || error("Julia 1.10 or newer is required")' >/dev/null; then
    printf 'Error: Julia 1.10 or newer is required.\n' >&2
    exit 1
fi

venv_dir="$repo_root/.venv"
if [[ ! -x "$venv_dir/bin/python" ]]; then
    printf 'Creating Python virtual environment...\n'
    python3 -m venv "$venv_dir"
fi

printf 'Installing the Python practice dependencies...\n'
"$venv_dir/bin/python" -m pip install --requirement "$repo_root/requirements.txt"

printf 'Instantiating the course Julia environment...\n'
julia --project="$repo_root" -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
julia --project="$repo_root" "$repo_root/setup/week01_check.jl"

week2="$repo_root/week02/lab/EC991Week2"
printf 'Instantiating and testing the Week 2 package...\n'
julia --project="$week2" -e 'using Pkg; Pkg.instantiate(); Pkg.test()'

printf 'Environment ready. See LAPTOP_SETUP.md to start Pluto.\n'