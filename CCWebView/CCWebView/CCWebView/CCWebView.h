//
//  CCWebView.h
//  CCWebView
//
//  Created by 冯明庆 on 17/3/1.
//  Copyright © 2017年 冯明庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    #define _CC_AUTO_ 1
#else
    #define _CC_AUTO_ 0
#endif

#ifndef __OPTMIZE__
    #define CCLog(fmt,...) NSLog((@"\n %s \n %s %d \n" fmt),__FILE__,__func__,__LINE__,##__VA_ARGS__)
#else
    #define CCLog(...) /* */
#endif

#define _CC_DETECT_DEALLOC_ \
    - (void)dealloc { \
        CCLog(@"_CC_%@_DEALLOC_" , NSStringFromClass([self class]));\
    }\

@class CCWebView;

typedef NS_ENUM(NSInteger , CCWebViewType) {
    CCWebViewTypeUIWebView = 0 ,
    CCWebViewTypeWKWebView ,
    CCWebViewTypeAuto
};

NS_ASSUME_NONNULL_BEGIN

@protocol CCWebViewDelegate <NSObject>

@optional
- (void) ccWebViewDidStartLoading : (CCWebView *) webView ;
- (void) ccWebViewDidFinishLoading : (CCWebView *) webView ;
- (void) ccWebViewDidFail : (CCWebView *) webView
                withError : (NSError *) error ;
- (BOOL) ccWebViewShouldStartLoad : (CCWebView *) webView
                      withRequest : (NSURLRequest *) request
               withNavigationType : (UIWebViewNavigationType) navigationType ;
@end

@interface CCWebView : UIView

/// default Auto .
- (instancetype) initByDefaultWithFrame : (CGRect) frame ;
- (instancetype) initWithFrame : (CGRect) frame
               withWebViewType : (CCWebViewType) type ;

@property (nonatomic , assign) id <CCWebViewDelegate> delegate ;

/// WebView that presently in use .
@property (nonatomic , readonly) id webViewInUse ;
/// estimated loading Progress
@property (nonatomic , assign , readonly) float floatLoadingProgress ;
/// originReguest
@property (nonatomic , strong , readonly) NSURLRequest *requestOrigin ;
@property (nonatomic , strong , readonly) NSURLRequest *requestCurrent;
@property (nonatomic , strong , readonly) NSString *stringTitle;

#pragma mark - Kinda System API
@property (nonatomic , strong , readonly) UIScrollView *scrollView ;
@property (nonatomic , strong , readonly) NSURL *url;
@property (nonatomic , assign) BOOL isScaleToFit;

@property (nonatomic , assign , readonly) BOOL isLoading;
@property (nonatomic , assign , readonly) BOOL canGoBack;
@property (nonatomic , assign , readonly) BOOL canGoForward;

- (id) ccLoadRequest : (NSURLRequest *) request ;
- (id) ccLoadHTMLString : (NSString *)string
                baseURL : (nullable NSURL *)baseURL;

- (void) ccEvaluateJavaScript : (NSString *) stringJavaScript
          withCompleteHandler : (nullable void (^) (id result , NSError *error) ) handler ;
- (NSString *) ccStringByEvaluatingJavaScriptFromString : (NSString *) stringJS __deprecated_msg("Not recommend . Use [ccEvaluateJavaScript:withCompleteHandler:] instead"); // Sync . Wait until it finished . Not recommend .

// for wk.
- (void) ccAddScriptMessageHandler : (id <WKScriptMessageHandler>) messageHandler
                          withName : (NSString *) stringName NS_AVAILABLE_IOS(8_0);
- (void) ccRemoveScirptMessageHandler : (NSString *) stringName NS_AVAILABLE_IOS(8_0) ;


- (id) ccGoBack ;
- (id) ccGoForward ;
- (id) ccReload ;
- (id) ccRefreshOrigin ; // reload Origin Page
- (void) ccStopLoading ;

- (NSInteger) ccHistoryCount ;
/// return to a specific page .
- (void) ccReturnToPerPage : (NSInteger) integerLevel;

@end

@interface CCCommonDef : NSObject

void _CC_Safe_Sync_Block(id block_nil , dispatch_block_t block);

void _CC_Safe_Async_Block(id block_nil , dispatch_block_t block);

@end

NS_ASSUME_NONNULL_END
