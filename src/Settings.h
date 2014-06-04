/*******************************************************************************
  * Settings.h
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

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QSettings>
#include <QString>
#include <QList>
#include <QStringList>
#include <QDebug>

class Settings : public QObject {
    Q_OBJECT

public:
    explicit Settings(QString organisation = QString(), QString application = QString(), QObject *parent = 0) :
        QObject(parent) {
        _settings = new QSettings(organisation, application);

        //qDebug() << "Settings are stored in" << _settings->fileName();

        // values to use across the app
        _settings->beginGroup("badVoltage");
        _settings->setValue("url", "http://www.badvoltage.org");
        _settings->setValue("aboutUrl", "http://www.badvoltage.org/about");
        _settings->setValue("rssUrl", "http://www.badvoltage.org/feed/mp3");
        _settings->setValue("communityUrl", "http://community.badvoltage.org/?mobile_view=1");
        _settings->endGroup();

        _settings->beginGroup("app");
        _settings->setValue("url", "http://scharel.github.io/harbour-badvoltage");
        _settings->setValue("gitUrl", "https://github.com/scharel/harbour-badvoltage");
        _settings->setValue("version", "0.2-2");
        _settings->setValue("agent", QString("Bad Voltage for SailfishOS - ").append(_settings->value("version").toString()));
        _settings->endGroup();
    }

    ~Settings() {
        if (_settings)
            delete _settings;
        _settings = NULL;
    }

    Q_INVOKABLE void setValue(const QString &key, const QVariant &value) {
        //qDebug() << "Setting <<" << key << ":" << value.toString();
        _settings->setValue(key, value);
    }
    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const {
        QVariant retval = _settings->value(key, defaultValue);
        //qDebug() << "Setting >>" << key << ":" << retval.toString();
        return retval;
    }
    Q_INVOKABLE void remove(const QString &key) {
        _settings->remove(key);
        //qDebug() << "Setting removed" << key;
    }
    Q_INVOKABLE bool contains(const QString &key) {
        return _settings->contains(key);
    }
    Q_INVOKABLE void sync() {
        _settings->sync();
        //qDebug() << "Settings synced";
    }
    QList<int> seasons(const QString &group) {
        _settings->beginGroup(group);
        QStringList seasonStrings = _settings->childGroups();
        QList<int> seasonInts;
        _settings->endGroup();
        for (int i = 0; i < seasonStrings.size(); ++i) {
            bool ok = false;
            int season = seasonStrings.at(i).toInt(&ok);
            if (ok)
                seasonInts.append(season);
        }
        return seasonInts;
    }
    QList<int> episodes(const QString &group, int season) {
        _settings->beginGroup(QString(group).append("/%1").arg(season));
        QStringList episodeStrings = _settings->childGroups();
        QList<int> episodeInts;
        _settings->endGroup();
        for (int i = 0; i < episodeStrings.size(); ++i) {
            bool ok = false;
            int episode = episodeStrings.at(i).toInt(&ok);
            if (ok)
                episodeInts.append(episode);
        }
        return episodeInts;
    }

private:
    QSettings* _settings;
};

#endif // SETTINGS_H
