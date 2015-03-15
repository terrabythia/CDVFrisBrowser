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

@property UIImage *buttonImage;

@end

@implementation FrisBrowser

static FrisBrowser *sharedInstance;

@synthesize navigationController = _navigationController;
@synthesize webViewController = _webViewController;

@synthesize buttonImage = _buttonImage;

+ (instancetype) sharedInstance {
    return sharedInstance;
}

- (void)pluginInitialize {
    if (nil == sharedInstance) {
        sharedInstance = self;
    }
}

- (UIImage *) imageByURLString:(NSString *)URLString {
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]];
    return [UIImage imageWithData:imageData];
}

- (void) preloadCloseButtonImage:(CDVInvokedUrlCommand *)command {

    NSString *imageURL = [command argumentAtIndex:0];
    self.buttonImage = [self imageByURLString:imageURL];

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
            BOOL hasHTTP = [[options[@"buttonImage"] lowercaseString] hasPrefix:@"http://"];
            BOOL hasHTTPS = [[options[@"buttonImage"] lowercaseString] hasPrefix:@"https://"];
            if (hasHTTP || hasHTTPS) {
                if (nil == self.buttonImage) {
                    self.buttonImage = [self imageByURLString:options[@"buttonImage"]];
                }
            }
            else {
                NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:options[@"buttonImage"] ofType:nil];
                if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
                {
                    self.buttonImage = [UIImage imageNamed:options[@"buttonImage"]];
                }
                else
                {
                    NSLog(@"FrisBrowser: CloseButton Image File (%@) Not Found in Resource Path", options[@"buttonImage"]);
                }
            }
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
            [self.navigationController.navigationBar setBarTintColor:barTintColor];
        }
        else if (nil != barTintColor && [self.navigationController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
            [self.navigationController.navigationBar setTintColor:barTintColor];
        }
        else if (nil != barTintColor && [[UINavigationBar appearance] respondsToSelector:@selector(setBackgroundColor:)]) {
            [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setBackgroundColor:barTintColor];
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
                fontColor = [UIColor colorWithRed:[barFont[@"fontColor"][@"r"] floatValue]/255.0f green:[barFont[@"fontColor"][@"g"] floatValue]/255.0f  blue:[barFont[@"fontColor"][@"b"] floatValue]/255.0f  alpha:1.0f];
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
        else if (nil == closeButtonTitle && nil != self.buttonImage) {
            [self.webViewController.closeButton setTitle:@"" forState:UIControlStateNormal];
        }
        if (nil != self.buttonImage) {
            if (nil != closeButtonColor) {
                self.webViewController.closeButton.tintColor = closeButtonColor;
            }
            [self.webViewController.closeButton setImage:self.buttonImage forState:UIControlStateNormal];
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
