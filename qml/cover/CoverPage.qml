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

    Timer {
        id: updatingTimer
        interval: 1500
    }

    Connections {
        target: updatingLabel
        onVisibleChanged: if (updatingLabel.visible === false) updatingTimer.restart()
    }

    Column {
        y: 175
        x: Theme.paddingSmall
        width: parent.width - 2 * Theme.paddingSmall
        spacing: Theme.paddingSmall

        Label {
            id: updatingLabel
            visible: feedModel.progress !== 1
            width: parent.width
            truncationMode: TruncationMode.Fade
            horizontalAlignment: contentWidth < width ? Text.AlignHCenter : Text.AlignLeft
            //: While updating feed
            text: qsTr("Updating...")
        }

        Label {
            id: playingLabel
            visible: !updatingLabel.visible && !player.stopped && !updatingTimer.running
            width: parent.width
            truncationMode: TruncationMode.Fade
            horizontalAlignment: contentWidth < width ? Text.AlignHCenter : Text.AlignLeft
            text: getPrettyNumber(player.season, player.episode) + ": " + settings.value("content/" + player.season + "/" + player.episode + "/title")
        }

        Label {
            id: newEpisodesLabel
            visible: !updatingLabel.visible && !playingLabel.visible
            width: parent.width
            truncationMode: TruncationMode.Fade
            horizontalAlignment: wrapMode === Text.Wrap ? Text.AlignHCenter : Text.AlignLeft
            maximumLineCount: 2
            wrapMode: player.stopped ? Text.Wrap : Text.NoWrap
            //: Number of unseen episodes
            text: (nUnSeen === 0 ? qsTr("No") : nUnSeen) + " " + qsTr("Unseen Episode") + (nUnSeen > 1 ? qsTr("s") : qsTr(""))
        }

        Label {
            id: audioPositionLabel
            visible: !player.stopped
            width: parent.width
            truncationMode: TruncationMode.Fade
            horizontalAlignment: contentWidth < width ? Text.AlignHCenter : Text.AlignLeft
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


