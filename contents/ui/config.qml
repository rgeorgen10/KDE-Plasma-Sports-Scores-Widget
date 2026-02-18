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
                stepSize: 30
                value: 60
                textFromValue: function(value) {
                    return value + " seconds"
                }
                valueFromText: function(text) {
                    return parseInt(text)
                }
            }
        }
        
        QQC2.ComboBox {
            id: defaultLeagueComboBox
            Kirigami.FormData.label: "Default league:"
            model: ["nhl", "nba", "nfl", "mlb"]
            
            onCurrentValueChanged: {
                cfg_defaultLeague = currentValue
            }
            
            Component.onCompleted: {
                currentIndex = find(cfg_defaultLeague)
            }
        }
    }
}
