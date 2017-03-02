//
//  CCWebViewController.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/2.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCWebViewController.h"

@interface CCWebViewController () <CCWebViewDelegate>

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
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView ccLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    self.title = NSStringFromClass([webView.webViewInUse class]);
}

#pragma mark - CCWebViewDelegate
- (void)ccWebViewDidStartLoading:(CCWebView *)webView {
    CCLog(@"_CC_%s_",__FUNCTION__);
}
- (void)ccWebViewDidFinishLoading:(CCWebView *)webView {
    CCLog(@"_CC_%s_",__FUNCTION__);
}
- (void)ccWebViewDidFail:(CCWebView *)webView withError:(NSError *)error {
    CCLog(@"_CC_%s_",__FUNCTION__);
}
- (BOOL)ccWebViewShouldStartLoad:(CCWebView *)webView withRequest:(NSURLRequest *)request withNavigationType:(UIWebViewNavigationType)navigationType {
    CCLog(@"_CC_%s_",__FUNCTION__);
    CCLog(@"_CC_%@_",request.URL.absoluteString);
    return YES;
}

_CC_DETECT_DEALLOC_

@end
