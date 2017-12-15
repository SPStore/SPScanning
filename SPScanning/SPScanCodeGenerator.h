//
//  SPScanCodeGenerator.h
//  SPScanManager
//
//  Created by leshengping on 2017/12/8.
//  Copyright © 2017年 leshengping. All rights reserved.
//  二维码、条码生成器

#import <UIKit/UIKit.h>

typedef NSString * SPLogoKey;

UIKIT_EXTERN SPLogoKey const SPLogoImageCornerRadiusName;     // logo的圆角半径
UIKIT_EXTERN SPLogoKey const SPLogoImageBorderWidthName;      // logo的边框宽度
UIKIT_EXTERN SPLogoKey const SPLogoImageBorderColorName;      // logo的边框颜色
UIKIT_EXTERN SPLogoKey const SPLogoImageOuterBorderWidthName; // logo的最外层的边框
UIKIT_EXTERN SPLogoKey const SPLogoImageOuterBorderColorName; // logo的最外层的边框颜色
UIKIT_EXTERN SPLogoKey const SPLogoImageInnerBorderWidthName; // logo的最内层的边框
UIKIT_EXTERN SPLogoKey const SPLogoImageInnerBorderColorName; // logo的最内层的边框颜色
UIKIT_EXTERN SPLogoKey const SPLogoImageShadowOffsetName;     // logo的阴影偏移大小

// C语言函数，返回一个默认字典，用于定制logo样式,如圆角、边框等
NSDictionary *defaultDic(void);

@interface SPScanCodeGenerator : NSObject

/**
 生成默认大小的普通二维码
 
 @param text 字符串
 @return 返回二维码图像
 */
+ (UIImage *)generateQRCodeByString:(NSString *)text;

/**
 生成一张指定大小的普通二维码
 
 @param text 字符串
 @param qrWidth 二维码大小,该宽度决定二维码图片的像素
 @return 返回二维码图像
 */
+ (UIImage *)generateQRCodeByString:(NSString *)text qrWidth:(CGFloat)qrWidth;

/**
 生成一张带有logo的二维码
 
 @param text 字符串
 @param logoScaleToSuperView 相对于父视图的缩放比,取值范围0-1;0,不显示，1,代表与父视图大小相同
 @return 返回二维码图像
 */
+ (UIImage *)generateQRCodeWithLogoByString:(NSString *)text
                                    qrWidth:(CGFloat)qrWidth
                              logoImageName:(NSString *)logoImageName
                       logoScaleToSuperView:(CGFloat)logoScaleToSuperView;

/**!!!!!!!
 生成一张带有logo的二维码,并且可以定制logo的一些样式
 
 @param text 字符串
 @param set  字典，用于定制logo的一些样式，其中字典的key为SPLogoKey,之所以采用字典，是为了简化参数的个数.如果set为nil或        没有键值对，就和上面那个方法等效.  你可以调用C语言函数defaultDic()设置默认的字典
 @param logoScaleToSuperView 相对于父视图的缩放比,取值范围0-1;0,不显示，1,代表与父视图大小相同
 @return 返回二维码图像
 */
+ (UIImage *)generateQRCodeWithLogoByString:(NSString *)text
                                    qrWidth:(CGFloat)qrWidth
                              logoImageName:(NSString *)logoImageName
                               logoImageSet:(NSDictionary<SPLogoKey,id> *)set
                       logoScaleToSuperView:(CGFloat)logoScaleToSuperView;


/**
 生成一张彩色的二维码
 
 @param text 字符串
 @param qrColor 二维码颜色
 @param backgroundColor 背景色
 @return 返回二维码图像
 */
+ (UIImage *)generateQRCodeWithColorByString:(NSString *)text
                                     qrWidth:(CGFloat)qrWidth
                                     qrColor:(CIColor *)qrColor
                             backgroundColor:(CIColor *)backgroundColor;

/**
 生成一张彩色并带logo的二维码
 
 @param text 字符串
 @param qrColor 二维码颜色
 @param backgroundColor 背景色
 @return 返回二维码图像
 */
+ (UIImage *)generateQRCodeWithLogoAndColorByString:(NSString *)text
                                            qrWidth:(CGFloat)qrWidth
                                      logoImageName:(NSString *)logoImageName
                                       logoImageSet:(NSDictionary<SPLogoKey,id> *)set
                                            qrColor:(CIColor *)qrColor
                                    backgroundColor:(CIColor *)backgroundColor
                               logoScaleToSuperView:(CGFloat)logoScaleToSuperView;
/**
 生成普通条形码（一维码）
 
 @param text 字符串
 @param size 大小
 @return 返回条码图像
 */
+ (UIImage *)generateBarCodeByString:(NSString *)text barSize:(CGSize)size;

/**
 生成彩色条形码（一维码）
 
 @param text 字符串
 @param size 大小
 @return 返回条码图像
 */
+ (UIImage *)generateColorBarCodeByString:(NSString *)text
                                  barSize:(CGSize)size
                                  barColor:(CIColor *)barColor
                          backgroundColor:(CIColor *)backgroundColor;;


@end
