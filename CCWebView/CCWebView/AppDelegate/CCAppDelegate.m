//
//  CCAppDelegate.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/1.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCAppDelegate.h"
#import "CCBasicViewController.h"

@interface CCAppDelegate ()

@end

@implementation CCAppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[CCBasicViewController alloc] initWithNibName:NSStringFromClass([CCBasicViewController class]) bundle:[NSBundle mainBundle]]];
    return YES;
}

@end
