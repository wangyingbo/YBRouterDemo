//
//  BaseWebViewController.m
//  FengbangC
//
//  Created by kevin on 03/01/2018.
//  Copyright © 2018 kevin. All rights reserved.
//

#import "BaseWebViewController.h"
#import "YBRouterHeader.h"
@import WebKit;
@interface BaseWebViewController ()<WKUIDelegate,WKNavigationDelegate,YBRouterProtocol>
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSMutableArray *urlArray;
@property (nonatomic,copy) NSString *webUrlStr;
@end

@implementation BaseWebViewController

#pragma mark - override
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self configNavigation];
    [self configView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUrlStr:_webUrlStr];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"%@ appear",self.description);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    NSLog(@"%@ disappear",self.description);
}

- (void)dealloc{
    [_webView removeObserver:self forKeyPath:@"title"];
}

#pragma mark - initData
- (void)initData {
    NSDictionary *parameters = [self getRouterParameter];
    NSLog(@"<%@>通过参数方法传参的参数是：\n%@",NSStringFromClass([self class]),parameters);
    self.webUrlStr = self.routerString;
}

#pragma mark - initUI
- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];
    _webView = [[WKWebView alloc]initWithFrame:self.view.frame];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [_webView setAllowsBackForwardNavigationGestures:YES];
    [self.view addSubview:_webView];
    
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)configNavigation {
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
    //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

-(BOOL)navigationShouldPopOnBackButton{
    if (_urlArray.count>0) {
        NSURL *currentUrl = _webView.URL;
        NSURL *firstUrl = _urlArray.firstObject;
        if ([currentUrl isEqual:firstUrl]) {
            return YES;
        }else{
            if ([_webView canGoBack]) {
                [_webView goBack];
                return NO;
            }
        }
    }
    return YES;
}

//- (void)configObserver{
//    _urlArray = [[NSMutableArray alloc]init];
//    @weakify(self);
//    [RACObserve(_webView,URL) subscribeNext:^(id  _Nullable x) {
//        @strongify(self);
//        NSLog(@"urlSTR:%@",x);
//        NSString *scheme = [x scheme];
//        UIApplication *app = [UIApplication sharedApplication];
//        if ([scheme isEqualToString:@"tel"]) {
//            if ([app canOpenURL:x]) {
//                [app openURL:x];
//            }
//        }
//        [self.urlArray safe_addObject:x];
//        if (x!=nil) {
//            [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable webTitle, NSError * _Nullable error) {
//                if ([webTitle isKindOfClass:[NSString class]]) {
//                    self.title = webTitle;
//                }
//            }];
//        }
//    }];
//}

-(void)setUrlStr:(NSString *)urlStr {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

#pragma mark - kvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        }
        else
        {
//            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
    }else{
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}
#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%@",message);
    completionHandler();
}

#pragma mark - YBRouterProtocol
- (void)routerParameters:(id)parameters {
    NSLog(@"<%@>通过代理方法传参的参数是：\n%@",NSStringFromClass([self class]),parameters);
}

- (void)routerTransitionPreController:(__kindof UIViewController *)preController nextController:(__kindof UIViewController *)nextController {
    
    if (preController.navigationController) {
        [preController.navigationController pushViewController:nextController animated:YES];
    }else {
        [preController presentViewController:nextController animated:YES completion:nil];
    }
    
}

@end
