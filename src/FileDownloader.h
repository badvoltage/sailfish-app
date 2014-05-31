/*******************************************************************************
  * FileDownloader.h
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

#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>
#include <QQueue>
#include <QPair>
#include <QDebug>

#include "Settings.h"

class FileDownloader : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool downloading READ downloading NOTIFY downloadingChanged)

public:
    explicit FileDownloader(Settings* settings, QObject *parent = 0);
    virtual ~FileDownloader() { }

    // functions available from QML
    Q_INVOKABLE void download(int season, int episode);
    Q_INVOKABLE int abort();
    Q_INVOKABLE int dequeue(int season, int episode);
    Q_INVOKABLE bool deleteFile(int season, int episode, bool force = false);
    Q_INVOKABLE bool isDownloading(int season, int episode);
    Q_INVOKABLE bool isEnqueued(int season, int episode);
    Q_INVOKABLE bool isDownloaded(int season, int episode);

    // read function for property downloading
    bool downloading() { return _downloading; }

public slots:
    // cleaning up on app closing
    void doEnd();

private slots:
    // when data recieved
    void readData();
    // when progress made
    void progress(qint64 bytesReceived, qint64 bytesTotal);
    // when all data recieved
    void finishedData();
    // when error occurred
    void error(QNetworkReply::NetworkError error);

signals:
    // signals recievable in QML
    void downloadStarted(int signalSeason, int signalEpisode);
    void downloadAborted(int signalSeason, int signalEpisode);
    void downloadEnqueued(int signalSeason, int signalEpisode);
    void downloadDequeued(int signalSeason, int signalEpisode);
    void fileDownloaded(int signalSeason, int signalEpisode);
    void fileDeleted(int signalSeason, int signalEpisode);
    void downloadProgress(int signalSeason, int signalEpisode, int bytesReceived, int bytesTotal);

    // signal for property downloading
    void downloadingChanged();

private:
    QNetworkAccessManager _manager;
    QNetworkReply* _reply;
    QFile _file;
    Settings* _settings;

    QQueue<QPair<int,int> > _downloadQueue;

    void doDownload(int season, int episode);
    qint64 _lastBytesReceived;

    // variable for property downloading
    bool _downloading;
    // write function for property downloading
    void setDownloading(bool downloading);

    void checkLocalFiles();
};

#endif // FILEDOWNLOADER_H
