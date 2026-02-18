# Migration Guide: Plasma 5 to Plasma 6

This document details the changes made to upgrade the Sports Scores widget from Plasma 5 to Plasma 6.

## Overview

The Plasma 6 upgrade required significant changes due to the migration from Qt 5 to Qt 6 and updates to KDE's Plasma framework APIs.

## Import Statement Changes

### Qt Imports

**Plasma 5:**
```qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
```

**Plasma 6:**
```qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
```

### Plasma Framework Imports

**Plasma 5:**
```qml
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
```

**Plasma 6:**
```qml
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
```

## Component Replacements

### Button Component

**Plasma 5:**
```qml
PlasmaComponents3.Button {
    text: "Click me"
    flat: true
}
```

**Plasma 6:**
```qml
QQC2.Button {
    text: "Click me"
    flat: true
    highlighted: isActive  // New property for active state
}
```

### ScrollView Component

**Plasma 5:**
```qml
ScrollView {
    anchors.fill: parent
    clip: true
    // content here
}
```

**Plasma 6:**
```qml
QQC2.ScrollView {
    anchors.fill: parent
    clip: true
    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
    // content here
}
```

### BusyIndicator

**Plasma 5:**
```qml
PlasmaComponents3.BusyIndicator {
    visible: isLoading
}
```

**Plasma 6:**
```qml
QQC2.BusyIndicator {
    visible: isLoading
    running: isLoading  // New: explicitly set running state
}
```

### Label Component

**Plasma 5:**
```qml
PlasmaComponents3.Label {
    text: "Hello"
    font.pointSize: PlasmaCore.Theme.smallestFont.pointSize
    color: PlasmaCore.Theme.textColor
}
```

**Plasma 6:**
```qml
PlasmaComponents.Label {
    text: "Hello"
    font: Kirigami.Theme.smallFont
    color: Kirigami.Theme.textColor
}
```

### SpinBox

**Plasma 5:**
```qml
PlasmaComponents3.SpinBox {
    id: spinBox
    from: 30
    to: 600
    value: 60
}
```

**Plasma 6:**
```qml
QQC2.SpinBox {
    id: spinBox
    from: 30
    to: 600
    value: 60
    textFromValue: function(value) {
        return value + " seconds"
    }
    valueFromText: function(text) {
        return parseInt(text)
    }
}
```

### ComboBox

**Plasma 5:**
```qml
PlasmaComponents3.ComboBox {
    id: comboBox
    model: ["Option 1", "Option 2"]
    currentIndex: 0
}
```

**Plasma 6:**
```qml
QQC2.ComboBox {
    id: comboBox
    model: ["Option 1", "Option 2"]
    onCurrentValueChanged: {
        // Handle value change
    }
}
```

## New Kirigami Components

### Card Component

**Plasma 5 (using Rectangle):**
```qml
Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 80
    color: PlasmaCore.Theme.backgroundColor
    border.color: PlasmaCore.Theme.textColor
    border.width: 1
    radius: 5
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        // content
    }
}
```

**Plasma 6 (using Kirigami.Card):**
```qml
Kirigami.Card {
    Layout.fillWidth: true
    
    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        // content
    }
}
```

### PlaceholderMessage

**Plasma 5:**
```qml
PlasmaComponents3.Label {
    visible: items.length === 0
    text: "No items available"
    Layout.alignment: Qt.AlignHCenter
}
```

**Plasma 6:**
```qml
Kirigami.PlaceholderMessage {
    visible: items.length === 0
    text: "No items available"
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
}
```

### InlineMessage

**Plasma 5:**
```qml
PlasmaComponents3.Label {
    visible: errorMessage !== ""
    text: errorMessage
    color: PlasmaCore.Theme.negativeTextColor
    Layout.fillWidth: true
}
```

**Plasma 6:**
```qml
Kirigami.InlineMessage {
    visible: errorMessage !== ""
    text: errorMessage
    type: Kirigami.MessageType.Error
    Layout.fillWidth: true
}
```

## Theme and Styling

### Units

**Plasma 5:**
```qml
width: 400
height: 500
spacing: 10
anchors.margins: 5
```

**Plasma 6:**
```qml
width: Kirigami.Units.gridUnit * 25
height: Kirigami.Units.gridUnit * 31
spacing: Kirigami.Units.largeSpacing
anchors.margins: Kirigami.Units.smallSpacing
```

### Font Sizes

**Plasma 5:**
```qml
font.pointSize: PlasmaCore.Theme.smallestFont.pointSize
font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.5
```

**Plasma 6:**
```qml
font: Kirigami.Theme.smallFont
font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
```

### Colors

**Plasma 5:**
```qml
color: PlasmaCore.Theme.backgroundColor
color: PlasmaCore.Theme.textColor
color: PlasmaCore.Theme.positiveTextColor
color: PlasmaCore.Theme.negativeTextColor
```

**Plasma 6:**
```qml
color: Kirigami.Theme.backgroundColor
color: Kirigami.Theme.textColor
color: Kirigami.Theme.positiveTextColor
color: Kirigami.Theme.negativeTextColor
```

## Configuration UI Changes

### Plasma 5 Config

**config.qml:**
```qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.components 3.0 as PlasmaComponents3

ColumnLayout {
    property alias cfg_refreshInterval: refreshIntervalSpinBox.value
    property alias cfg_defaultLeague: defaultLeagueComboBox.currentIndex
    
    RowLayout {
        PlasmaComponents3.Label {
            text: "Refresh interval (seconds):"
        }
        PlasmaComponents3.SpinBox {
            id: refreshIntervalSpinBox
            from: 30
            to: 600
        }
    }
}
```

### Plasma 6 Config

**config.qml:**
```qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_refreshInterval: refreshIntervalSpinBox.value
    property string cfg_defaultLeague
    
    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: "Refresh interval:"
            QQC2.SpinBox {
                id: refreshIntervalSpinBox
                from: 30
                to: 600
            }
        }
    }
}
```

**configGeneral.qml (new file required):**
```qml
import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "preferences-system"
        source: "config.qml"
    }
}
```

## Metadata Changes

### Plasma 5 metadata.json

```json
{
    "KPlugin": {
        "Version": "1.0"
    },
    "X-Plasma-API": "declarativeappletscript",
    "X-Plasma-MainScript": "ui/main.qml"
}
```

### Plasma 6 metadata.json

```json
{
    "KPlugin": {
        "Version": "2.0"
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}
```

## Property Bindings

### Configuration Access

**Plasma 5:**
```qml
property string currentLeague: "nhl"
Timer {
    interval: 60000  // hardcoded
}
```

**Plasma 6:**
```qml
property string currentLeague: plasmoid.configuration.defaultLeague || "nhl"
Timer {
    interval: (plasmoid.configuration.refreshInterval || 60) * 1000
}
```

## Installation Command Changes

**Plasma 5:**
```bash
plasmapkg2 --type=plasmoid --install widget-directory
```

**Plasma 6:**
```bash
kpackagetool6 --type=Plasma/Applet --install widget-directory
```

## Testing Changes

**Plasma 5:**
```bash
plasmoidviewer -a widget-directory
```

**Plasma 6:**
```bash
plasmoidviewer -a widget-directory
```
(Command name remains the same, but it now launches the Plasma 6 version)

## Summary of Breaking Changes

1. **Versionless imports**: Qt 6 uses versionless imports (`import QtQuick` instead of `import QtQuick 2.15`)
2. **Component namespace changes**: PlasmaComponents3 becomes PlasmaComponents
3. **Kirigami integration**: Many UI components now use Kirigami instead of Plasma components
4. **KCM for configuration**: Config pages now extend KCM.SimpleKCM
5. **Unit system**: Hardcoded pixel values replaced with Kirigami.Units
6. **Theme access**: PlasmaCore.Theme partially replaced by Kirigami.Theme
7. **Tool aliasing**: QtQuick.Controls imported as QQC2 to avoid conflicts

## Best Practices for Plasma 6

1. **Use Kirigami components** for better cross-platform compatibility
2. **Leverage Kirigami.Units** for proper scaling across different display sizes
3. **Use FormLayout** in configuration pages for consistent alignment
4. **Prefer Kirigami.Card** over custom Rectangle-based cards
5. **Use PlaceholderMessage** for empty states
6. **Use InlineMessage** for error/warning messages
7. **Set explicit `running` property** on BusyIndicator
8. **Use `highlighted` property** on buttons instead of just `flat`

## Common Migration Issues

### Issue: Widget doesn't load
**Solution**: Check import statements and ensure all version numbers are removed

### Issue: Components not found
**Solution**: Update component namespaces (PlasmaComponents3 → PlasmaComponents)

### Issue: Configuration doesn't save
**Solution**: Ensure config.qml extends KCM.SimpleKCM and configGeneral.qml exists

### Issue: Incorrect spacing/sizing
**Solution**: Replace hardcoded pixel values with Kirigami.Units

### Issue: ScrollView behaves incorrectly
**Solution**: Explicitly set ScrollBar policies on QQC2.ScrollView

## Additional Resources

- [KDE Plasma 6 Porting Guide](https://develop.kde.org/docs/plasma/widget/)
- [Kirigami Documentation](https://develop.kde.org/frameworks/kirigami/)
- [Qt 6 Migration Guide](https://doc.qt.io/qt-6/portingguide.html)
