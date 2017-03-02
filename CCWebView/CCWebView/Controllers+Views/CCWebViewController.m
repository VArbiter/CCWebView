//
//  CCWebViewController.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/2.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCWebViewController.h"

@interface CCWebViewController ()

@property (nonatomic , assign) CCWebViewType type;

@end

@implementation CCWebViewController

- (instancetype) initWithType : (CCWebViewType) type {
    if ((self = [super init])) {
        _type = type;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    CCWebView *webView = nil;
    if (_type != CCWebViewTypeUIWebView) {
        webView = [[CCWebView alloc] initByDefaultWithFrame:self.view.bounds];
    } else webView = [[CCWebView alloc] initWithFrame:self.view.bounds
                                      withWebViewType:CCWebViewTypeUIWebView];
    [self.view addSubview:webView];
    [webView ccLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    self.title = NSStringFromClass([webView.webViewInUse class]);
}

_CC_DETECT_DEALLOC_

@end
