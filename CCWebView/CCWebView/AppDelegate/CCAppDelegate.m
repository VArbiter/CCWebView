//
//  CCAppDelegate.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/1.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCAppDelegate.h"
#import "CCWKWebViewController.h"

@interface CCAppDelegate ()

@end

@implementation CCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyWindow];
    _window.rootViewController = [[CCWKWebViewController alloc] init];
    return YES;
}

@end
