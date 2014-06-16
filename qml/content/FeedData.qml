/*******************************************************************************
  * FeedModel.qml
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
import QtQuick.XmlListModel 2.0

ListModel {
    property int progress: 0
    Component.onCompleted: load()
    function load() {
        nUnSeen = 0
        clear()
        //console.log("Loading content from local storage")
        var count = settings.value("content/count", 0)
        if (count > 0)
        {
            //console.log(count + " episodes in local storage")
            var seasons = settings.value("content/seasons", 0)
            if (seasons > 0)
            {
                //console.log(seasons + " seasons in local storage")
                for (var actSeason = seasons; actSeason > 0; actSeason--)
                {
                    var episodes = settings.value("content/" + actSeason + "/episodes", 0)
                    if (episodes > 0) {
                        //console.log(episodes + " episodes in season " + actSeason)
                        for (var actEpisode = episodes; actEpisode > 0; actEpisode--)
                        {
                            var noDataString = "NO_DATA"
                            if (settings.contains("content/" + actSeason + "/" + actEpisode + "/title")) {
                                //console.log("Adding " + actSeason + "x" + actEpisode + " to feedModel")
                                append( {
                                           "season": parseInt(actSeason),
                                           "episode": parseInt(actEpisode),
                                           "title": settings.value("content/" + actSeason + "/" + actEpisode + "/title", noDataString),
                                           "link": settings.value("content/" + actSeason + "/" + actEpisode + "/link", noDataString),
                                           "pubDate": settings.value("content/" + actSeason + "/" + actEpisode + "/pubDate", noDataString),
                                           "description": settings.value("content/" + actSeason + "/" + actEpisode + "/description", noDataString),
                                           "content_encoded": settings.value("content/" + actSeason + "/" + actEpisode + "/content_encoded", noDataString),
                                           "enclosure_url": settings.value("content/" + actSeason + "/" + actEpisode + "/enclosure_url", noDataString),
                                           "enclosure_length": settings.value("content/" + actSeason + "/" + actEpisode + "/enclosure_length", noDataString),
                                           "enclosure_type": settings.value("content/" + actSeason + "/" + actEpisode + "/enclosure_type", noDataString),
                                           "itunes_duration": settings.value("content/" + actSeason + "/" + actEpisode + "/itunes_duration", noDataString),
                                           "seen": settings.value("downloads/" + actSeason + "/" + actEpisode + "/seen", "false") === "true"
                                       } )
                                if (settings.value("downloads/" + actSeason + "/" + actEpisode + "/seen", "false") !== "true")
                                    nUnSeen = nUnSeen + 1
                            }
                        }
                    }
                }
            }
        }
        else
            reloadData()
        progress = 1
    }

    property var component
    property var rssModel

    function reloadData() {
        progress = 0
        component = Qt.createComponent("RssData.qml")
        if (component.status === Component.Ready)
            finishedModelLoading()
        else
            component.statusChanged.connect(finishedModelLoading)
    }
    function finishedModelLoading()
    {
        if (component.status === Component.Ready)
        {
            rssModel = component.createObject()
            if (rssModel !== null)
            {
                //rssModel.reloadData()
                progress = rssModel.progress
                if (rssModel.status === XmlListModel.Ready)
                    finishedRssLoading()
                else
                    rssModel.statusChanged.connect(finishedRssLoading)
            }
            else {
                console.log("Error while loading rss feed from " + rssModel.source)
                rssModel.destroy()
                progress = 1
            }
        } else if (component.status === Component.Error) {
            console.log("Error while loading rss feed from " + rssModel.source + ": " + component.errorString())
            rssModel.destroy()
            progress = 1
        }
    }
    function finishedRssLoading()
    {
        if (rssModel.status === XmlListModel.Ready)
        {
            rssModel.destroy()
            load()
        }
        else if (rssModel.status === XmlListModel.Error) {
            console.log("Error while loading rss feed from " + rssModel.source + ": " + rssModel.errorString())
            rssModel.destroy()
            progress = 1
        }
    }
}
