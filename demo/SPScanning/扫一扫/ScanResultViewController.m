//
//  ScanResultViewController.m
//  SPScanning
//
//  Created by develop1 on 2018/10/24.
//  Copyright © 2018 Cookie. All rights reserved.
//

#import "ScanResultViewController.h"
#import <WebKit/WebKit.h>

#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define screen_max_length (MAX(kScreenWidth, kScreenHeight))
#define is_iPhoneX (screen_max_length >= 812.0)
#define kNavigationHeight (is_iPhoneX ? 88.0f : 64.0f)

@interface ScanResultViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) CGFloat progressAcc;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setTintColor:[UIColor blackColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_black"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClicked)];

    [self.view addSubview:self.resultLabel];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kNavigationHeight, kScreenWidth, kScreenHeight-kNavigationHeight) configuration:configuration];
    _webView = webView;
    webView.navigationDelegate = self;

    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.result]]) {
        self.resultLabel.hidden = YES;
        webView.hidden = NO;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.result]]];
    } else {
        self.resultLabel.hidden = NO;
        webView.hidden = YES;
        self.resultLabel.text = [NSString stringWithFormat:@"扫描结果:\n%@",self.result];
    }
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.view addSubview:webView];

    [self.view addSubview:self.progressView];
    [self.view addSubview:_progressView];

    [self.view addSubview:self.closeButton];
}

- (void)backBtnClicked {
    [self.navigationController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.progressAcc = (1- self.progressView.progress ) / 25;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.progress = 0;
    self.progressView.hidden = NO;
    self.progressAcc = 0;
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.0167 target:self selector:@selector(progressCallback) userInfo:nil repeats:YES];
}
- (void)progressCallback {
    float progress = self.progressView.progress;
    if (self.progressAcc > 0) {
        if (progress >= 1) {
            [self.timer invalidate];
            self.timer = nil;
            self.progressView.hidden = YES;
            self.progressAcc = 0;
            return;
        }
        progress += self.progressAcc;
        if (progress > 1) {
            progress = 1;
        }
    }else if(progress < 0.95) {
        if ((progress += (0.95 - progress)*0.01) > 0.95) {
            progress = 0.95;
        }
    }
    self.progressView.progress = progress;
}

- (void)closeButtonAction {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        // 高度不给都行，不论给多大都是1
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNavigationHeight, kScreenWidth, 1)];
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
        _progressView.tintColor = [UIColor colorWithRed:29.0/255.0 green:178.0/255.0 blue:11.0/255.0 alpha:1];
        _progressView.trackTintColor = [UIColor clearColor];

    }
    return _progressView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _resultLabel.numberOfLines = 5;
        _resultLabel.textColor = [UIColor lightGrayColor];
        _resultLabel.font = [UIFont boldSystemFontOfSize:18];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
    }
    return  _resultLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(16, 27, 20, 20);
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    }
    return  _closeButton;
}

@end
