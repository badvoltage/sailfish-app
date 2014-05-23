/*******************************************************************************
  * CommunityPage.qml
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

// This file is currently not used
Page {
    id: communityPage

    onStatusChanged: if (status === PageStatus.Active) {
        console.log("Community visible")
        app.mode = "community"
    }

    SilicaWebView {
        anchors.fill: parent

        header: PageHeader {
            //: Header of the Community page
            title: qsTr("Community")
        }

        url: settings.value("badVoltage/communityUrl")

        /*onLoadStarted: busyIndicator.visible = true
        onLoadFinished: busyIndicator.visible = false

        BusyIndicator {
            id: busyIndicator
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
        }

        Label {
            id: failLabel
            anchors.centerIn: parent
            visible: false
            //: Error while loading the WebView
            text: qsTr("Error while loading!")
        }*/
    }
}
