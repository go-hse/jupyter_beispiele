@echo off
for /r %%f in (*.ipynb) do (
    echo Entferne Outputs in %%f
    python reset.py %%f
)