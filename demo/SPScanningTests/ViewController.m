//
//  ViewController.m
//  SPScanning
//
//  Created by develop1 on 2018/10/24.
//  Copyright © 2018 Cookie. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import "GenerateViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

// 扫码
- (IBAction)scan:(UIButton *)sender {
//    [self promptSettingAuthority];
    ScanViewController *scan = [[ScanViewController alloc] init];
    [self presentViewController:scan animated:YES completion:nil];
}

// 生成二维码、条形码
- (IBAction)generateCode:(UIButton *)sender {
    GenerateViewController *generate = [[GenerateViewController alloc] init];
    [self presentViewController:generate animated:YES completion:nil];
}

- (void)promptSettingAuthority {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *title = [NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机“选项中，允许%@访问你的相机",app_Name];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
