//
//  ScanViewController.m
//  SPScanning
//
//  Created by develop1 on 2018/10/24.
//  Copyright © 2018 Cookie. All rights reserved.
//

#import "ScanViewController.h"
#import "SPScanManager.h"
#import "CodeReaderView.h"
#import "ScanAreaView.h"
#import "SPButton.h"
#import "ScanResultViewController.h"

@interface ScanViewController () <SPScanManagerDelegate,CodeReaderViewDelegate>
@property (nonatomic, weak) SPButton *torchButton; // 手电筒
@property (nonatomic, weak) CodeReaderView *readerView;
@property (nonatomic, weak) ScanAreaView *scanAreaView;
@property (nonatomic, weak) UILabel *lblTip;
@property (nonatomic, weak) UIButton *closeButton;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubViews];

    [[SPScanManager sharedScanManager] scanWithPreView:self.readerView scanRect:CGRectZero objectType:nil completed:^(NSArray<SPScanResult *> *array) {
        NSLog(@"扫描结果=%@",array);
        SPScanResult *result = [array firstObject];
        ScanResultViewController *resultVc = [[ScanResultViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:resultVc];
        resultVc.result = result.strScanned;
        [self presentViewController:navi animated:YES completion:nil];
    }];
    [SPScanManager sharedScanManager].delegate = self;
    [[SPScanManager sharedScanManager] startScan];
}

- (void)setupSubViews {
    // 读取二维码的view（关键view）
    CodeReaderView *readerView = [[CodeReaderView alloc] init];
    readerView.frame = self.view.bounds;
    readerView.delegate = self;
    [self.view addSubview:readerView];
    _readerView = readerView;

    // 和扫描区域一样大小的view，主要就是现显示四个直角扫描图片和中间的动画扫描线
    ScanAreaView *scanAreaView = [[ScanAreaView alloc] init];
    scanAreaView.layer.masksToBounds = YES;
    [self.view addSubview:scanAreaView];
    _scanAreaView = scanAreaView;

    UILabel *lblTip = [[UILabel alloc] init];
    lblTip.text = @"将二维码放入框内，即可自动扫描";
    lblTip.textColor = [UIColor whiteColor];
    lblTip.font = [UIFont systemFontOfSize:13];
    lblTip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblTip];
    _lblTip = lblTip;

    // 手电筒
    SPButton *torchButton = [SPButton buttonWithType:UIButtonTypeCustom];
    [torchButton setImage:[UIImage imageNamed:@"torchClose"] forState:UIControlStateNormal];
    [torchButton setImage:[UIImage imageNamed:@"torchOpen"] forState:UIControlStateSelected];
    [torchButton setTitle:@"轻触照亮" forState:UIControlStateNormal];
    [torchButton setTitle:@"轻触关闭" forState:UIControlStateSelected];
    torchButton.titleLabel.font = [UIFont systemFontOfSize:13];
    torchButton.imagePosition = SPButtonImagePositionTop;
    [torchButton addTarget:self action:@selector(torchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    torchButton.hidden = YES;
    [self.view addSubview:torchButton];
    _torchButton = torchButton;

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(16, 27, 20, 20);
    [closeButton setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close_highlight"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    _closeButton = closeButton;
}

- (void)torchButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [SPScanManager sharedScanManager].torchOn = sender.selected;
}

- (void)closeButtonAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - SPScanManagerDelegate
- (void)scanManagerBrightnessValueDidChanged:(float)brightnessValue {
    self.torchButton.hidden = brightnessValue > 0 && ![SPScanManager sharedScanManager].torchOn;
    self.scanAreaView.scanAnimationImageView.hidden = !self.torchButton.hidden;
}

- (void)codeReaderViewDrawRect:(CGRect)rect {

    // 设置有效扫码区域
    [SPScanManager sharedScanManager].scanRect = rect;

    CGFloat c_width = _readerView.innerViewRect.size.width;
    CGFloat c_y = _readerView.innerViewRect.origin.y;
    _scanAreaView.frame = rect;
    _torchButton.frame = CGRectMake((self.view.bounds.size.width-60)*0.5, c_y + c_width - 65, 60, 60);

    self.lblTip.frame = CGRectMake(0, c_y + c_width + 20, self.view.bounds.size.width, 15);
    [self.lblTip layoutIfNeeded];

    // 执行扫描线动画
    [self.scanAreaView performAnimation];
}

@end
