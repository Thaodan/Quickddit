/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2017-2020  Sander van Grieken

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: aboutSubredditPage
    title: qsTr("About %1").arg(aboutSubredditManager.url || "Subreddit")
    busy: aboutSubredditManager.busy
    clip: true

    property alias subreddit: aboutSubredditManager.subreddit

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: flickableColumn.height + 2 * constant.paddingMedium

        PullDownMenu {
            MenuItem {
                text: qsTr("Moderators")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ModeratorListPage.qml"), {manager: aboutSubredditManager});
                }
            }

            MenuItem {
                text: qsTr("Message Moderators")
                visible: quickdditManager.isSignedIn
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SendMessagePage.qml"), {recipient: aboutSubredditManager.url});
                }
            }

            MenuItem {
                text: aboutSubredditManager.isSubscribed ? qsTr("Unsubscribe") : qsTr("Subscribe")
                enabled: quickdditManager.isSignedIn && !aboutSubredditManager.busy && aboutSubredditManager.isValid
                onClicked: aboutSubredditManager.subscribeOrUnsubscribe();
            }
        }

        Image {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: flickableColumn.top
            }
            width: parent.width
            height: shortDescriptionText.y - y
            source: aboutSubredditManager.bannerBackgroundUrl
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            opacity: 0.5
            transformOrigin: Item.Top
        }

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: childrenRect.height
            spacing: constant.paddingMedium
            visible: aboutSubredditManager.isValid

            QuickdditPageHeader { title: aboutSubredditPage.title }

            Item {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                height: Math.max(headerImage.height, titleText.height)

                Image {
                    id: headerImage
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    source: aboutSubredditManager.iconUrl
                    asynchronous: true
                    width: (status == Image.Error || status == Image.Null) ? 0 : Theme.itemSizeLarge
                    height: width
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: headerImage.width
                            height: headerImage.height
                            radius: headerImage.width/4
                        }
                    }
                }

                Text {
                    id: titleText
                    anchors {
                        left: headerImage.right
                        leftMargin: headerImage.status == Image.Ready ? constant.paddingLarge : 0
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: constant.fontSizeXLarge
                    color: constant.colorLight
                    font.bold: true
                    text: aboutSubredditManager.subreddit
                }
            }

            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                visible: aboutSubredditManager.isNSFW
                font.pixelSize: constant.fontSizeMedium
                color: "red"
                font.italic: true
                text: qsTr("This subreddit is Not Safe For Work")
            }

            Text {
                id: shortDescriptionText
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                wrapMode: Text.Wrap
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorMid
                text: aboutSubredditManager.shortDescription
            }

            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                text: qsTr("%n subscribers", "", aboutSubredditManager.subscribers) + " · " +
                      qsTr("%n active users", "", aboutSubredditManager.activeUsers)
            }

            Flow {
                spacing: constant.paddingMedium
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: constant.paddingMedium

                Bubble {
                    visible: quickdditManager.isSignedIn
                    color: aboutSubredditManager.isSubscribed ? "green" : "red"
                    text: aboutSubredditManager.isSubscribed ? qsTr("Subscribed") : qsTr("Not Subscribed")
                }

                Bubble {
                    visible: aboutSubredditManager.subredditType !== AboutSubredditManager.Public
                    text: aboutSubredditManager.subredditType === AboutSubredditManager.Private ? qsTr("Private") :
                          aboutSubredditManager.subredditType === AboutSubredditManager.Restricted ? qsTr("Restricted") :
                          aboutSubredditManager.subredditType === AboutSubredditManager.GoldRestricted ? qsTr("GoldRestricted") : qsTr("Archived")
                }

                Bubble {
                    visible: aboutSubredditManager.submissionType !== AboutSubredditManager.Any
                    text: aboutSubredditManager.submissionType === AboutSubredditManager.Link ? qsTr("Links only") : qsTr("Self posts only")
                }

                Bubble {
                    visible: aboutSubredditManager.isNSFW
                    text: qsTr("NSFW")
                    color: "red"
                }

                Bubble {
                    visible: aboutSubredditManager.isContributor
                    text: qsTr("Contributor")
                }

                Bubble {
                    visible: aboutSubredditManager.isBanned
                    text: qsTr("Banned")
                    color: "red"
                }

                Bubble {
                    visible: aboutSubredditManager.isModerator
                    text: qsTr("Mod")
                    color: "blue"
                }

                Bubble {
                    visible: aboutSubredditManager.isMuted
                    text: qsTr("Muted")
                    color: "grey"
                }
            }

            Separator {
                anchors { left: parent.left; right: parent.right }
                color: constant.colorMid
                visible: aboutSubredditManager.longDescription != ""
            }

            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                text: constant.richtextStyle + aboutSubredditManager.longDescription
                onLinkActivated: globalUtils.openLink(link);
            }
        }

        VerticalScrollDecorator {}
    }

    AboutSubredditManager {
        id: aboutSubredditManager
        manager: quickdditManager
        onSubscribeSuccess: {
            if (isSubscribed) {
                infoBanner.alert(qsTr("You have subscribed to %1").arg(url))
            } else {
                infoBanner.alert(qsTr("You have unsubscribed from %1").arg(url))
            }
        }
        onError: infoBanner.warning(errorString)
    }
}
