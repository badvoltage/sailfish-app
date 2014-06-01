/*******************************************************************************
  * About.qml
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

Item {
    property string badVoltage: "<a href=\"" + settings.value("badVoltage/url") + "\"><strong>About Bad Voltage</strong></a><br>
<br>
Bad Voltage is a podcast with Jono Bacon, Jeremy Garcia, Stuart Langridge,
and Bryan Lunduke, in which they talk about anything that interests them.
Technology, Open Source, Politics, Music…anything and everything is up for grabs,
complete with reviews and interviews.<br>
<br>
The shows are released under the<br>
<a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">Creative Commons Attribution Share-Alike</a><br>
license and as are free to listen to and share with others.<br>
<a href=\"http://ccmixter.org/files/FreeInstrumentalMusic/43270\">This music</a>
os used for the theme."

    property string license: "<strong>About this app</strong> (" + settings.value("app/version") + ")<br>
<br>
Copyright © 2014  Scharel Clemens<br>
The source code of this app is available on <a href=\"" + settings.value("app/gitUrl") + "\">GitHub</a>.<br>
<br>
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.<br>
<br>
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.<br>
<br>
You should have received a copy of the GNU General Public License
along with this program.  If not, see<br>
<a href=\"https://www.gnu.org/licenses/\">www.gnu.org/licenses</a>."
}
