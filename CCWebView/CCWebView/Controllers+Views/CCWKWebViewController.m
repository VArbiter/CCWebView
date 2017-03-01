//
//  CCWKWebViewController.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/1.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCWKWebViewController.h"
#import "CCWebView.h"

@interface CCWKWebViewController ()

@end

@implementation CCWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CCWebView *webView = [[CCWebView alloc] initByDefaultWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    [webView ccLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
