<!---
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
-->

# nl.frismedia.frisbrowser

This plugin is an alternative to the [Cordova In App Browser Plugin](https://github.com/apache/cordova-plugin-inappbrowser).
The need for this plugin was created when I wanted to style the in app browser to fit my needs, but wasn't able to do that with the In App Browser Plugin.

The plugin is only for iOS at the moment, but Android support will follow soon.

## Installation

    cordova plugin add nl.frismedia.frisbrowser

## Supported Platforms

- iOS

## Sample usage

    FrisBrowser.open(
        'http://www.google.com',
        {
            statusBarStyle: "lightContent", 
            buttonImage: "icon-close.png",
            headerTitleFont: {
                fontName: 'Futura-Medium',
                fontSize: 20,
                fontColor: {r:255,g:255,b:255}
            },
            headerBackgroundColor: {r:29,g:71,b:77},
            buttonColor: {r:255,g:255,b:255}
        }
    );
 
    FrisBrowser.close();