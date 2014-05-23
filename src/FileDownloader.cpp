/*******************************************************************************
  * FileDownloader.cpp
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

#include "FileDownloader.h"
#include "Settings.h"

#include <QNetworkRequest>
#include <QStandardPaths>
#include <QDir>

FileDownloader::FileDownloader(Settings* settings, QObject *parent) :
    QObject(parent), _settings(settings), _lastBytesReceived(0), _downloading(false)
{
    QString storagePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir().mkpath(storagePath);
    QDir().setCurrent(storagePath);
    checkLocalFiles();
}

void FileDownloader::doDownload(int season, int episode) {
    QString settingsKey = QString("content/%1/%2/enclosure_url").arg(season).arg(episode);
    QString downloadURL = _settings->value(settingsKey, "NO_DATA").toString();
    settingsKey = QString("downloads/%1/%2/downloaded").arg(season).arg(episode);
    bool downloaded = _settings->value(settingsKey, false).toBool();

    if (downloadURL != "NO_DATA" && !downloaded) {
        QString fileName = downloadURL.split("/", QString::SkipEmptyParts).last();
        _file.setFileName(fileName);
        if (_file.open(QIODevice::WriteOnly)) {
            qDebug() << "Starting download" << season << "x" << episode << "from" << downloadURL;
            QNetworkRequest request(downloadURL);
            request.setRawHeader("User-Agent", _settings->value("app/agent", "NOT_DEFINED").toByteArray());
            _reply = _manager.get(request);
            emit downloadStarted(season, episode);
            setDownloading(true);

            connect(_reply, SIGNAL(readyRead()),
                    this, SLOT(readData()));
            connect(_reply, SIGNAL(downloadProgress(qint64, qint64)),
                    this, SLOT(progress(qint64, qint64)));
            connect(_reply, SIGNAL(finished()),
                    this, SLOT(finishedData()));
            connect(_reply, SIGNAL(error(QNetworkReply::NetworkError)),
                    this, SLOT(error(QNetworkReply::NetworkError)));

            return;
        }
        else {
            qDebug() << "Error creating file" << fileName;

            if (!_downloadQueue.isEmpty())
                _downloadQueue.dequeue();
            if (!_downloadQueue.isEmpty())
                doDownload(_downloadQueue.head().first, _downloadQueue.head().second);

            return;
        }
    }
    else {
        qDebug() << "Could not find download link of" << season << "x" << episode << "or already downloaded";

        if (!_downloadQueue.isEmpty())
            _downloadQueue.dequeue();
        if (!_downloadQueue.isEmpty())
            doDownload(_downloadQueue.head().first, _downloadQueue.head().second);

        return;
    }
}

void FileDownloader::download(int season, int episode) {
    QPair<int, int> number(season, episode);

    if (!_downloadQueue.contains(number)) {
        if (_downloadQueue.isEmpty()) {
            _downloadQueue.enqueue(number);
            doDownload(season, episode);
        }
        else {
            _downloadQueue.enqueue(number);
            emit downloadEnqueued(season, episode);
        }
    }
}

int FileDownloader::abort() {
    int removed = 0;

    if (!_downloadQueue.isEmpty()) {
        QPair<int, int> number = _downloadQueue.head();

        disconnect(_reply, SIGNAL(readyRead()),
                   this, SLOT(readData()));
        disconnect(_reply, SIGNAL(downloadProgress(qint64, qint64)),
                   this, SLOT(progress(qint64, qint64)));
        disconnect(_reply, SIGNAL(finished()),
                   this, SLOT(finishedData()));
        disconnect(_reply, SIGNAL(error(QNetworkReply::NetworkError)),
                   this, SLOT(error(QNetworkReply::NetworkError)));

        _reply->abort();
        _file.remove();
        _reply->deleteLater();

        qDebug() << "Aborting download of" << number.first << "x" << number.second;
        removed = _downloadQueue.removeAll(number);
        deleteFile(number.first, number.second, true);
        emit downloadAborted(number.first, number.second);
    }

    if (_downloadQueue.isEmpty())
        setDownloading(false);
    else
        doDownload(_downloadQueue.head().first, _downloadQueue.head().second);

    return removed;
}

int FileDownloader::dequeue(int season, int episode) {
    QPair<int, int> number(season, episode);
    int removed = 0;

    if (!_downloadQueue.isEmpty()) {
        if (_downloadQueue.head() == number)
            removed = abort();
        else
            removed = _downloadQueue.removeAll(number);

        if (removed > 0)
            emit downloadDequeued(season, episode);
    }

    return removed;
}

bool FileDownloader::deleteFile(int season, int episode, bool force) {
    if (!_downloadQueue.isEmpty())
        if (_downloadQueue.head() == QPair<int, int>(season, episode))
            abort();

    if (_settings->value(QString("downloads/%1/%2/downloaded").arg(season).arg(episode), false).toBool() || force) {
        _settings->setValue(QString("downloads/%1/%2/downloaded").arg(season).arg(episode), false);
        QString filePath = _settings->value(QString("downloads/%1/%2/localFile").arg(season).arg(episode), "NO_DATA").toString();
        if (filePath != "NO_DATA") {
            QFile file(filePath);
            if (file.remove()) {
                qDebug() << "Deleted file" << QFileInfo(file).fileName();
                emit fileDeleted(season, episode);
                return true;
            }
        }
    }
    return false;
}

void FileDownloader::doEnd()
{
    _downloadQueue.clear();
    abort();
}

void FileDownloader::readData() {
    _file.write(_reply->read(_reply->bytesAvailable()));
}

void FileDownloader::progress(qint64 bytesReceived, qint64 bytesTotal) {
    if (!_downloadQueue.isEmpty() && bytesReceived != _lastBytesReceived)
        emit downloadProgress(_downloadQueue.head().first, _downloadQueue.head().second, bytesReceived, bytesTotal);
    //qDebug() << QFileInfo(_file).fileName() << ":" << bytesReceived / 1024 / 1024 << "/" << bytesTotal / 1024 / 1024 << "MB";
}

void FileDownloader::finishedData() {
    if (!_downloadQueue.isEmpty() && _reply->error() == QNetworkReply::NoError) {
        QPair<int, int> number = _downloadQueue.head();
        qDebug() << "Finished downloading" << QFileInfo(_file).fileName() << QFileInfo(_file).size() / 1024 / 1024 << "MB";

        _settings->setValue(QString("downloads/%1/%2/downloaded").arg(number.first).arg(number.second), true);
        _settings->setValue(QString("downloads/%1/%2/localFile").arg(number.first).arg(number.second), QFileInfo(_file).absoluteFilePath());

        disconnect(sender(), SIGNAL(readyRead()),
                   this, SLOT(readData()));
        disconnect(sender(), SIGNAL(downloadProgress(qint64, qint64)),
                   this, SLOT(progress(qint64, qint64)));
        disconnect(sender(), SIGNAL(finished()),
                   this, SLOT(finishedData()));
        disconnect(sender(), SIGNAL(error(QNetworkReply::NetworkError)),
                   this, SLOT(error(QNetworkReply::NetworkError)));

        _file.close();
        _reply->deleteLater();
        emit fileDownloaded(number.first, number.second);

        _downloadQueue.dequeue();
        if (_downloadQueue.isEmpty())
            setDownloading(false);
        else
            doDownload(_downloadQueue.head().first, _downloadQueue.head().second);
    }
}

void FileDownloader::error(QNetworkReply::NetworkError error) {
    abort();
    if (error != QNetworkReply::NoError) {
        qDebug() << "Error while downloading file from" << _reply->url().toString() << ":" << _reply->errorString();
    }
}

void FileDownloader::setDownloading(bool downloading) {
    if (downloading != _downloading) {
        _downloading = downloading;
        emit downloadingChanged();
    }
}

void FileDownloader::checkLocalFiles() {
    QFileInfoList files = QDir().entryInfoList(QStringList("*.mp3"), QDir::Files | QDir::Writable, QDir::Name);
    if (files.size() > 0) {
        QList<int> seasons = _settings->seasons("downloads");
        for (int season = 0; season < seasons.size(); ++season) {
            QList<int> episodes = _settings->episodes("downloads", seasons.at(season));
            for (int episode = 0; episode < episodes.size(); ++episode) {
                QString fileName = _settings->value(QString("downloads/%1/%2/localFile").arg(seasons.at(season)).arg(episodes.at(episode)), "NO_DATA").toString();
                if (QFileInfo(fileName).exists())
                    files.removeAll(QFileInfo(fileName));
            }
        }
        for (int file = 0; file < files.size(); ++file) {
            if (QFile(files.at(file).absoluteFilePath()).remove()) {
                qDebug() << "Removed local file:" << files.at(file).absoluteFilePath();
                files.removeAt(file);
            }
        }
    }
}
