//
//  ViewController.m
//  SPScanning
//
//  Created by Libo on 2017/12/15.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import "GenerateViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

// 扫码
- (IBAction)scan:(UIButton *)sender {
    ScanViewController *scan = [[ScanViewController alloc] init];
    [self presentViewController:scan animated:YES completion:nil];
}

// 生成二维码、条形码
- (IBAction)generateCode:(UIButton *)sender {
    GenerateViewController *generate = [[GenerateViewController alloc] init];
    [self presentViewController:generate animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
