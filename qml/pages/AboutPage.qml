/*******************************************************************************
  * AboutPage.qml
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
    id: aboutPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: parent.width
            spacing: 2 * Theme.paddingLarge

            PageHeader {
                //: Header of the About page
                title: qsTr("About")
            }

            About { id: about }

            Text {
                width: parent.width - 2*Theme.paddingLarge
                x: Theme.paddingLarge
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally(link)
                text: about.badVoltage
            }

            Separator {
                width: parent.width
                color: Theme.primaryColor
            }

            Text {
                width: parent.width - 2*Theme.paddingLarge
                x: Theme.paddingLarge
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                linkColor: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                onLinkActivated: Qt.openUrlExternally(link)
                text: about.license
            }

            Button {
                //: Button to page showing the license
                text: qsTr("License")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
            }
        }

        ScrollDecorator {  }
    }
}
