# vivado-git-tcl-template

## use [digilent-vivado-scritps](https://github.com/Digilent/digilent-vivado-scripts)
- When creating the project, make sure to place the Vivado project in a folder named proj in the local repo.

## use local scripts [::ok::]

### `config.tcl`
Modify according to your project settings.

### `*.xci`
`RUNTIME_PARAM.OUTPUTDIR` of `*.xci` should be set to `../../proj/$_proj_name/$_proj_name.gen/ip/$ip_name`.
You can use `scripts/move_xci.py`:
```bash
python3 scripts/move_xci.py ./src/ip/foo.xci ./src/ip/foo.xci ../../proj/project/project.gen/ip/foo
```
Or,
```bash
python3 scripts/fix_xci.py
```
which fix all xci files at once.

### linux
```bash
make clean
make project
make gui
```

### windows
```batch
del /Q proj/*
```
```powershell
Remove-Item -Path "proj\*" -Recurse -Force
```
```powershell
./create.bat
./open.bat
```
