# Sports Scores Widget - Plasma 6 Upgrade Summary

## What Changed

This is a complete upgrade of your Sports Scores widget from Plasma 5 to Plasma 6. The widget maintains all its original functionality while adopting Plasma 6's modern framework and improved UI components.

## Key Improvements

### 1. **Qt 6 Migration**
- Upgraded from Qt 5.15 to Qt 6
- Removed version numbers from import statements (Qt 6 standard)
- Updated to use Qt Quick Controls 2 (QQC2) namespace

### 2. **Kirigami Integration**
- Replaced custom Rectangle-based cards with `Kirigami.Card` components
- Added `Kirigami.PlaceholderMessage` for better empty state handling
- Implemented `Kirigami.InlineMessage` for improved error display
- Used `Kirigami.Units` for proper scaling across different displays

### 3. **Modern UI Components**
- Buttons now use `highlighted` property for active states
- ScrollView includes explicit scrollbar policies
- BusyIndicator has proper `running` state management
- Form-based configuration layout with `Kirigami.FormLayout`

### 4. **Enhanced Configuration**
- New `KCM.SimpleKCM` based configuration
- Added `configGeneral.qml` descriptor file (required for Plasma 6)
- Improved configuration UI with better labels and descriptions
- Default league now properly saved as string instead of index

### 5. **Theme Consistency**
- Migrated from hardcoded pixel values to `Kirigami.Units`
- Updated color references to use `Kirigami.Theme` where appropriate
- Better integration with system themes

### 6. **Improved Installation**
- Updated installation script to use `kpackagetool6`
- Added Plasma 6 version detection
- Better error handling and user feedback

## Files Modified/Added

### Modified Files:
- `metadata.json` - Updated for Plasma 6 requirements
- `contents/ui/main.qml` - Complete rewrite with Plasma 6 APIs
- `contents/ui/config.qml` - Updated to KCM.SimpleKCM format
- `install.sh` - Updated for Plasma 6 tools

### New Files:
- `contents/ui/configGeneral.qml` - Required config descriptor
- `MIGRATION.md` - Detailed migration guide

### Unchanged Files:
- `contents/code/sportsapi.js` - No changes needed (pure JavaScript)

## Feature Parity

All original features are preserved:
- ✅ Live scores for NHL, NBA, NFL, MLB
- ✅ Schedule view with dates and times
- ✅ Standings with team rankings
- ✅ Auto-refresh with configurable interval
- ✅ Manual refresh button
- ✅ League selection tabs
- ✅ View type switching (Scores/Schedule/Standings)

## Breaking Changes

This widget is **NOT compatible** with Plasma 5. If you need to support both:
1. Keep the original Plasma 5 version separate
2. Use this Plasma 6 version only on Plasma 6 systems
3. The installation script will detect and warn if Plasma 6 is not found

## Installation

### Quick Install:
```bash
cd sports-scores-widget-plasma6
./install.sh
```

### Manual Install:
```bash
kpackagetool6 --type=Plasma/Applet --install sports-scores-widget-plasma6
```

### After Installation:
1. Restart Plasma Shell: `plasmashell --replace &`
2. Right-click desktop/panel → "Add Widgets..."
3. Search for "Sports Scores"
4. Add to your desired location

## Testing Recommendations

Before deploying, test the following:
1. **Basic Functionality**: Verify all three views (Scores, Schedule, Standings) work
2. **League Switching**: Test switching between NHL, NBA, NFL, MLB
3. **Configuration**: Open settings and change refresh interval and default league
4. **Refresh**: Test both auto-refresh and manual refresh
5. **Theme Integration**: Check appearance in light and dark themes
6. **Error Handling**: Disconnect network briefly to verify error messages display correctly

## Known Issues

None currently. The widget has been fully updated to Plasma 6 standards.

## Version History

- **v2.0** - Plasma 6 version (this release)
  - Complete rewrite for Qt 6 and Plasma 6
  - Kirigami component integration
  - Improved UI and configuration

- **v1.0** - Plasma 5 version (previous)
  - Original implementation for Plasma 5
  - Basic score, schedule, and standings views

## Support

If you encounter issues:
1. Check the README.md for troubleshooting steps
2. Verify you're running Plasma 6.0 or higher
3. Check the system log: `journalctl -xef | grep plasmashell`
4. Test with plasmoidviewer: `plasmoidviewer -a /path/to/widget`

## Documentation

- `README.md` - User documentation and installation guide
- `MIGRATION.md` - Technical migration guide from Plasma 5 to 6
- This file - Summary of changes and upgrade information

---

**Note**: This is a major version upgrade. While every effort has been made to maintain feature parity, the underlying implementation is completely new. Please report any issues you encounter.
