# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-badvoltage

CONFIG += sailfishapp

SOURCES += src/harbour-badvoltage.cpp \
    src/FileDownloader.cpp

OTHER_FILES += qml/harbour-badvoltage.qml \
    rpm/harbour-badvoltage.changes.in \
    rpm/harbour-badvoltage.spec \
    rpm/harbour-badvoltage.yaml \
    translations/*.ts \
    harbour-badvoltage.desktop \
    qml/content/RssData.qml \
    qml/content/FeedData.qml \
    qml/cover/BV.png \
    qml/cover/CoverPage.qml \
    qml/pages/FeedPage.qml \
    qml/pages/EpisodePage.qml \
    qml/pages/CommunityPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/LicensePage.qml \
    qml/content/About.qml \
    README \
    COPYING

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-badvoltage-de.ts

HEADERS += \
    src/Settings.h \
    src/FileDownloader.h

