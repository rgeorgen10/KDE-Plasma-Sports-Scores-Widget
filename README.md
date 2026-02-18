# Sports Scores Widget - Plasma 6 Edition

A KDE Plasma 6 widget that displays live scores, schedules, and standings for NHL, NBA, NFL, and MLB.

![Sports Scores Widget](screenshot.png)

## Features

- **Live Scores**: View real-time scores for ongoing games
- **Schedule**: Check upcoming games and their times
- **Standings**: See team rankings and records
- **Multiple Leagues**: Support for NHL, NBA, NFL, and MLB
- **Auto-refresh**: Configurable refresh interval (30-600 seconds)
- **Clean Interface**: Modern design that integrates seamlessly with Plasma 6

## Requirements

- KDE Plasma 6.0 or higher
- Qt 6.x
- Internet connection (for fetching live sports data)

## Installation

### Method 1: Using the install script (Recommended)

1. Extract the widget files
2. Open a terminal in the widget directory
3. Run the installation script:
   ```bash
   ./install.sh
   ```

### Method 2: Manual installation

```bash
kpackagetool6 --type=Plasma/Applet --install /path/to/sports-scores-widget-plasma6
```

### Method 3: System-wide installation (requires root)

```bash
sudo kpackagetool6 --type=Plasma/Applet --install /path/to/sports-scores-widget-plasma6 --global
```

## Usage

1. Right-click on your desktop or panel
2. Select "Add Widgets..."
3. Search for "Sports Scores"
4. Drag the widget to your desired location

## Configuration

Right-click on the widget and select "Configure Sports Scores..." to access settings:

- **Refresh Interval**: Set how often the widget fetches new data (30-600 seconds)
- **Default League**: Choose which league to display when the widget loads (NHL, NBA, NFL, MLB)

## Upgrading from Plasma 5

This is a complete rewrite for Plasma 6 with the following changes:

### Key Updates

1. **Qt 6 Migration**: Updated from Qt 5.15 to Qt 6.x
2. **New Import Statements**: 
   - Changed from `QtQuick 2.15` to `QtQuick`
   - Replaced `org.kde.plasma.core 2.0` with `org.kde.plasma.core`
   - Added `org.kde.kirigami` for modern UI components
3. **Kirigami Integration**: Now uses Kirigami components for better theming and consistency
4. **Improved Configuration**: Updated config UI using KCM.SimpleKCM
5. **Better Error Handling**: Enhanced error messages using Kirigami.InlineMessage
6. **Modern UI Components**: Replaced deprecated PlasmaComponents with Qt Quick Controls 2

### What Changed

**Plasma 5 imports:**
```qml
import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
```

**Plasma 6 imports:**
```qml
import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
```

### Backward Compatibility

This widget is **not compatible** with Plasma 5. If you're still using Plasma 5, please use the original version of the widget.

## Data Source

This widget fetches data from ESPN's public API. No API key is required.

## Troubleshooting

### Widget doesn't appear after installation

1. Try restarting Plasma:
   ```bash
   plasmashell --replace &
   ```

2. Check if the widget is installed:
   ```bash
   kpackagetool6 --type=Plasma/Applet --show com.example.sportsscores
   ```

### No data is displayed

- Check your internet connection
- Verify that ESPN's API is accessible
- Check the refresh interval in settings (it may be waiting for the next refresh)
- Try manually refreshing by clicking the "Refresh" button

### Widget shows errors

- The widget displays error messages when data cannot be fetched
- Common causes include network issues or API unavailability
- Try refreshing manually after checking your connection

### Uninstalling

To remove the widget:
```bash
kpackagetool6 --type=Plasma/Applet --remove com.example.sportsscores
```

## Development

### Project Structure

```
sports-scores-widget-plasma6/
├── contents/
│   ├── code/
│   │   └── sportsapi.js       # API handling and data parsing
│   └── ui/
│       ├── main.qml            # Main widget interface
│       ├── config.qml          # Configuration UI
│       └── configGeneral.qml   # Config descriptor
├── metadata.json               # Widget metadata
├── install.sh                  # Installation script
└── README.md                   # This file
```

### Building and Testing

To test changes without installing:
```bash
plasmoidviewer -a /path/to/sports-scores-widget-plasma6
```

### Customization

You can modify the widget to:
- Add more sports leagues (edit `sportsapi.js`)
- Change the refresh interval defaults (edit `config.qml`)
- Customize the UI appearance (edit `main.qml`)
- Add additional data views (create new components in `main.qml`)

## License

GPL-2.0+

## Credits

- Widget created for KDE Plasma 6
- Sports data provided by ESPN API
- Icons from KDE icon themes

## Contributing

Feel free to submit issues and enhancement requests!

## Changelog

### Version 2.0 (Plasma 6)
- Complete rewrite for Plasma 6 compatibility
- Migrated to Qt 6
- Integrated Kirigami components
- Improved configuration interface
- Enhanced error handling
- Modern UI design

### Version 1.0 (Plasma 5)
- Initial release for Plasma 5
- Basic score, schedule, and standings views
- Support for NHL, NBA, NFL, MLB
