//
//  InAppBrowser.h
//  inappbrowser
//
//  Created by Sander on 05/03/15.
//  Copyright (c) 2015 Frismedia. All rights reserved.
//

#import <UIKit/UIkit.h>
#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface FrisBrowser : CDVPlugin <UIWebViewDelegate>

@property NSNumber *preferredStatusBarStyle;

+ (instancetype)sharedInstance;

- (void)open:(CDVInvokedUrlCommand *)command;

- (void)close:(CDVInvokedUrlCommand *)command;

@end
