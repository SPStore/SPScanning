//
//  GenerateViewController.m
//  SPScanManager
//
//  Created by leshengping on 2017/12/12.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "GenerateViewController.h"
#import "SPScanCodeGenerator.h"

@interface GenerateViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;

@end

@implementation GenerateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

// 生成指定大小的普通二维码
- (IBAction)generatatePresetSizeQRCode:(UIButton *)sender {
    // qrWidth越大，分辨率越高
    UIImage *image = [SPScanCodeGenerator generateQRCodeByString:@"abcdefg" qrWidth:500];
    self.codeImageView.image = image;
}

// 生成彩色二维码
- (IBAction)generatateColorQRCode:(UIButton *)sender {
    UIImage *image = [SPScanCodeGenerator generateQRCodeWithColorByString:@"abcdefg" qrWidth:200 qrColor:[CIColor colorWithRed:0 green:1 blue:0] backgroundColor:[CIColor colorWithRed:0.7 green:0.2 blue:0.8]];
    self.codeImageView.image = image;
}

// 生成到logo的二维码
- (IBAction)genetatateLogoQRCode:(UIButton *)sender {
    // 利用字典定制logo的一些样式
    NSDictionary *dic = @{
                          SPLogoImageBorderWidthName:@5,
                          SPLogoImageInnerBorderWidthName:@1,
                          SPLogoImageInnerBorderColorName:[UIColor blackColor],
                          SPLogoImageBorderColorName:[UIColor whiteColor],
                          SPLogoImageCornerRadiusName:@10,
                          SPLogoImageShadowOffsetName:@(CGSizeMake(0, 3))
                          };
    // 如果你不想自己构造字典，可以采用默认的字典，调用C语言函数defaultDic()
    UIImage *image = [SPScanCodeGenerator generateQRCodeWithLogoByString:@"abcdefggig" qrWidth:400 logoImageName:@"logo.jpg" logoImageSet:dic logoScaleToSuperView:0.2];
    self.codeImageView.image = image;
}

// 生成彩色并带logo的二维码
- (IBAction)generatateColorWithLogoQRCode:(UIButton *)sender {
    // defaultDic()是默认字典，定制默认的logo样式
    UIImage *image = [SPScanCodeGenerator generateQRCodeWithLogoAndColorByString:@"zhonghuarenmin" qrWidth:400 logoImageName:@"logo.jpg" logoImageSet:defaultDic() qrColor:[CIColor colorWithRed:1 green:0 blue:1] backgroundColor:[CIColor colorWithRed:0 green:1 blue:0.5] logoScaleToSuperView:0.2];
    self.codeImageView.image = image;
}

// 生成普通条形码
- (IBAction)generatateBarCode:(UIButton *)sender {
    UIImage *image = [SPScanCodeGenerator generateBarCodeByString:@"abcdefg" barSize:CGSizeMake(200, 60)];
    self.codeImageView.image = image;
}

// 生成彩色条形码
- (IBAction)generateColorBarCode:(UIButton *)sender {
    UIImage *image = [SPScanCodeGenerator generateColorBarCodeByString:@"leshengping" barSize:CGSizeMake(200, 60) barColor:[CIColor colorWithRed:0 green:1 blue:0] backgroundColor:[CIColor colorWithRed:1 green:0 blue:0]];
    self.codeImageView.image = image;
}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
