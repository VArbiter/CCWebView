//
//  CCBasicViewController.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/2.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCBasicViewController.h"
#import "CCWebViewController.h"

@interface CCBasicViewController ()

- (IBAction)ccButtonActionUIWebView:(UIButton *)sender;
- (IBAction)ccButtonActionWKWebView:(UIButton *)sender;

- (void) ccJumpWithType : (CCWebViewType) type ;

@end

@implementation CCBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([CCWebView class]);
}

- (IBAction)ccButtonActionUIWebView:(UIButton *)sender {
    [self ccJumpWithType:CCWebViewTypeUIWebView];
}

- (IBAction)ccButtonActionWKWebView:(UIButton *)sender {
    [self ccJumpWithType:CCWebViewTypeAuto];
}

- (void) ccJumpWithType : (CCWebViewType) type {
    [self.navigationController pushViewController:[[CCWebViewController alloc] initWithType:type] animated:YES];
}
@end
