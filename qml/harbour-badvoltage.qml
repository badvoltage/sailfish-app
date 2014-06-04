/*******************************************************************************
  *
  * harbour-badvoltage.qml
  * harbour-badvoltage is a Bad Voltage podcast client app for SailfishOS.
  *
  * Copyright (C) 2014  Scharel Clemens <scharelc@gmail.com>
  *
  * This file is part of harbour-badvoltage.
  *
  * harbour-badvoltage is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * harbour-badvoltage is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with harbour-badvoltage.  If not, see <http://www.gnu.org/licenses/>.
  *
  *****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "pages"
import "content"

ApplicationWindow
{
    id: app

    property var feedModel: FeedData { }
    Component.onCompleted: feedModel.reloadData()
    property int nUnSeen: 0

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    initialPage: Component { FeedPage { } }

    function getTimeFromMs(milliseconds) {
        var hours = Math.floor(milliseconds / 1000 / 60 / 60)
        var minutes = Math.floor((milliseconds-hours*1000*60*60) / 1000 / 60)
        var seconds = Math.floor((milliseconds-hours*1000*60*60-minutes*1000*60) / 1000)
        return (hours < 1 ? "" : hours + ":") + (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }
    function getMsFromTime(time) {
        var hours = parseInt(time.split(":", 3)[0])
        var minutes = parseInt(time.split(":", 3)[1])
        var seconds = parseInt(time.split(":", 3)[2])
        return 1000 * (seconds + 60 * (minutes + 60 * hours))
    }

    function getSeason(number) {
        return parseInt(number.replace(/×/g, "x").split("x", 2)[0].trim())
    }
    function getEpisode(number) {
        return parseInt(number.replace(/×/g, "x").split("x", 2)[1].trim())
    }
    function getNumber(season, episode) {
        return season + "x" + episode
    }
    function getPrettyNumber(season, episode) {
        return season + "×" + episode
    }

    Audio {
        id: player
        //autoLoad: false

        property int season: 0
        property int episode: 0
        property bool playing: false
        property bool paused: false
        property bool stopped: true
        signal isEndOfMedia()

        onPlaying: {
            console.log("Playing: " + source)
            stopped = false
            paused = false
            playing = true
        }
        onPaused:{
            console.log("Paused: " + source)
            stopped = false
            playing = true
            paused = true
        }
        onStopped: {
            console.log("Stopped: " + source)
            playing = false
            paused = false
            stopped = true
            if (status === Audio.EndOfMedia)
                isEndOfMedia()
            source = ""
            season = 0
            episode = 0
        }
        function playEpisode(newSeason, newEpisode) {
            stop()
            season = newSeason
            episode = newEpisode
            if (downloader.isDownloaded(season, episode))
                source = settings.value("downloads/" + season + "/" + episode + "/localFile", "NO_LOCAL_FILE")
            else
                source = settings.value("content/" + season + "/" + episode + "/enclosure_url", "NO_REMOTE_FILE")
            play()
        }
    }

    // Is not working as expected
    /*Connections {
        target: downloader
        onFileDownloaded: {
            if (signalSeason === player.season && signalEpisode === player.episode)
                player.playEpisode(signalSeason, signalEpisode)
        }
    }*/
}
