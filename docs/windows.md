# Windows

The regular responsive Flutter window has a 360×540 minimum and supports tray Open, Refresh and Exit actions. Inno Setup packages the full Release bundle, Start Menu entry, optional desktop shortcut and uninstall support. Its opt-in task creates a per-user Task Scheduler daily trigger around 09:00 and removes it during uninstall.

Current Flutter stable supports Windows 10/11. Windows 7 is not supported or advertised; supporting it would require an insecure frozen legacy Flutter/toolchain and incompatible plugin audit. The installer targets x64-compatible Windows 10/11.
