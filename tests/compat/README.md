Stand-ins for QML modules that older Plasma versions only provide inside plasmashell,
not as importable modules. Used by the Debian 13 (Plasma 6.3) CI job via QML_IMPORT_PATH,
never shipped in the plasmoid.

- org.kde.plasma.plasmoid: PlasmaExtras.Representation imports it for Plasmoid.formFactor;
  libplasma 6.3 registers it only at runtime in the shell.
