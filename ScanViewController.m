//
//  ScanViewController.m
//  SPScanManager
//
//  Created by leshengping on 2017/12/12.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "ScanViewController.h"
#import "SPScanManager.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface ScanViewController ()
@property (nonatomic, strong) SPScanManager *manager;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *preView = [[UIView alloc] initWithFrame:CGRectMake(10, (SCREEN_H-400)*0.5, 200, 400)];
    [self.view addSubview:preView];
    SPScanManager *manager = [[SPScanManager alloc] initWithPreView:preView cropRect:CGRectMake(0, 0, 100, 100) objectType:nil sessionPreset:AVCaptureSessionPresetHigh videoGravit:AVLayerVideoGravityResizeAspectFill completed:^(NSArray<SPScanResult *> *array) {
        SPScanResult *result = array.firstObject;
        NSLog(@"扫描结果result= %@",result.strScanned);
    }];
    // 开始扫描
    [manager startScan];
    // 需要用全局变量引用，否则局部变量在方法一结束就被释放了
    _manager = manager;
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.frame = CGRectMake(0, SCREEN_H-40, SCREEN_W, 30);
    descLabel.text = @"有效扫码区域在(0,0,100,100)区域内";
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:descLabel];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(16, 27, 30, 30);
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
}

- (void)cancelButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
