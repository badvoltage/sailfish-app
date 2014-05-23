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
import QtMultimedia 5.0

Page {
    id: episodePage

    property int season
    property int episode

    onStatusChanged: {
        if (status === PageStatus.Active) {
            //audioPlayer.source = episodeMp3
        } else if (status === PageStatus.Deactivating) {
            //audioPlayer.stop()
        }
    }

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

                property bool isDownloading: false
                property bool isEnqueued: false
                property bool isDownloaded: settings.value("downloads/" + season + "/" + episode + "/downloaded", false) === "true"

                Connections {
                    target: downloader
                    onDownloadStarted: {
                        if (signalSeason == season && signalEpisode == episode) {
                            audioArea.isEnqueued = false
                            audioArea.isDownloading = true
                        }
                    }
                    onDownloadAborted: {
                        if (signalSeason == season && signalEpisode == episode) {
                            audioArea.isDownloading = false
                        }
                    }
                    onDownloadEnqueued: {
                        if (signalSeason == season && signalEpisode == episode) {
                            audioArea.isEnqueued = true
                        }
                    }
                    onDownloadDequeued: {
                        if (signalSeason == season && signalEpisode == episode) {
                            audioArea.isEnqueued = false
                        }
                    }
                    onFileDownloaded: {
                        if (signalSeason == season && signalEpisode == episode) {
                            audioArea.isDownloading = false;
                            audioArea.isDownloaded = true;
                        }
                    }
                    onFileDeleted: {
                        if (signalSeason == season && signalEpisode == episode) {
                            audioArea.isDownloaded = false;
                        }
                    }
                }

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
                        visible: !audioArea.isDownloaded && audioArea.isDownloading && !audioArea.isEnqueued && downloader.downloading
                        //: Abort ongoing download
                        text: qsTr("Abort download")
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
                        onClicked: downloader.deleteFile(season, episode)
                    }

                    MenuLabel {
                        text: settings.value("content/" + season + "/" + episode + "/pubDate")
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    //height: Theme.itemSizeLarge
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    text: settings.value("content/" + season + "/" + episode + "/title")
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: playButton.height

                    IconButton {
                        id: playButton
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon.source: audioPlayer.season === season && audioPlayer.episode === episode && audioPlayer.isPlaying ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
                        onClicked: {
                            if (audioPlayer.season === season && audioPlayer.episode === episode) {
                                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play()
                            }
                            else {
                                audioPlayer.stop()
                                audioPlayer.playEpisode(season, episode)
                            }
                        }
                    }
                    Image {
                        id: downloadedIcon
                        visible: audioArea.isDownloaded
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: playButton.verticalCenter
                        source: "image://theme/icon-s-cloud-download"
                    }
                    BusyIndicator {
                        id: downloadBusyIndicator
                        visible: audioArea.isEnqueued
                        running: visible
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.verticalCenter: playButton.verticalCenter
                        size: BusyIndicatorSize.Small
                    }
                }

                Slider {
                    id: slider
                    property bool inUserControl: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 2*Theme.paddingMedium
                    handleVisible: audioPlayer.seekable
                    enabled: audioPlayer.seekable
                    minimumValue: 0
                    maximumValue: audioPlayer.duration
                    stepSize: 1000
                    value: audioPlayer.season === season && audioPlayer.episode === episode && !audioPlayer.isStopped ? audioPlayer.position : 0
                    valueText: inUserControl ? getTime(sliderValue): audioPlayer.season === season && audioPlayer.episode === episode && !audioPlayer.isStopped ? getTime(value) : getTime(0)
                    label: settings.value("content/" + season + "/" + episode + "/itunes_duration")
                    onDownChanged: {
                        if (down) {
                            inUserControl = true
                        }
                        else {
                            inUserControl = false
                            audioPlayer.seek(sliderValue)
                        }
                    }
                    Connections {
                        target: audioPlayer
                        onPositionChanged: {
                            slider.value = audioPlayer.season === season && audioPlayer.episode === episode ? audioPlayer.position : 0
                        }
                        onEpisodeFinished: {
                            pageStack.pop()
                        }
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
