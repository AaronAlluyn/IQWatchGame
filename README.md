# [IQWatchGame]

A Garmin Connect IQ watch app that is a currently unspecified game...

## Supported Devices

* Forerunner 165
* Forerunner 255 Music
* Venu 2S
* Vivoactive 5

## Development

1. Open the project folder in VS Code.
2. Press `Ctrl + F5` to run without debugging.
3. Select the target device profile when prompted to launch the Connect IQ Simulator.

### Building and Deploying to Device

1. Open the VS Code Command Palette.
2. Run `Monkey C: Build for Device`.
3. Select the target device and destination folder. This will output a compiled `.prg` file.
4. Connect the Garmin watch to the PC via USB.
5. Navigate to the watch's file system and copy the compiled `.prg` file directly into the `GARMIN/APPS/` directory.
6. Disconnect the watch. The application will be accessible at the bottom of the device's activity tracking menu.