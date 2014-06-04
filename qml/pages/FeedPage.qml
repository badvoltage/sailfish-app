/*******************************************************************************
  * FeedPage.qml
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
import "../content"

Page {
    id: feedPage

    Timer {
        id: browserTimer
        interval: 2000
        onRunningChanged: pullDown.busy = running
    }

    SilicaListView {
        id: listView

        model: app.feedModel
        anchors.fill: parent
        VerticalScrollDecorator { }

        header: PageHeader {
            //: Header of thloadDatae initial Page
            title: qsTr("Bad Voltage")
            width: parent.width
        }

        PullDownMenu {
            id: pullDown
            busy: listView.model.progress === 1 ? false : true

            MenuItem {
                //: Menu item that leads to the About page
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
            MenuItem {
                //: Menu item that loads the Community page in the browser after the Community has been visited for the first time
                text: settings.value("app/communityVisited", false) === "true" ? qsTr("Community") :
                                                                                 //: Menu item that loads the Community page in the browser before the Community has been visited for the first time
                                                                                 qsTr("Community (in external browser)")
                onClicked: {
                    browserTimer.restart()
                    Qt.openUrlExternally(settings.value("badVoltage/communityUrl"))
                    //pageStack.push(Qt.resolvedUrl("CommunityPage.qml"))
                    settings.setValue("app/communityVisited", true)
                }
            }
            MenuItem {
                //: Menu item that updates the Feed page
                text: qsTr("Update Feed")
                onClicked: {
                    listView.model.reloadData()
                }
            }
            MenuLabel {
                visible: !player.stopped
                text: getPrettyNumber(player.season, player.episode) + ": " + getTimeFromMs(player.position) + "/" + getTimeFromMs(player.duration)
            }
        }

        delegate: Item {
            id: myListItem

            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.height : contentItem.height

            property bool isDownloading: downloader.isDownloading(season, episode)
            property bool isEnqueued: downloader.isEnqueued(season, episode)
            property bool isDownloaded: downloader.isDownloaded(season, episode)
            property bool isSeen: settings.value("downloads/" + season + "/" + episode + "/seen", false) === "true"

            /*ListView.onAdd: AddAnimation {
                target: myListItem
            }
            ListView.onRemove: RemoveAnimation {
                target: myListItem
            }*/

            Connections {
                target: downloader
                onDownloadStarted: {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("downloadStarted " + signalSeason + "x" + signalEpisode)
                        isEnqueued = false
                        isDownloading = true
                    }
                }
                onDownloadAborted: {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("downloadAborted " + signalSeason + "x" + signalEpisode)
                        isDownloading = false
                        progressRectangle.progress = 0
                    }
                }
                onDownloadEnqueued: {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("downloadEnqueued " + signalSeason + "x" + signalEpisode)
                        isEnqueued = true
                    }
                }
                onDownloadDequeued: {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("downloadDequeued " + signalSeason + "x" + signalEpisode)
                        isEnqueued = false
                    }
                }
                onFileDownloaded: {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("fileDownloaded " + signalSeason + "x" + signalEpisode)
                        isDownloading = false
                        isDownloaded = true
                    }
                }
                onFileDeleted: {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("fileDeleted " + signalSeason + "x" + signalEpisode)
                        isDownloaded = false
                        progressRectangle.progress = 0
                    }
                }
                onDownloadProgress:
                {
                    if (signalSeason == season && signalEpisode == episode) {
                        //console.log("downloadProgress " + signalSeason + "x" + signalEpisode)
                        progressRectangle.progress = bytesReceived / bytesTotal
                    }
                }
            }
            Connections {
                target: player
                onIsEndOfMedia: {
                    if (player.season === season && player.episode === episode)
                        listView.setSeen(index, true)
                }
            }

            BackgroundItem {
                id: contentItem
                height: Theme.itemSizeLarge
                highlighted: !myListItem.menuOpen && down

                Rectangle {
                    id: progressRectangle
                    property double progress: 0
                    visible: isDownloading
                    height: parent.height
                    width: progress * parent.width
                    color: Theme.highlightColor
                    opacity: 0.2
                }
                Label {
                    id: numberLabel
                    x: Theme.paddingLarge
                    anchors.bottom: parent.verticalCenter
                    color: Theme.highlightColor
                    text: getPrettyNumber(season, episode) + ": "
                }
                Label {
                    id: titleLabel
                    anchors.left: numberLabel.right
                    anchors.bottom: parent.verticalCenter
                    color: contentItem.highlighted || (season === player.season && episode === player.episode && player.playing) ? Theme.highlightColor : Theme.primaryColor
                    width: parent.width - downloadedIcon.width - playingIcon.width
                    text: title
                }
                Label {
                    id: dateLabel
                    x: Theme.paddingLarge
                    anchors.top: parent.verticalCenter
                    color: contentItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: pubDate
                }
                GlassItem {
                    id: unseenItem
                    visible: !isSeen
                    color: Theme.highlightColor
                    anchors.horizontalCenter: parent.left
                    anchors.verticalCenter: numberLabel.verticalCenter
                }
                Image {
                    id: playingIcon
                    visible: player.season === season && player.episode === episode && player.playing && !player.paused
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-speaker"
                }
                Image {
                    id: downloadedIcon
                    visible: (player.season === season && player.episode === episode && player.playing && !player.paused) ? false : isDownloaded
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-download"
                }
                BusyIndicator {
                    id: downloadBusyIndicator
                    visible: (player.season === season && player.episode === episode && player.playing && !player.paused) ? false : isEnqueued
                    running: visible
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    size: BusyIndicatorSize.Small
                }

                onClicked: pageStack.push(Qt.resolvedUrl("EpisodePage.qml"), {season: season, episode: episode } )

                onPressAndHold: {
                    componentData.index = index
                    componentData.season = season
                    componentData.episode = episode
                    componentData.size = enclosure_length
                    componentData.isDownloading = isDownloading
                    componentData.isEnqueued = isEnqueued
                    componentData.isDownloaded = isDownloaded
                    componentData.isSeen = isSeen
                    componentData.item = myListItem
                    if (!contextMenu) {
                        contextMenu = contextMenuComponent.createObject(listView)
                    }
                    contextMenu.show(myListItem)
                }
            }
            function remove() {
                //: Deleting hint on remorse timer, [SEASON]x[EPISODE] is added
                remorse.execute(myListItem, qsTr("Deleting") + " " + getPrettyNumber(season, episode), function() { downloader.deleteFile(season, episode) } )
            }
            RemorseItem { id: remorse }
        }

        QtObject {
            id: componentData
            property int index: 0
            property int season: 0
            property int episode: 0
            property int size: 0
            property bool isDownloading: false
            property bool isEnqueued: false
            property bool isDownloaded: false
            property bool isSeen: false
            property var item
        }

        Component {
            id: contextMenuComponent
            ContextMenu {
                MenuItem {
                    visible: !componentData.isDownloaded && !componentData.isDownloading && !componentData.isEnqueued && !downloader.downloading
                    //: Download episode for offline listening
                    text: qsTr("Download") + " (" +
                          //: Size of the episode in MB (Mega Bytes)
                          (componentData.size / 1024 / 1024).toPrecision(3) + " " + qsTr("MB") + ")"
                    onClicked: downloader.download(componentData.season, componentData.episode)
                }
                MenuItem {
                    visible: !componentData.isDownloaded && componentData.isDownloading && downloader.downloading
                    //: Abort ongoing download
                    text: qsTr("Abort download")
                    onClicked: downloader.abort()
                }
                MenuItem {
                    visible: !componentData.isDownloaded && !componentData.isDownloading && !componentData.isEnqueued && downloader.downloading
                    //: Add episode to download queue for offline listening (if another download is currently going on)
                    text: qsTr("Add to download queue") + " (" +
                          //: Size of the episode in MB (Mega Bytes)
                          (componentData.size / 1024 / 1024).toPrecision(3) + " " + qsTr("MB") + ")"
                    onClicked: downloader.download(componentData.season, componentData.episode)
                }
                MenuItem {
                    visible: !componentData.isDownloaded && !componentData.isDownloading && componentData.isEnqueued && downloader.downloading
                    //: Remove episode from download queue for offline listening (if another download is currently going on)
                    text: qsTr("Remove from download queue")
                    onClicked: downloader.dequeue(componentData.season, componentData.episode)
                }
                MenuItem {
                    visible: componentData.isDownloaded && !componentData.isDownloading && !componentData.isEnqueued
                    //: Delete downloaded episode from device
                    text: qsTr("Delete from device")
                    //onClicked: downloader.deleteFile(componentData.season, componentData.episode)
                    onClicked: componentData.item.remove()
                }
                MenuItem {
                    //: Mark feed ass seen
                    text: !componentData.isSeen ? qsTr("Mark as seen") :
                                                  //: Unmark feed as seen
                                                  qsTr("Mark as unseen")
                    onClicked: listView.setSeen(componentData.index, !componentData.isSeen)
                }
            }
        }

        function setSeen(index, isSeen) {
            listView.currentIndex = index
            if (listView.currentItem.isSeen !== isSeen) {
                nUnSeen = isSeen ? nUnSeen-1 : nUnSeen+1
                listView.currentItem.isSeen = isSeen
                settings.setValue("downloads/" + listView.model.get(index).season + "/" + listView.model.get(index).episode + "/seen", isSeen)
                settings.sync()
            }
        }
    }
}
