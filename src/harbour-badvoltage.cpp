/*******************************************************************************
  *
  * harbour-badvoltage.cpp
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

#include <sailfishapp.h>
#include <QtQuick>
#include "Settings.h"
#include "FileDownloader.h"

int main(int argc, char *argv[])
{
    QGuiApplication* app = SailfishApp::application(argc, argv);

    QQuickView* view = SailfishApp::createView();
    Settings* settings = new Settings("harbour-badvoltage", "BadVoltage");
    FileDownloader* downloader = new FileDownloader(settings);
    QObject::connect(app, SIGNAL(aboutToQuit()), downloader, SLOT(doEnd()));
    QObject::connect(app, SIGNAL(aboutToQuit()), settings, SLOT(sync()));

    view->rootContext()->setContextProperty("settings", settings);
    view->rootContext()->setContextProperty("downloader", downloader);
    view->setSource(SailfishApp::pathTo("qml/harbour-badvoltage.qml"));
    view->show();

    return app->exec();
}
