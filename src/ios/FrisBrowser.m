//
//  InAppBrowser.m
//  inappbrowser
//
//  Created by Sander on 05/03/15.
//  Copyright (c) 2015 Frismedia. All rights reserved.
//

#import <Cordova/CDVInvokedUrlCommand.h>
#import "FrisBrowser.h"
#import "FrisBrowserViewController.h"

@interface FrisBrowser()

@property UINavigationController *navigationController;
@property FrisBrowserViewController *webViewController;

@end

@implementation FrisBrowser

static FrisBrowser *sharedInstance;

@synthesize navigationController = _navigationController;
@synthesize webViewController = _webViewController;

+ (instancetype) sharedInstance {
    return sharedInstance;
}

- (void)pluginInitialize {
    if (nil == sharedInstance) {
        sharedInstance = self;
    }
}

- (void) open:(CDVInvokedUrlCommand *)command {

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"YES"];

    NSString *url = [command argumentAtIndex:0];
    NSDictionary *options = [command argumentAtIndex:1];

    UIColor *barTintColor = nil;
    UIColor *closeButtonColor = nil;
    NSString *closeButtonTitle = nil;
    NSDictionary *barFont = nil;
    UIImage *closeButtonImage = nil;

    if (nil != options) {
        if (nil != options[@"headerBackgroundColor"]) {
            barTintColor = [UIColor colorWithRed:[options[@"headerBackgroundColor"][@"r"] floatValue]/255.0f green:[options[@"headerBackgroundColor"][@"g"] floatValue]/255.0f blue:[options[@"headerBackgroundColor"][@"b"] floatValue]/255.0f alpha:1.0f];
        }
        if (nil != options[@"headerTitleFont"]) {
            barFont = options[@"headerTitleFont"];
        }
        if (nil != options[@"buttonColor"]) {
            closeButtonColor = [UIColor colorWithRed:[options[@"buttonColor"][@"r"] floatValue]/255.0f green:[options[@"buttonColor"][@"g"] floatValue]/255.0f blue:[options[@"buttonColor"][@"b"] floatValue]/255.0f alpha:1.0f];
        }
        if (nil != options[@"buttonTitle"]) {
            closeButtonTitle = options[@"buttonTitle"];
        }
        if (nil != options[@"buttonImage"]) {
            closeButtonImage = [UIImage imageNamed:options[@"buttonImage"]];
        }
    }

    if (nil == self.webViewController) {
        self.navigationController = [[UIStoryboard storyboardWithName:@"FrisBrowser" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FrisInAppBrowser"];

        if (nil != options[@"statusBarStyle"]) {
            if ([@"lightContent" isEqualToString:options[@"statusBarStyle"]]) {
                self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
            }
            else {
                self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
            }
        }

        if (nil != barTintColor && [self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:29.0f / 255.0f green:71.0f / 255.0f blue:77.0f / 255.0f alpha:1.0f]];
        }

        NSMutableDictionary *textAttributes = [NSMutableDictionary dictionary];
        if (nil != barFont && (nil != barFont[@"fontName"] || nil != barFont[@"fontSize"] || nil != barFont[@"fontColor"])) {
            NSString *fontName = barFont[@"fontName"];
            if (nil == fontName) {
                fontName = @"HelveticaNeue";
            }
            NSNumber *fontSize = barFont[@"fontSize"];
            if (nil == fontSize) {
                fontSize = @(20);
            }
            UIColor *fontColor = [UIColor whiteColor];
            if (nil != barFont[@"fontColor"]) {
                fontColor = [UIColor colorWithRed:[barFont[@"fontColor"][@"r"] floatValue] green:[barFont[@"fontColor"][@"g"] floatValue]  blue:[barFont[@"fontColor"][@"b"] floatValue]  alpha:1.0f];
            }
            textAttributes[NSForegroundColorAttributeName] = fontColor;
            textAttributes[NSFontAttributeName] = [UIFont fontWithName:fontName size:[fontSize floatValue]];
        }
        if (textAttributes.count > 0) {
            [self.navigationController.navigationBar setTitleTextAttributes:textAttributes];
        }

        self.webViewController = (FrisBrowserViewController *)self.navigationController.topViewController;
        if (nil != closeButtonColor) {
            [self.webViewController.closeButton setTitleColor:closeButtonColor forState:UIControlStateNormal];
        }
        if (nil != closeButtonTitle) {
            [self.webViewController.closeButton setTitle:closeButtonTitle forState:UIControlStateNormal];
            [self.webViewController.closeButton sizeToFit];
        }
        else if (nil == closeButtonTitle && nil != closeButtonImage) {
            [self.webViewController.closeButton setTitle:@"" forState:UIControlStateNormal];
        }
        if (nil != closeButtonImage) {
            if (nil != closeButtonColor) {
                self.webViewController.closeButton.tintColor = closeButtonColor;
            }
            [self.webViewController.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
            [self.webViewController.closeButton sizeToFit];
        }
    }

    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:self.navigationController animated:YES completion:^{
        self.webViewController.webView.delegate = self;
        [self.webViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [self.webViewController.webView setScalesPageToFit:YES];
    }];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void) close:(CDVInvokedUrlCommand *)command {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.navigationController = nil;
        self.webViewController = nil;
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.webViewController.title = title;

    [UIView animateWithDuration:1.0f animations:^{
        self.webViewController.activityIndicatorView.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.webViewController.activityIndicatorView.hidden = YES;
    }];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error loading %@", error);
}

@end
