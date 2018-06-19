//
// Created by ssyram on 2018/6/10.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "WebKit/WebKit.h"
#import "BaiduViewController.h"

@interface BaiduViewController()<WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation BaiduViewController

- (void)viewDidLoad{
    [super loadView];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.baidu.com/?pu=sz%401321_666"]]];
    [self.view addSubview:webView];
}

@end