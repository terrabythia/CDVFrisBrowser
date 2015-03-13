//
//  ViewController.m
//  inappbrowser
//
//  Created by Sander on 05/03/15.
//  Copyright (c) 2015 Frismedia. All rights reserved.
//

#import "FrisBrowserViewController.h"
#import "FrisBrowser.h"

@interface FrisBrowserViewController ()

- (IBAction)didPressCloseButton:(UIButton *)sender;

@end

@implementation FrisBrowserViewController

@synthesize closeButton = _closeButton;
@synthesize webView = _webView;
@synthesize activityIndicatorView = _activityIndicatorView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Loading";
}

- (IBAction) didPressCloseButton:(UIButton *)sender {
    [[FrisBrowser sharedInstance] close:nil];
}

@end
