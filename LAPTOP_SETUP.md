# Laptop setup

This repository contains locked Julia environments for the course root and the
Week 2 package. On a Windows laptop, install Git, open PowerShell, and run:

```powershell
git clone https://github.com/shy2k/EC991-work.git
Set-Location EC991-work
powershell -ExecutionPolicy Bypass -File .\setup-laptop.ps1
```

The script installs Python and Julia with `winget` when needed, installs the
Python practice dependencies, restores Julia packages from the committed
`Project.toml` and `Manifest.toml` files, runs the Week 1 system check, and runs
the Week 2 package tests. Python 3.11 and Julia 1.10 or newer are required.

## Linux

Install Git, Python 3.11 or newer, and Julia 1.10 or newer using your Linux
distribution's package manager or the official installers. Then run:

```bash
git clone https://github.com/shy2k/EC991-work.git
cd EC991-work
bash setup-laptop.sh
```

The script creates a local `.venv` for the Python practice dependencies and
restores the Julia environments, runs the Week 1 system check, and runs the
Week 2 package tests. If creating the virtual environment fails, install your
distribution's Python `venv` package and rerun the script.

Open Pluto from the repository root with:

```bash
julia --project=. -e 'using Pluto; Pluto.run()'
```

Then open `week01/lab/week01_julia_basics.jl` in Pluto.

If Julia is already installed, prevent the script from trying to install it:

```powershell
.\setup-laptop.ps1 -SkipJuliaInstall -SkipPythonInstall
```

Open the Week 1 Pluto notebook:

```powershell
julia --project=. -e "using Pluto; Pluto.run()"
```

Then open `week01/lab/week01_julia_basics.jl` in Pluto.

Run the completed Week 2 exercises:

```powershell
Set-Location week02\lab\EC991Week2
julia --project=. run\exercises.jl
```

If PowerShell says `julia` is not recognised immediately after installation,
close and reopen PowerShell so that it reloads `PATH`, then rerun the setup
script.
