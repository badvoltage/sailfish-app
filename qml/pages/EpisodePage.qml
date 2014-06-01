/*******************************************************************************
  * EpisodePage.qml
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

Page {
    id: episodePage

    property int season
    property int episode

    SilicaFlickable {
        width: parent.width
        height: audioArea.height

        Column {
            anchors.fill: parent
            spacing: 0

            Column {
                id: audioArea
                width: parent.width
                spacing: Theme.paddingMedium

                PageHeader {
                    title: getPrettyNumber(season, episode)
                }

                property bool isDownloading: downloader.isDownloading(season, episode)
                property bool isEnqueued: downloader.isEnqueued(season, episode)
                property bool isDownloaded: downloader.isDownloaded(season, episode)
                property int progressPerCent: 0

                Connections {
                    target: downloader
                    onDownloadStarted: {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("downloadStarted " + signalSeason + "x" + signalEpisode)
                            audioArea.isEnqueued = false
                            audioArea.isDownloading = true
                        }
                    }
                    onDownloadAborted: {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("downloadAborted " + signalSeason + "x" + signalEpisode)
                            audioArea.isDownloading = false
                        }
                    }
                    onDownloadEnqueued: {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("downloadEnqueued " + signalSeason + "x" + signalEpisode)
                            audioArea.isEnqueued = true
                        }
                    }
                    onDownloadDequeued: {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("downloadDequeued " + signalSeason + "x" + signalEpisode)
                            audioArea.isEnqueued = false
                        }
                    }
                    onFileDownloaded: {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("fileDownloaded " + signalSeason + "x" + signalEpisode)
                            audioArea.isDownloading = false
                            audioArea.isDownloaded = true
                        }
                    }
                    onFileDeleted: {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("fileDeleted " + signalSeason + "x" + signalEpisode)
                            audioArea.isDownloaded = false
                        }
                    }
                    onDownloadProgress:
                    {
                        if (signalSeason == season && signalEpisode == episode) {
                            //console.log("downloadProgress " + signalSeason + "x" + signalEpisode)
                            audioArea.progressPerCent = (bytesReceived / bytesTotal) * 100
                        }
                    }
                }

                function remove() {
                    //: Deleting hint on remorse timer, [SEASON]x[EPISODE] is added
                    remorse.execute(qsTr("Deleting") + " " + getPrettyNumber(season, episode), function() { downloader.deleteFile(season, episode) } )
                }
                RemorsePopup { id: remorse }

                PullDownMenu {
                    MenuItem {
                        //: Open the badvoltage.org webpage, showing this episode in external browser
                        text: qsTr("View in Browser")
                        onClicked: Qt.openUrlExternally(settings.value("content/" + season + "/" + episode + "/link"))
                    }

                    MenuItem {
                        visible: !audioArea.isDownloaded && !audioArea.isDownloading && !audioArea.isEnqueued && !downloader.downloading
                        //: Download episode for offline listening
                        text: qsTr("Download") + " (" +
                              //: Size of the episode in MB (Mega Bytes)
                              (settings.value("content/" + season + "/" + episode + "/enclosure_length") / 1024 / 1024).toPrecision(3) + " " + qsTr("MB") + ")"
                        onClicked: downloader.download(season, episode)
                    }
                    MenuItem {
                        visible: !audioArea.isDownloaded && audioArea.isDownloading && downloader.downloading
                        //: Abort ongoing download
                        text: qsTr("Abort download") + " (" + audioArea.progressPerCent + ("%)")
                        onClicked: downloader.abort()
                    }
                    MenuItem {
                        visible: !audioArea.isDownloaded && !audioArea.isDownloading && !audioArea.isEnqueued && downloader.downloading
                        //: Add episode to download queue for offline listening (if another download is currently going on)
                        text: qsTr("Add to download queue") + " (" +
                              //: Size of the episode in MB (Mega Bytes)
                              (settings.value("content/" + season + "/" + episode + "/enclosure_length") / 1024 / 1024).toPrecision(3) + " " + qsTr("MB") + ")"
                        onClicked: downloader.download(season, episode)
                    }
                    MenuItem {
                        visible: !audioArea.isDownloaded && !audioArea.isDownloading && audioArea.isEnqueued && downloader.downloading
                        //: Remove episode from download queue for offline listening (if another download is currently going on)
                        text: qsTr("Remove from download queue")
                        onClicked: downloader.dequeue(season, episode)
                    }
                    MenuItem {
                        visible: audioArea.isDownloaded && !audioArea.isDownloading && !audioArea.isEnqueued
                        //: Delete downloaded episode from device
                        text: qsTr("Delete from device")
                        onClicked: audioArea.remove()
                    }
                    MenuLabel {
                        text: settings.value("content/" + season + "/" + episode + "/pubDate")
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: title.height

                    Label {
                        id: title
                        anchors.horizontalCenter: parent.horizontalCenter
                        //height: Theme.itemSizeLarge
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                        text: settings.value("content/" + season + "/" + episode + "/title")
                    }
                    Image {
                        id: downloadedIcon
                        visible: audioArea.isDownloaded
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: title.verticalCenter
                        source: "image://theme/icon-m-download"
                    }
                    BusyIndicator {
                        id: downloadBusyIndicator
                        visible: audioArea.isEnqueued || audioArea.isDownloading
                        running: visible
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: title.verticalCenter
                        size: BusyIndicatorSize.Small
                    }
                }

                IconButton {
                    id: playButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon.source: {
                        if (player.season === season && player.episode === episode && !player.paused)
                            return "image://theme/icon-l-pause"
                        else
                            return "image://theme/icon-l-play"
                    }
                    onClicked: {
                        if (player.season === season && player.episode === episode && !player.paused)
                            player.pause()
                        else if (player.episode === episode && player.season === season)
                            player.play()
                        else {
                            player.playEpisode(season, episode)
                        }
                    }
                    onPressAndHold: player.stop()
                }

                Slider {
                    id: slider
                    property bool inUserControl: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width //- 2*Theme.paddingMedium
                    enabled: player.season === season && player.episode === episode && player.seekable && !player.stopped
                    handleVisible: enabled
                    minimumValue: 0
                    maximumValue: player.duration
                    value: player.season === season && player.episode === episode ? player.position : 0
                    stepSize: 1000
                    valueText: getTimeFromMs(sliderValue)
                    label: settings.value("content/" + season + "/" + episode + "/itunes_duration", "")
                    onDownChanged: {
                        if (down) {
                            inUserControl = true
                        }
                        else {
                            inUserControl = false
                            player.seek(sliderValue)
                        }
                    }
                    Connections {
                        target: player
                        onPositionChanged: {
                            if (player.season === season && player.episode === episode) slider.value = player.position
                        }
                        onIsEndOfMedia: if (player.season === season && player.episode === episode) pageStack.pop()
                    }
                }
            }

            Separator {
                width: parent.width
                color: Theme.primaryColor
            }

            Flickable {
                width: parent.width
                height: Screen.height - audioArea.height
                y: audioArea.height
                contentWidth: parent.width
                contentHeight: contentArea.height
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Text {
                    id: contentArea
                    width: parent.width - 2*Theme.paddingLarge
                    x: Theme.paddingLarge
                    color: Theme.primaryColor
                    linkColor: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText
                    onLinkActivated: Qt.openUrlExternally(link)
                    text: settings.value("content/" + season + "/" + episode + "/content_encoded")
                }

                ScrollDecorator {  }
            }
        }
    }
}
