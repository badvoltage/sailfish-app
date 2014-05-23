/*******************************************************************************
  * RssModel.qml
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

XmlListModel {
    source: settings.value("badVoltage/rssUrl")
    query: "/rss/channel/item"
    namespaceDeclarations: "declare namespace itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'; declare namespace content='http://purl.org/rss/1.0/modules/content/';"

    XmlRole { name: "title"; query: "title/string()"; isKey: true }
    XmlRole { name: "link"; query: "link/string()"; isKey: true }
    XmlRole { name: "pubDate"; query: "pubDate/string()"; isKey: true }
    XmlRole { name: "description"; query: "description/string()"; isKey: true }
    XmlRole { name: "content_encoded"; query: "content:encoded/string()"; isKey: true }
    XmlRole { name: "enclosure_url"; query: "enclosure/@url/string()"; isKey: true }
    XmlRole { name: "enclosure_length"; query: "enclosure/@length/string()"; isKey: true }
    XmlRole { name: "enclosure_type"; query: "enclosure/@type/string()"; isKey: true }
    XmlRole { name: "itunes_duration"; query: "itunes:duration/string()"; isKey: true }

    Component.onCompleted: {
        //loadData()
    }
    onStatusChanged: {
        if (status === XmlListModel.Null)
            console.log("No XML data has been set for this model.")
        if (status === XmlListModel.Ready) {
            console.log("The XML data has been loaded into the model.")
            loadData()
        }
        if (status === XmlListModel.Loading)
            console.log("The model is in the process of reading and loading XML data.")
        if (status === XmlListModel.Null)
            console.log("An error occurred while the model was loading: " + errorString())
    }

    function loadData()
    {
        settings.remove("content")
        console.log("Loading " + count + " items from " + source)
        for (var i = 0; i < count; i++)
        {
            var item = get(i);
            var actNumber = item.title.split(": ", 2)[0].replace(/×/g, "x").trim()
            var actSeason = parseInt(getSeason(actNumber))
            var actEpisode = parseInt(getEpisode(actNumber))
            if (settings.value("content/seasons", 0) < actSeason) settings.setValue("content/seasons", actSeason);
            if (settings.value("content/" + actSeason + "/episodes", 0) < actEpisode) settings.setValue("content/" + actSeason + "/episodes", actEpisode);
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/season", actSeason)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/episode", actEpisode)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/title", item.title.split(": ", 2)[1].trim())
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/link", item.link)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/pubDate", item.pubDate.split(" +", 2)[0].trim())
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/description", item.description)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/content_encoded", item.content_encoded)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/enclosure_url", item.enclosure_url.replace(/%20/g, " "))
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/enclosure_length", item.enclosure_length)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/enclosure_type", item.enclosure_type)
            settings.setValue("content/" + actSeason + "/" + actEpisode + "/itunes_duration", item.itunes_duration)
        }
        settings.setValue("content/count", count)
    }

    function reloadData()
    {
        reload()
        loadData()
    }
}
