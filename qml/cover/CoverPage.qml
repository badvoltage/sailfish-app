/*******************************************************************************
  * CoverPage.qml
  *
  * Autor: Scharel Clemens <scharelc@gmail.com>
  * Copyright: 2014 Scharel Clemens
  *
  * This file is part of BadVoltage.
  *
  * BadVoltage is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * BadVoltage is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with BadVoltage.  If not, see <http://www.gnu.org/licenses/>.
  *
  *****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

CoverBackground {
    CoverPlaceholder {
        id: placeHolder
        icon.source: "BadVoltageW.png"
    }

    Column {
        y: 175
        width: parent.width
        spacing: Theme.paddingSmall

        Label {
            id: updatingLabel
            //opacity: feedModel.progress !== 1 ? 1 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            //: While updating feed
            text: feedModel.progress !== 1 ? qsTr("Updating...") :
                                             //: Number of unseen episodes
                                             (nUnSeen === 0 ? qsTr("No") : nUnSeen) + " " + qsTr("new Episode") + (nUnSeen > 1 ? qsTr("s") : qsTr(""))
        }

        Label {
            id: audioPositionLabel
            opacity: !player.stopped ? 1 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            text: getTimeFromMs(player.position) + "/" + getTimeFromMs(player.duration)
        }
    }

    CoverActionList {
        enabled: player.stopped
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                //console.log("Cover Refresh")
                feedModel.reloadData()
            }
        }
    }

    CoverActionList {
        enabled: player.paused && !player.stopped
        CoverAction {
            iconSource: "image://theme/icon-cover-play"
            onTriggered: {
                //console.log("Cover Play")
                player.play()
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                //console.log("Cover Refresh")
                feedModel.reloadData()
            }
        }
    }

    CoverActionList {
        enabled: !player.paused && !player.stopped
        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
            onTriggered: {
                //console.log("Cover Pause")
                player.pause()
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                //console.log("Cover Refresh")
                feedModel.reloadData()
            }
        }
    }
}


