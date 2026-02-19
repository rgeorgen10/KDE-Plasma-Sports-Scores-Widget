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
    height: Kirigami.Units.gridUnit * 31
    
    property var leagues: ["nhl", "nba", "nfl", "mlb"]
    property string currentLeague: plasmoid.configuration.defaultLeague || "nhl"
    property string currentView: "scores" // scores, schedule, standings
    property var scoresData: ({})
    property var standingsData: ({})
    property var scheduleData: ({})
    property bool isLoading: false
    property string errorMessage: ""
    
    // Refresh timer - refresh based on configuration
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
        
        if (currentView === "scores") {
            fetchScores()
        } else if (currentView === "schedule") {
            fetchSchedule()
        } else if (currentView === "standings") {
            fetchStandings()
        }
    }
    
    function fetchScores() {
        SportsAPI.fetchScores(currentLeague, function(data) {
            if (data.error) {
                errorMessage = data.error
            } else {
                scoresData[currentLeague] = data
            }
            isLoading = false
        })
    }
    
    function fetchSchedule() {
        SportsAPI.fetchSchedule(currentLeague, function(data) {
            if (data.error) {
                errorMessage = data.error
            } else {
                scheduleData[currentLeague] = data
            }
            isLoading = false
        })
    }
    
    function fetchStandings() {
        SportsAPI.fetchStandings(currentLeague, function(data) {
            if (data.error) {
                errorMessage = data.error
            } else {
                standingsData[currentLeague] = data
            }
            isLoading = false
        })
    }
    
    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 31
        Layout.minimumWidth: Kirigami.Units.gridUnit * 22
        Layout.minimumHeight: Kirigami.Units.gridUnit * 25
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Header with league tabs
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
            
            // View selector
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
                        onClicked: {
                            currentView = "scores"
                            refreshCurrentView()
                        }
                    }
                    
                    QQC2.Button {
                        text: "Schedule"
                        Layout.fillWidth: true
                        flat: currentView !== "schedule"
                        highlighted: currentView === "schedule"
                        onClicked: {
                            currentView = "schedule"
                            refreshCurrentView()
                        }
                    }
                    
                    QQC2.Button {
                        text: "Standings"
                        Layout.fillWidth: true
                        flat: currentView !== "standings"
                        highlighted: currentView === "standings"
                        onClicked: {
                            currentView = "standings"
                            refreshCurrentView()
                        }
                    }
                }
            }
            
            // Content area
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
                        
                        // Loading indicator
                        QQC2.BusyIndicator {
                            visible: isLoading
                            Layout.alignment: Qt.AlignHCenter
                            running: isLoading
                        }
                        
                        // Error message
                        Kirigami.InlineMessage {
                            visible: errorMessage !== ""
                            text: errorMessage
                            type: Kirigami.MessageType.Error
                            Layout.fillWidth: true
                        }
                        
                        // Content based on current view
                        Loader {
                            Layout.fillWidth: true
                            sourceComponent: {
                                if (currentView === "scores") return scoresView
                                if (currentView === "schedule") return scheduleView
                                if (currentView === "standings") return standingsView
                                return null
                            }
                        }
                    }
                }
            }
            
            // Footer with refresh button
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
                        onClicked: refreshCurrentView()
                    }
                }
            }
        }
    }
    
    // Scores view component
    Component {
        id: scoresView
        
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            
            Repeater {
                model: scoresData[currentLeague] ? scoresData[currentLeague].games || [] : []
                
                Kirigami.Card {
                    Layout.fillWidth: true
                    
                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing
                        
                        PlasmaComponents.Label {
                            text: modelData.status || "Unknown"
                            font: Kirigami.Theme.smallFont
                            color: modelData.isLive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
                            // font.bold: modelData.isLive         this line causes issues
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
                                        width: Kirigami.Units.iconSizes.small
                                        height: Kirigami.Units.iconSizes.small
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                        Layout.maximumWidth: Kirigami.Units.iconSizes.small
                                        Layout.maximumHeight: Kirigami.Units.iconSizes.small
                                        fillMode: Image.PreserveAspectFit
                                        visible: modelData.homeLogo ? true : false
                                    }
                                    PlasmaComponents.Label {
                                        text: modelData.homeTeam || "Home"
                                        font.bold: true
                                    }
                                }
                                RowLayout {
                                    spacing: Kirigami.Units.smallSpacing
                                    Image {
                                        source: modelData.awayLogo || ""
                                        width: Kirigami.Units.iconSizes.small
                                        height: Kirigami.Units.iconSizes.small
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                        Layout.maximumWidth: Kirigami.Units.iconSizes.small
                                        Layout.maximumHeight: Kirigami.Units.iconSizes.small
                                        fillMode: Image.PreserveAspectFit
                                        visible: modelData.awayLogo ? true : false
                                    }
                                    PlasmaComponents.Label {
                                        text: modelData.awayTeam || "Away"
                                    }
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
                visible: !scoresData[currentLeague] || !scoresData[currentLeague].games || scoresData[currentLeague].games.length === 0
                text: "No games available"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
    
    // Schedule view component
    Component {
        id: scheduleView
        
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            
            Repeater {
                model: scheduleData[currentLeague] ? scheduleData[currentLeague].games || [] : []
                
                Kirigami.Card {
                    Layout.fillWidth: true
                    
                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing
                        
                        PlasmaComponents.Label {
                            text: modelData.date || "Unknown Date"
                            font: Kirigami.Theme.smallFont
                            color: Kirigami.Theme.textColor
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            PlasmaComponents.Label {
                                text: (modelData.awayTeam || "Away") + " @ " + (modelData.homeTeam || "Home")
                                Layout.fillWidth: true
                            }
                            
                            PlasmaComponents.Label {
                                text: modelData.time || ""
                                font: Kirigami.Theme.smallFont
                            }
                        }
                    }
                }
            }
            
            Kirigami.PlaceholderMessage {
                visible: !scheduleData[currentLeague] || !scheduleData[currentLeague].games || scheduleData[currentLeague].games.length === 0
                text: "No scheduled games"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
    
    // Standings view component
    Component {
        id: standingsView
        
        ColumnLayout {
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
                            width: Kirigami.Units.iconSizes.small
                            height: Kirigami.Units.iconSizes.small
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            Layout.maximumWidth: Kirigami.Units.iconSizes.small
                            Layout.maximumHeight: Kirigami.Units.iconSizes.small
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
                                : (modelData.wins || 0) + "-" + (modelData.losses || 0) + (currentLeague === "nhl" ? "-" + (modelData.otLosses || 0) : "")
                            font: Kirigami.Theme.smallFont
                            // font.bold: currentLeague === "nhl" This Line causes issues
                        }
                    }
                }
            }
            
            Kirigami.PlaceholderMessage {
                visible: !standingsData[currentLeague] || !standingsData[currentLeague].teams || standingsData[currentLeague].teams.length === 0
                text: "No standings available"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
}
