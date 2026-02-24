# frontier-startup-cost-eval

This Git repo holds the build and run scripts necessary to reproduce the comparison of sbcast, Spindle, and Copper on Frontier for Cray User Group 2026.

## Access to sbcast, Spindle, and Copper

`sbcast` and Spindle are both provided by RPMs installed in the node images, and are available directly via the `spindle` and `sbcast` commands.
Copper is provided by UMS046 (`module load ums ums046; module load copper`).

## Dependencies specific to Frontier

There are intentionally-few dependencies specific to Frontier. The primary dependency is the `miniforge3` module, which is used to provide conda. You can easily switch to a different module by changing `builds/common_modules.sh`.
