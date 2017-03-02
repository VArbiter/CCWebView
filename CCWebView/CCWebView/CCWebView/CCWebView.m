//
//  CCWebView.m
//  CCWebView
//
//  Created by 冯明庆 on 17/3/1.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import "CCWebView.h"

@interface CCWebView () < UIWebViewDelegate , WKNavigationDelegate , WKUIDelegate , CCWebViewProgressDelegate >

@property (nonatomic , assign , readwrite) float floatLoadingProgress ;
@property (nonatomic , strong , readwrite) NSURLRequest *requestOrigin ;
@property (nonatomic , strong , readwrite) NSURLRequest *requestCurrent;
@property (nonatomic , strong , readwrite) NSString *stringTitle;

@property (nonatomic , assign) BOOL isUIWebView ;
@property (nonatomic , strong) CCUIWebViewDelegate *delegateWebView ;

- (void) ccInitWebView : (CCWebViewType) type ;
- (void) ccInitWKWebView ;
- (void) ccInitUIWebView ;
- (void) ccDefaultSettings ;

- (void) ccDelegate_WebViewDidStartLoading;
- (void) ccDelegate_WebViewDidFinishLoading;
- (void) ccDelegate_WebViewDidFailWithError : (NSError *) error ;
- (BOOL) ccDelegate_WebViewShouldStartLoadWithRequest : (NSURLRequest *) request
                                   withNavigationType : (NSInteger) navigationType ;
- (void) ccDelegate_WebViewDidBeginLoadingWithProgress : (float) floatProgress ;

@end

@implementation CCWebView

@synthesize isScaleToFit = _isScaleToFit;

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initByDefaultWithFrame:frame];
}
- (instancetype) initByDefaultWithFrame : (CGRect) frame {
    return [self initWithFrame:frame
               withWebViewType:CCWebViewTypeAuto];
}
- (instancetype) initWithFrame : (CGRect) frame
               withWebViewType : (CCWebViewType) type {
    if ((self = [super initWithFrame:frame])) {
        [self ccInitWebView:type];
        [self ccDefaultSettings];
    }
    return self;
}

- (id) ccLoadRequest : (NSURLRequest *) request {
    _requestOrigin = request;
    _requestCurrent = _requestOrigin;
    if (self.isUIWebView) {
        [(UIWebView *)_webViewInUse loadRequest:request];
        return nil;
    } else return [(WKWebView *)_webViewInUse loadRequest:request];
}
- (id) ccLoadHTMLString : (NSString *)string
                baseURL : (nullable NSURL *)baseURL {
    if (self.isUIWebView) {
        [(UIWebView *)_webViewInUse loadHTMLString:string
                                           baseURL:baseURL];
        return nil;
    } else return [(WKWebView *)_webViewInUse loadHTMLString:string
                                                     baseURL:baseURL];
}

- (void) ccEvaluateJavaScript : (NSString *) stringJavaScript
          withCompleteHandler : (nullable void (^) (id result , NSError *error) ) handler {
    if(self.isUIWebView) {
        NSString *stringResult = [(UIWebView *)_webViewInUse stringByEvaluatingJavaScriptFromString:stringJavaScript];
        _CC_Safe_Async_Block(handler, ^{
            handler(stringResult , nil);
        });
    } else return [(WKWebView *)_webViewInUse evaluateJavaScript:stringJavaScript
                                               completionHandler:handler];
}
- (NSString *) ccStringByEvaluatingJavaScriptFromString : (NSString *) stringJS {
    if (self.isUIWebView) return [(UIWebView *)_webViewInUse stringByEvaluatingJavaScriptFromString:stringJS];
    else {
        __block NSString *stringResult = nil;
        __block BOOL isExecuted = NO;
        [(WKWebView *)_webViewInUse evaluateJavaScript:stringJS
                                     completionHandler:^(id obj, NSError *error) {
            stringResult = obj;
            isExecuted = YES;
        }];
        
        while (!isExecuted) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
        }
        return stringResult;
    }
}

// for wk.
- (void) ccAddScriptMessageHandler : (id <WKScriptMessageHandler>) messageHandler
                          withName : (NSString *) stringName {
    if (self.isUIWebView) return ;
    [[(WKWebView *)_webViewInUse configuration].userContentController addScriptMessageHandler:messageHandler
                                                                                         name:stringName];
}
- (void) ccRemoveScirptMessageHandler : (NSString *) stringName {
    if (self.isUIWebView) return ;
    [[(WKWebView *)_webViewInUse configuration].userContentController removeScriptMessageHandlerForName:stringName];
}

- (id) ccGoBack {
    if (self.isUIWebView) {
        [(UIWebView *)_webViewInUse goBack];
        return nil;
    } else return [(WKWebView *)_webViewInUse goBack];
}
- (id) ccGoForward {
    if (self.isUIWebView) {
        [(UIWebView *)_webViewInUse goForward];
        return nil;
    } else return [(WKWebView *)_webViewInUse goForward];
}
- (id) ccReload {
    if(self.isUIWebView) {
        [(UIWebView *)_webViewInUse reload];
        return nil;
    } else return [(WKWebView *)_webViewInUse reload];
}
- (id) ccRefreshOrigin {
    if (self.isUIWebView) {
        if(_requestOrigin) {
            [self ccEvaluateJavaScript:[NSString stringWithFormat:@"window.location.replace('%@')",_requestOrigin.URL.absoluteString]
                   withCompleteHandler:nil];
        }
        return nil;
    } else return [(WKWebView *)_webViewInUse reloadFromOrigin];
}
- (void) ccStopLoading {
    [_webViewInUse stopLoading];
}

- (NSInteger) ccHistoryCount {
    if(self.isUIWebView) {
        UIWebView *webView = _webViewInUse;
        NSInteger integerCount = [[webView stringByEvaluatingJavaScriptFromString:@"window.history.length"] integerValue];
        return integerCount ? integerCount : 1 ;
    } else {
        WKWebView *webView = _webViewInUse;
        return webView.backForwardList.backList.count;
    }
}
/// return to a specific page .
- (void) ccReturnToPerPage : (NSInteger) integerLevel{
    if(!self.canGoBack) return;
    if(integerLevel > 0) {
        NSInteger integerHistory = [self ccHistoryCount];
        if(integerLevel >= integerHistory) {
            integerLevel = integerHistory - 1;
        }
        if(self.isUIWebView) {
            UIWebView *webView = _webViewInUse;
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%ld)", (long) integerLevel]];
        } else {
            WKWebView *webView = _webViewInUse;
            WKBackForwardListItem *itemBack = webView.backForwardList.backList[integerLevel];
            [webView goToBackForwardListItem:itemBack];
        }
    } else [self ccGoBack];
}

#pragma mark - Private Methods 
- (void) ccInitWebView : (CCWebViewType) type {
    switch (type) {
        case CCWebViewTypeUIWebView:{
            [self ccInitUIWebView];
        }break;
        case CCWebViewTypeWKWebView:{
            // Fall though .
        }
        case CCWebViewTypeAuto:{
#if _CC_AUTO_
            [self ccInitWKWebView];
#else
            [self ccInitUIWebView];
#endif
        } break;
            
        default:
            break;
    }
}
- (void) ccInitWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds
                                            configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    [webView addObserver:self
              forKeyPath:@"estimatedProgress"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    [webView addObserver:self
              forKeyPath:@"title"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    
    _webViewInUse = webView;
}
- (void) ccInitUIWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    for (UIView *tempSubview in [webView.scrollView subviews]) {
        if ([tempSubview isKindOfClass:[UIImageView class]]) {
            ((UIImageView *) tempSubview).image = nil;
            tempSubview.backgroundColor = [UIColor clearColor];
        }
    }
    _delegateWebView = [[CCUIWebViewDelegate alloc] init];
    _delegateWebView.delegateWebView = self;
    _delegateWebView.delegateProgress = self;
    __weak typeof(_delegateWebView) pDelegateWebView = _delegateWebView;
    webView.delegate = pDelegateWebView;
    _webViewInUse = webView;
}
- (void) ccDefaultSettings {
    [_webViewInUse setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:_webViewInUse];
}

#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self ccDelegate_WebViewDidStartLoading];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self ccDelegate_WebViewDidFinishLoading];
}
- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error {
    [self ccDelegate_WebViewDidFailWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error {
    [self ccDelegate_WebViewDidFailWithError:error];
}
- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self ccDelegate_WebViewShouldStartLoadWithRequest:navigationAction.request
                                        withNavigationType:navigationAction.navigationType]) {
        _requestCurrent = navigationAction.request;
        if (!navigationAction.targetFrame) [webView loadRequest:navigationAction.request] ;
        decisionHandler(WKNavigationActionPolicyAllow) ;
    } else decisionHandler(WKNavigationActionPolicyCancel);
}
#pragma mark - observer
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context{
    if([keyPath isEqualToString:@"estimatedProgress"]) {
        _floatLoadingProgress = [change[NSKeyValueChangeNewKey] doubleValue];
        [self ccDelegate_WebViewDidBeginLoadingWithProgress:_floatLoadingProgress];
    }
    else if([keyPath isEqualToString:@"title"]) {
        _stringTitle = change[NSKeyValueChangeNewKey];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self ccDelegate_WebViewDidStartLoading];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _stringTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (!_requestOrigin) {
        _requestOrigin = webView.request;
    }
    [self ccDelegate_WebViewDidFinishLoading];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self ccDelegate_WebViewDidFailWithError:error];
}
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self ccDelegate_WebViewShouldStartLoadWithRequest:request
                                           withNavigationType:navigationType];
}
#pragma mark - CCWebViewProgressDelegate
- (void)ccUIWebViewProgressDelegate:(CCUIWebViewDelegate *)delegateUIWebView withProgress:(float)floatProgress {
    _floatLoadingProgress = floatProgress;
    [self ccDelegate_WebViewDidBeginLoadingWithProgress:_floatLoadingProgress];
}
#pragma mark - CCWebViewDelegate
- (void) ccDelegate_WebViewDidStartLoading{
    if ([_delegate respondsToSelector:@selector(ccWebViewDidStartLoading:)]) {
        [_delegate ccWebViewDidStartLoading:self];
    }
}
- (void) ccDelegate_WebViewDidFinishLoading {
    if ([_delegate respondsToSelector:@selector(ccWebViewDidFinishLoading:)]) {
        [_delegate ccWebViewDidFinishLoading:self];
    }
}
- (void) ccDelegate_WebViewDidFailWithError : (NSError *) error {
    if ([_delegate respondsToSelector:@selector(ccWebViewDidFail:withError:)]) {
        [_delegate ccWebViewDidFail:self
                          withError:error];
    }
}
- (BOOL) ccDelegate_WebViewShouldStartLoadWithRequest : (NSURLRequest *) request
                                   withNavigationType : (NSInteger) navigationType {
    BOOL isExcuted = YES;
    if ([_delegate respondsToSelector:@selector(ccWebViewShouldStartLoad:withRequest:withNavigationType:)]) {
        if (navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        isExcuted = [_delegate ccWebViewShouldStartLoad:self
                                            withRequest:request
                                     withNavigationType:navigationType];
    }
    return isExcuted;
}
- (void) ccDelegate_WebViewDidBeginLoadingWithProgress : (float) floatProgress {
    if ([_delegate respondsToSelector:@selector(ccWebViewDidBeginLoading:withProgress:)]) {
        [_delegate ccWebViewDidBeginLoading:self
                               withProgress:floatProgress];
    }
}
#pragma mark - Setter
- (void)setIsScaleToFit:(BOOL)isScaleToFit {
    if(self.isUIWebView) {
        UIWebView *webView = _webViewInUse;
        webView.scalesPageToFit = isScaleToFit;
    } else {
        if(_isScaleToFit == isScaleToFit) {
            return;
        }
        WKWebView *webView = _webViewInUse;
        NSString *stringJS = @"var meta = document.createElement('meta'); \
                                meta.name = 'viewport'; \
                                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
                                var head = document.getElementsByTagName('head')[0];\
                                head.appendChild(meta);";
        if (isScaleToFit) {
            WKUserScript *userScript = [[WKUserScript alloc] initWithSource:stringJS
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                           forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:userScript];
        } else {
            NSMutableArray *array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
            for (WKUserScript *tempScript in array) {
                if([tempScript.source isEqual:stringJS]) {
                    [array removeObject:tempScript];
                    break;
                }
            }
            for (WKUserScript *tempScript in array) {
                [webView.configuration.userContentController addUserScript:tempScript];
            }
        }
    }
    _isScaleToFit = isScaleToFit;
}

#pragma mark - Getter
- (BOOL)isUIWebView {
    return [_webViewInUse isKindOfClass:[UIWebView class]];
}

- (UIScrollView *)scrollView {
    return [(id)_webViewInUse scrollView];
}
- (NSURLRequest *)requestCurrent {
    return self.isUIWebView ? [(UIWebView *)_webViewInUse request] : _requestCurrent;
}
- (NSURL *)url {
    return self.isUIWebView ? [(UIWebView *)_webViewInUse request].URL : [(WKWebView *)_webViewInUse URL];
}
- (BOOL)isLoading {
    return [_webViewInUse isLoading];
}
- (BOOL)canGoBack {
    return [_webViewInUse canGoBack];
}
- (BOOL)canGoForward {
    return [_webViewInUse canGoForward];
}
- (BOOL)isScaleToFit {
    return self.isUIWebView ? [_webViewInUse scalesPageToFit] : _isScaleToFit;
}

- (void)dealloc {
    if(self.isUIWebView) {
        UIWebView *webView = _webViewInUse;
        webView.delegate = nil;
    } else {
        WKWebView *webView = _webViewInUse;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
    
        [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [webView removeObserver:self forKeyPath:@"title"];
    }
}
@end

#pragma mark - CCUIWebViewDelegate

@interface CCUIWebViewDelegate ()

@property (nonatomic , assign , readwrite) float floatProgress ;
@property (nonatomic , assign) NSInteger integerLoadingCount ;
@property (nonatomic , assign) NSInteger integerMaxLoadingCount ;
@property (nonatomic , assign) BOOL isInteract ;
@property (nonatomic , strong) NSURL *urlCurrent ;

@property (nonatomic , readonly) NSString *stringProxy ;
@property (nonatomic , readonly) float floatCompleteProgress ;

- (void) ccDefaultSettings ;
- (void) ccStart ;
- (void) ccIncrement ;
- (void) ccReset ;
- (void) ccComplete ;

- (void) ccState : (UIWebView *) webView ;

@end

@implementation CCUIWebViewDelegate

- (instancetype)init {
    if ((self = [super init])) {
        [self ccDefaultSettings];
    }
    return self;
}

#pragma mark - Private .
- (void) ccDefaultSettings {
    _floatProgress = self.floatInitialProgress;
    [self ccReset];
}
- (void) ccStart {
    if (_floatProgress < self.floatInitialProgress) {
        [self setFloatProgress:self.floatInitialProgress];
    }
}
- (void) ccIncrement {
    float floatCurrentProgress = _floatProgress;
    float floatMaxProgress = _isInteract ? self.floatInitialProgress : self.floatInteractProgress;
    float floatRemainPercent = (float) _integerLoadingCount / (float) _integerMaxLoadingCount;
    [self setFloatProgress:fmin((floatMaxProgress - floatCurrentProgress) * floatRemainPercent, floatMaxProgress)];
}
- (void) ccReset {
    _integerMaxLoadingCount = _integerLoadingCount = 0;
    _isInteract = NO;
    [self setFloatProgress:.0f];
}
- (void) ccComplete {
    [self setFloatProgress:self.floatCompleteProgress];
}

- (void) ccState : (UIWebView *) webView {
    --_integerLoadingCount;
    [self ccIncrement];
    
    NSString *stringReadyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    BOOL isInteractive = [stringReadyState isEqualToString:@"interactive"];
    if (isInteractive) {
        _isInteract = isInteractive;
        NSString *stringCompleteJS = ccStringFormat(@"window.addEventListener('load', \
                                                    function() { \
                                                    var iframe = document.createElement('iframe'); \
                                                    iframe.style.display = 'none'; \
                                                    iframe.src = '%@'; \
                                                    document.body.appendChild(iframe); \
                                                    } \
                                                    , false);", self.stringProxy);
        [webView stringByEvaluatingJavaScriptFromString:stringCompleteJS];
    }
    
    BOOL isRedirect = !(_urlCurrent && [_urlCurrent isEqual:webView.request.mainDocumentURL]);
    BOOL isComplete = [stringReadyState isEqualToString:@"complete"];
    if (isComplete && !isRedirect) [self ccComplete];
}
#pragma mark - UIWebViewDelegate
- (void) webViewDidStartLoad:(UIWebView *)webView {
    if ([_delegateWebView respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_delegateWebView webViewDidStartLoad:webView];
    }
    _integerMaxLoadingCount = fmax(_integerMaxLoadingCount, ++_integerLoadingCount);
    [self ccStart];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView {
    if ([_delegateWebView respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_delegateWebView webViewDidFinishLoad:webView];
    }
    [self ccState:webView];
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([_delegateWebView respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_delegateWebView webView:webView
             didFailLoadWithError:error];
    }
    [self ccState:webView];
}
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString isEqualToString:self.stringProxy]) {
        [self ccComplete];
        return NO;
    }
    BOOL isValued = YES;
    if ([_delegateWebView respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        isValued = [_delegateWebView webView:webView
                  shouldStartLoadWithRequest:request
                              navigationType:navigationType];
    }
    BOOL isFragmentJump= NO;
    if (request.URL.fragment) {
        NSString *stringNonFragment = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment]
                                                                                            withString:@""];
        isFragmentJump = [stringNonFragment isEqualToString:webView.request.URL.absoluteString];
    }
    BOOL isNavigationTopLevel = [request.URL isEqual:request.mainDocumentURL];
    BOOL isHTTPScheme = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (isValued && !isFragmentJump && isNavigationTopLevel && isHTTPScheme) {
        _urlCurrent = request.URL;
        [self ccReset];
    }
    return isValued;
}
#pragma mark - Setter
- (void)setFloatProgress:(float)floatProgress {
    // only increment
    if (floatProgress > _floatProgress || !floatProgress) {
        _floatProgress = floatProgress;
        if ([_delegateProgress respondsToSelector:@selector(ccUIWebViewProgressDelegate:withProgress:)]) {
            [_delegateProgress ccUIWebViewProgressDelegate:self
                                              withProgress:floatProgress];
        }
        ccWeakSelf;
        _CC_Safe_Async_Block(_blockProgress, ^{
            pSelf.blockProgress(floatProgress);
        });
    }
}
#pragma mark - Getter
- (float)floatInitialProgress {
    return .1f;
}
- (float)floatInteractProgress {
    return .5f;
}
- (float)floatFinalProgress {
    return .9f;
}
- (float)floatCompleteProgress {
    return 1.0f;
}
- (NSString *)stringProxy {
    return @"webviewprogressproxy:///complete";
}
@end

#pragma mark - CCCommonDef

@interface CCCommonDef ()

void _CC_SAFE_BLOCK(id block_nil , dispatch_block_t block , BOOL isSync) ;

@end

@implementation CCCommonDef

void _CC_Safe_Sync_Block(id block_nil , dispatch_block_t block) {
    _CC_SAFE_BLOCK(block_nil , block, YES);
}

void _CC_Safe_Async_Block(id block_nil , dispatch_block_t block) {
    _CC_SAFE_BLOCK(block_nil , block, NO);
}

#pragma mark - Private .

void _CC_SAFE_BLOCK(id block_nil , dispatch_block_t block , BOOL isSync) {
    if (!block || !block_nil) return;
    if ([NSThread isMainThread]) {
        block();
    } else {
        isSync ? dispatch_sync(dispatch_get_main_queue(), block) : dispatch_async(dispatch_get_main_queue(), block) ;
    }
}

@end

#pragma mark - Solve Memory LEAK

@implementation CCWKScriptMessageDelegate

+ (instancetype)ccInitWithDelegate:(id<WKScriptMessageHandler>)delegateScriptMessage {
    CCWKScriptMessageDelegate *item = [[self alloc] init];
    item.delegateScriptMessage = delegateScriptMessage;
    return item;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegateScriptMessage userContentController:userContentController
                              didReceiveScriptMessage:message];
}
@end
