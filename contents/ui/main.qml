import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../../contents/code/sportsapi.js" as SportsAPI

PlasmoidItem {
    id: root

    width: Kirigami.Units.gridUnit * 25
    height: Kirigami.Units.gridUnit * 33

    property var leagues: ["nhl", "nba", "nfl", "mlb"]
    property string currentLeague: plasmoid.configuration.defaultLeague || "nhl"
    property string currentView: "scores"
    property var scoresData: ({})
    property var standingsData: ({})
    property var scheduleData: ({})
    property bool isLoading: false
    property string errorMessage: ""

    // Day offset: 0 = today, -1 = yesterday, +1 = tomorrow
    property int dayOffset: 0

    // Resolved at PlasmoidItem root so the relative path is anchored to main.qml's directory
    readonly property url logoUrl: Qt.resolvedUrl("../images/logo.svg")

    // Tell the Plasma shell to use our SVG as the widget icon (task manager,
    // widget explorer, panel collapsed state, etc.)
    Plasmoid.icon: Qt.resolvedUrl("../images/logo.svg")

    // Compact representation: shown when the widget lives in a panel and is
    // collapsed.  We render the same logo SVG so the panel button matches the
    // widget identity throughout the shell.
    compactRepresentation: Item {
        readonly property bool inPanel: (plasmoid.location === PlasmaCore.Types.TopEdge
                                      || plasmoid.location === PlasmaCore.Types.BottomEdge
                                      || plasmoid.location === PlasmaCore.Types.LeftEdge
                                      || plasmoid.location === PlasmaCore.Types.RightEdge)

        Image {
            anchors.centerIn: parent
            // Fill the compact button but never exceed the actual available space
            width:  Math.min(parent.width,  parent.height)
            height: width
            source: root.logoUrl
            fillMode: Image.PreserveAspectFit
            smooth: true
            antialiasing: true
        }

        // Open the full representation when the user clicks the panel button
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    function offsetDateString(offset) {
        var d = new Date()
        d.setDate(d.getDate() + offset)
        var y = d.getFullYear()
        var m = ("0" + (d.getMonth() + 1)).slice(-2)
        var day = ("0" + d.getDate()).slice(-2)
        return y + "" + m + "" + day
    }

    function dayLabel(offset) {
        if (offset === 0) return "Today"
        if (offset === -1) return "Yesterday"
        if (offset === 1) return "Tomorrow"
        var d = new Date()
        d.setDate(d.getDate() + offset)
        return d.toLocaleDateString(Qt.locale(), "MMM d")
    }

    // Cache key: league + date
    readonly property string currentKey: currentLeague + "_" + offsetDateString(dayOffset)

    // Incremented after every fetch so QML re-evaluates bindings that read
    // scoresData/scheduleData/standingsData even when currentKey hasn't changed
    // (e.g. when the user hits the manual Refresh button on the same day).
    property int refreshToken: 0

    Timer {
        id: refreshTimer
        interval: (plasmoid.configuration.refreshInterval || 60) * 1000
        running: true
        repeat: true
        onTriggered: refreshCurrentView()
    }

    Component.onCompleted: {
        refreshCurrentView()
    }

    function refreshCurrentView() {
        isLoading = true
        errorMessage = ""
        if (currentView === "scores")         fetchScores()
        else if (currentView === "schedule")  fetchSchedule()
        else if (currentView === "standings") fetchStandings()
    }

    function fetchScores() {
        var dateStr = offsetDateString(dayOffset)
        SportsAPI.fetchScoresForDate(currentLeague, dateStr, function(data) {
            if (data.error) {
                errorMessage = data.error
            } else {
                var updated = {}
                for (var k in scoresData) updated[k] = scoresData[k]
                updated[currentLeague + "_" + dateStr] = data
                scoresData = updated
            }
            isLoading = false
            refreshToken++
        })
    }

    function fetchSchedule() {
        var dateStr = offsetDateString(dayOffset)
        SportsAPI.fetchScoresForDate(currentLeague, dateStr, function(data) {
            if (data.error) {
                errorMessage = data.error
            } else {
                var updated = {}
                for (var k in scheduleData) updated[k] = scheduleData[k]
                updated[currentLeague + "_" + dateStr] = data
                scheduleData = updated
            }
            isLoading = false
            refreshToken++
        })
    }

    function fetchStandings() {
        SportsAPI.fetchStandings(currentLeague, function(data) {
            if (data.error) {
                errorMessage = data.error
            } else {
                var updated = {}
                for (var k in standingsData) updated[k] = standingsData[k]
                updated[currentLeague] = data
                standingsData = updated
            }
            isLoading = false
            refreshToken++
        })
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 33
        Layout.minimumWidth: Kirigami.Units.gridUnit * 22
        Layout.minimumHeight: Kirigami.Units.gridUnit * 27

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header: logo + title ─────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                color: Kirigami.Theme.highlightColor

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    Image {
                        // Use root.logoUrl — resolved from the PlasmoidItem file scope
                        source: root.logoUrl
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    PlasmaComponents.Label {
                        text: "Sports Scores"
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                        color: Kirigami.Theme.highlightedTextColor
                        Layout.fillWidth: true
                    }
                }
            }

            // ── League tabs ──────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                color: Kirigami.Theme.backgroundColor

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    Repeater {
                        model: leagues

                        QQC2.Button {
                            text: modelData.toUpperCase()
                            Layout.fillWidth: true
                            flat: currentLeague !== modelData
                            highlighted: currentLeague === modelData
                            onClicked: {
                                currentLeague = modelData
                                refreshCurrentView()
                            }
                        }
                    }
                }
            }

            // ── View selector ────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                color: Kirigami.Theme.backgroundColor

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Button {
                        text: "Scores"
                        Layout.fillWidth: true
                        flat: currentView !== "scores"
                        highlighted: currentView === "scores"
                        onClicked: { currentView = "scores"; refreshCurrentView() }
                    }

                    QQC2.Button {
                        text: "Schedule"
                        Layout.fillWidth: true
                        flat: currentView !== "schedule"
                        highlighted: currentView === "schedule"
                        onClicked: { currentView = "schedule"; refreshCurrentView() }
                    }

                    QQC2.Button {
                        text: "Standings"
                        Layout.fillWidth: true
                        flat: currentView !== "standings"
                        highlighted: currentView === "standings"
                        onClicked: { currentView = "standings"; refreshCurrentView() }
                    }
                }
            }

            // ── Day navigation (scores + schedule only) ──────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: currentView !== "standings" ? Kirigami.Units.gridUnit * 2.5 : 0
                color: Kirigami.Theme.alternateBackgroundColor
                visible: currentView !== "standings"
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Kirigami.Units.smallSpacing
                    anchors.rightMargin: Kirigami.Units.smallSpacing
                    spacing: 0

                    QQC2.Button {
                        icon.name: "arrow-left"
                        flat: true
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                        QQC2.ToolTip.text: "Previous day"
                        QQC2.ToolTip.visible: hovered
                        onClicked: { dayOffset -= 1; refreshCurrentView() }
                    }

                    PlasmaComponents.Label {
                        text: dayLabel(dayOffset)
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        font.bold: dayOffset === 0
                    }

                    QQC2.Button {
                        icon.name: "arrow-right"
                        flat: true
                        enabled: currentView === "schedule" ? dayOffset < 14 : dayOffset < 1
                        opacity: (currentView === "schedule" ? dayOffset < 14 : dayOffset < 1) ? 1.0 : 0.3
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                        QQC2.ToolTip.text: "Next day"
                        QQC2.ToolTip.visible: hovered
                        onClicked: { dayOffset += 1; refreshCurrentView() }
                    }

                    QQC2.Button {
                        text: "Today"
                        flat: true
                        visible: dayOffset !== 0
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3.5
                        onClicked: { dayOffset = 0; refreshCurrentView() }
                    }
                }
            }

            // ── Content area ─────────────────────────────────────────────
            // All three views stay permanently in the tree, switched by
            // 'visible'. This keeps their Repeater bindings live so data
            // shows immediately when the async fetch completes, regardless
            // of which tab is active at that moment.
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Kirigami.Theme.backgroundColor

                QQC2.ScrollView {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    clip: true
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.BusyIndicator {
                            visible: isLoading
                            Layout.alignment: Qt.AlignHCenter
                            running: isLoading
                        }

                        Kirigami.InlineMessage {
                            visible: errorMessage !== ""
                            text: errorMessage
                            type: Kirigami.MessageType.Error
                            Layout.fillWidth: true
                        }

                        // ── Scores view (always in tree, hidden when not active) ──
                        ColumnLayout {
                            visible: currentView === "scores"
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: refreshToken, scoresData[currentKey] ? scoresData[currentKey].games || [] : []

                                Kirigami.Card {
                                    Layout.fillWidth: true

                                    contentItem: ColumnLayout {
                                        spacing: Kirigami.Units.smallSpacing

                                        PlasmaComponents.Label {
                                            text: modelData.status || "Unknown"
                                            font: Kirigami.Theme.smallFont
                                            color: modelData.isLive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Kirigami.Units.largeSpacing

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: Kirigami.Units.smallSpacing

                                                RowLayout {
                                                    spacing: Kirigami.Units.smallSpacing
                                                    Image {
                                                        source: modelData.homeLogo || ""
                                                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: modelData.homeLogo ? true : false
                                                    }
                                                    PlasmaComponents.Label { text: modelData.homeTeam || "Home"; font.bold: true }
                                                }
                                                RowLayout {
                                                    spacing: Kirigami.Units.smallSpacing
                                                    Image {
                                                        source: modelData.awayLogo || ""
                                                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: modelData.awayLogo ? true : false
                                                    }
                                                    PlasmaComponents.Label { text: modelData.awayTeam || "Away" }
                                                }
                                            }

                                            ColumnLayout {
                                                spacing: Kirigami.Units.smallSpacing
                                                PlasmaComponents.Label {
                                                    text: modelData.homeScore !== undefined ? modelData.homeScore : "-"
                                                    font.bold: true
                                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                                                }
                                                PlasmaComponents.Label {
                                                    text: modelData.awayScore !== undefined ? modelData.awayScore : "-"
                                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Kirigami.PlaceholderMessage {
                                visible: !isLoading && (!scoresData[currentKey] || !scoresData[currentKey].games || scoresData[currentKey].games.length === 0)
                                text: "No games on " + dayLabel(dayOffset)
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            }
                        }

                        // ── Schedule view (always in tree, hidden when not active) ──
                        ColumnLayout {
                            visible: currentView === "schedule"
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: refreshToken, scheduleData[currentKey] ? scheduleData[currentKey].games || [] : []

                                Kirigami.Card {
                                    Layout.fillWidth: true

                                    contentItem: ColumnLayout {
                                        spacing: Kirigami.Units.smallSpacing

                                        // Game time / status row
                                        RowLayout {
                                            Layout.fillWidth: true
                                            PlasmaComponents.Label {
                                                text: (modelData.dayOfWeek ? modelData.dayOfWeek + " · " : "") + (modelData.time || modelData.status || "TBD")
                                                font: Kirigami.Theme.smallFont
                                                color: "white"
                                                Layout.fillWidth: true
                                            }
                                            PlasmaComponents.Label {
                                                text: modelData.venue || ""
                                                font: Kirigami.Theme.smallFont
                                                color: Kirigami.Theme.disabledTextColor
                                                visible: modelData.venue ? true : false
                                                elide: Text.ElideRight
                                                Layout.maximumWidth: Kirigami.Units.gridUnit * 8
                                            }
                                        }

                                        // Teams row — mirrors scores layout
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Kirigami.Units.largeSpacing

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: Kirigami.Units.smallSpacing

                                                // Home team
                                                RowLayout {
                                                    spacing: Kirigami.Units.smallSpacing
                                                    Image {
                                                        source: modelData.homeLogo || ""
                                                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: modelData.homeLogo ? true : false
                                                    }
                                                    PlasmaComponents.Label {
                                                        text: modelData.homeTeam || "Home"
                                                        font.bold: true
                                                    }
                                                }

                                                // Away team
                                                RowLayout {
                                                    spacing: Kirigami.Units.smallSpacing
                                                    Image {
                                                        source: modelData.awayLogo || ""
                                                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: modelData.awayLogo ? true : false
                                                    }
                                                    PlasmaComponents.Label {
                                                        text: modelData.awayTeam || "Away"
                                                    }
                                                }
                                            }

                                            // "vs" spacer column (no scores yet for upcoming games)
                                            PlasmaComponents.Label {
                                                text: "vs"
                                                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                                                color: Kirigami.Theme.disabledTextColor
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }

                            Kirigami.PlaceholderMessage {
                                visible: !isLoading && (!scheduleData[currentKey] || !scheduleData[currentKey].games || scheduleData[currentKey].games.length === 0)
                                text: "No games on " + dayLabel(dayOffset)
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            }
                        }

                        // ── Standings view (always in tree, hidden when not active) ──
                        ColumnLayout {
                            visible: currentView === "standings"
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: standingsData[currentLeague] ? standingsData[currentLeague].teams || [] : []

                                Kirigami.Card {
                                    Layout.fillWidth: true

                                    contentItem: RowLayout {
                                        spacing: Kirigami.Units.smallSpacing

                                        PlasmaComponents.Label {
                                            text: modelData.rank || (index + 1)
                                            font.bold: true
                                            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
                                        }

                                        Image {
                                            source: modelData.logo || ""
                                            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                            fillMode: Image.PreserveAspectFit
                                            visible: modelData.logo ? true : false
                                        }

                                        PlasmaComponents.Label {
                                            text: modelData.team || "Team"
                                            Layout.fillWidth: true
                                        }

                                        PlasmaComponents.Label {
                                            text: currentLeague === "nhl"
                                                ? (modelData.points || 0) + " PTS"
                                                : (modelData.wins || 0) + "-" + (modelData.losses || 0)
                                            font: Kirigami.Theme.smallFont
                                        }
                                    }
                                }
                            }

                            Kirigami.PlaceholderMessage {
                                visible: !isLoading && (!standingsData[currentLeague] || !standingsData[currentLeague].teams || standingsData[currentLeague].teams.length === 0)
                                text: "No standings available"
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            }
                        }

                    }
                }
            }

            // ── Footer ───────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                color: Kirigami.Theme.backgroundColor

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing

                    PlasmaComponents.Label {
                        text: "Auto-refresh: " + (plasmoid.configuration.refreshInterval || 60) + "s"
                        font: Kirigami.Theme.smallFont
                        Layout.fillWidth: true
                    }

                    QQC2.Button {
                        icon.name: "view-refresh"
                        text: "Refresh"
                        onClicked: { dayOffset = 0; refreshCurrentView() }
                    }
                }
            }
        }
    }
}
