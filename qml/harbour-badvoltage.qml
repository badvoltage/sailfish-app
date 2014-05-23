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

    Connections {
        property int tmpPosition
        target: downloader
        onFileDownloaded: {
            if (signalSeason == audioPlayer.season && signalEpisode == audioPlayer.episode) {
                tmpPosition = audioPlayer.position
                console.log("Switching audio playback to local file (position: " + tmpPosition + ")")
                settings.sync()
                audioPlayer.playEpisode(signalSeason, signalEpisode, tmpPosition)
            }
        }
        onFileDeleted: {
            if (signalSeason == audioPlayer.season && signalEpisode == audioPlayer.episode) {
                tmpPosition = audioPlayer.position
                console.log("Switching audio playback to internet (position: " + tmpPosition + ")")
                settings.sync()
                audioPlayer.playEpisode(signalSeason, signalEpisode, tmpPosition)
            }
        }
    }

    Component.onCompleted: {
        if (audioPlayer.season !== 0 && audioPlayer.episode !== 0) {
            if (settings.value("downloads/" + audioPlayer.season + "/" + audioPlayer.episode + "/downloaded", false) === "true")
                audioPlayer.source = settings.value("downloads/" + audioPlayer.season + "/" + audioPlayer.episode + "/localFile", "NO_LOCAL_FILE")
            else
                audioPlayer.source = settings.value("content/" + audioPlayer.season + "/" + audioPlayer.episode + "/enclosure_url", "NO_REMOTE_FILE")

            audioPlayer.pause()
            //audioPlayer.isPlaying = false
            //audioPlayer.isStopped = false
        }
    }

    Audio {
        id: audioPlayer
        autoLoad: false

        property int season: settings.value("audioPlayer/lastSeasonPlayed", 0)
        property int episode: settings.value("audioPlayer/lastEpisodePlayed", 0)
        property bool isPlaying: false
        property bool isStopped: true
        property string positionReadable: getTime(0)
        property string durationReadable: getTime(0)
        property int lastPosition: 0
        property bool oncePlayed: false
        signal episodeFinished(int finishedSeason, int finishedEpisode)

        onPositionChanged: {
            positionReadable = getTime(position)
            if (position - lastPosition > 100) {
                lastPosition = position
                settings.setValue("audioPlayer/lastPosition", position - 1000)
            }
        }
        onDurationChanged: {
            durationReadable = getTime(duration)
        }

        onPlaying: {
            console.log("Playing: " + source)
            if (!oncePlayed && season === parseInt(settings.value("audioPlayer/lastSeasonPlayed", 0)) && episode === parseInt(settings.value("audioPlayer/lastEpisodePlayed", 0))) {
                console.log("Continueing last played episode at: " + getTime(settings.value("audioPlayer/lastPosition", 0)))
                seek(settings.value("audioPlayer/lastPosition", 0))
            }
            oncePlayed = true
            isPlaying = true
            isStopped = false
            settings.setValue("audioPlayer/lastSeasonPlayed", season)
            settings.setValue("audioPlayer/lastEpisodePlayed", episode)
        }
        onPaused:{
            console.log("Paused: " + source)
            isPlaying = false
            isStopped = false
        }
        onStopped: {
            console.log("Stopped: " + source)
            isPlaying = false
            isStopped = true
            if (duration - position < 200)
                episodeFinished(season, episode)
            season = 0
            episode = 0
            settings.remove("audioPlayer/lastSeasonPlayed")
            settings.remove("audioPlayer/lastEpisodePlayed")
            settings.remove("audioPlayer/lastPosition")
        }
        function playEpisode(newSeason, newEpisode) {
            newSeason = typeof newSeason !== 'undefined' ? newSeason : season;
            newEpisode = typeof newEpisode !== 'undefined' ? newEpisode : episode;
            season = newSeason;
            episode = newEpisode;
            //stop();
            if (settings.value("downloads/" + season + "/" + episode + "/downloaded", false) === "true")
                source = settings.value("downloads/" + season + "/" + episode + "/localFile", "NO_LOCAL_FILE")
            else
                source = settings.value("content/" + season + "/" + episode + "/enclosure_url", "NO_REMOTE_FILE")
            //console.log("New source: " + source)
            play();
        }
    }

    function getTime(milliseconds) {
        var hours = Math.floor(milliseconds / 1000 / 60 / 60)
        var minutes = Math.floor((milliseconds-hours*1000*60*60) / 1000 / 60)
        var seconds = Math.floor((milliseconds-hours*1000*60*60-minutes*1000*60) / 1000)

        return (hours < 1 ? "" : hours + ":") + (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds)
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

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    initialPage: Component { FeedPage { } }
}
