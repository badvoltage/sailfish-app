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
        icon.source: "BV.png"
    }

    Label {
        y: 220
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.highlightColor
        text: audioPlayer.isStopped ? "Bad Voltage" : getPrettyNumber(audioPlayer.season, audioPlayer.episode)
    }

    Label {
        id: audioPositionLabel
        y: 250
        visible: !audioPlayer.isStopped
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
        text: audioPlayer.positionReadable + "/" + audioPlayer.durationReadable
    }

    CoverActionList {
        enabled: !audioPlayer.isPlaying && audioPlayer.isStopped
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                //console.log("Cover Refresh")
                feedModel.reloadData()
            }
        }
    }

    CoverActionList {
        enabled: !audioPlayer.isPlaying && !audioPlayer.isStopped
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                //console.log("Cover Refresh")
                feedModel.reloadData()
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-play"
            onTriggered: {
                //console.log("Cover Play")
                audioPlayer.play()
            }
        }
    }

    CoverActionList {
        enabled: audioPlayer.isPlaying && !audioPlayer.isStopped
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                //console.log("Cover Refresh")
                feedModel.reloadData()
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
            onTriggered: {
                //console.log("Cover Pause")
                audioPlayer.pause()
            }
        }
    }
}


