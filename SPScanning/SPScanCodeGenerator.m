//
//  SPScanCodeGenerator.m
//  SPScanManager
//
//  Created by leshengping on 2017/12/8.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "SPScanCodeGenerator.h"

SPLogoKey const SPLogoImageCornerRadiusName = @"SPLogoImageCornerRadiusName";
SPLogoKey const SPLogoImageBorderWidthName = @"SPLogoImageBorderWidthName";
SPLogoKey const SPLogoImageBorderColorName = @"SPLogoImageBorderColorName";
SPLogoKey const SPLogoImageOuterBorderWidthName = @"SPLogoImageOuterBorderWidthName";
SPLogoKey const SPLogoImageOuterBorderColorName = @"SPLogoImageOuterBorderColorName";
SPLogoKey const SPLogoImageInnerBorderWidthName = @"SPLogoImageInnerBorderWidthName";
SPLogoKey const SPLogoImageInnerBorderColorName = @"SPLogoImageInnerBorderColorName";
SPLogoKey const SPLogoImageShadowOffsetName = @"SPLogoImageShadowOffsetName";

@implementation SPScanCodeGenerator

#pragma mark - public

// 生成默认大小的普通的二维码
+ (UIImage *)generateQRCodeByString:(NSString *)text {
    // 默认大小
    CGFloat codeSize = MIN(CGRectGetWidth([UIScreen mainScreen].bounds) - 80, 160);
    return [self generateQRCodeByString:text qrWidth:codeSize];
}

// 生成指定大小的普通的二维码
+ (UIImage *)generateQRCodeByString:(NSString *)text qrWidth:(CGFloat)qrWidth {
    // 生成二维码图片
    CIImage *outputImage = [self generatateQRCIImageWithString:text];
    // 转化成指定大小的UIImage
    return [self createNonInterpolatedUIImageFormCIImage:outputImage qrWidth:qrWidth];
}

// 生成带logo的二维码
+ (UIImage *)generateQRCodeWithLogoByString:(NSString *)text
                                    qrWidth:(CGFloat)qrWidth
                              logoImageName:(NSString *)logoImageName
                       logoScaleToSuperView:(CGFloat)logoScaleToSuperView {
    UIImage *final_image = [self generateQRCodeWithLogoByString:text qrWidth:qrWidth logoImageName:logoImageName logoImageSet:nil logoScaleToSuperView:logoScaleToSuperView];
    return final_image;
}

// 生成带logo的二维码，可定制logo样式
+ (UIImage *)generateQRCodeWithLogoByString:(NSString *)text
                                    qrWidth:(CGFloat)qrWidth
                              logoImageName:(NSString *)logoImageName
                               logoImageSet:(NSDictionary<SPLogoKey,id> *)set
                       logoScaleToSuperView:(CGFloat)logoScaleToSuperView {

    return [self generateQRCodeWithLogoAndColorByString:text qrWidth:qrWidth logoImageName:logoImageName logoImageSet:set qrColor:nil backgroundColor:nil logoScaleToSuperView:logoScaleToSuperView];
}

// 生成彩色的二维码
+ (UIImage *)generateQRCodeWithColorByString:(NSString *)text qrWidth:(CGFloat)qrWidth qrColor:(CIColor *)qrColor backgroundColor:(CIColor *)backgroundColor {

    CIImage *outputImage = [self generatateQRCIImageWithString:text];
    CGRect extent = CGRectIntegral(outputImage.extent);
    // 放大,一般生成的outputImage都不是很大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(qrWidth/extent.size.width, qrWidth/extent.size.height)];
    
    // 彩色的二维码图片
    outputImage = [self colorImage:outputImage backgroundColor:backgroundColor qrColor:qrColor];

    return [UIImage imageWithCIImage:outputImage];
    
}

// 生成彩色并携带logo的二维码
+ (UIImage *)generateQRCodeWithLogoAndColorByString:(NSString *)text
                                            qrWidth:(CGFloat)qrWidth
                                      logoImageName:(NSString *)logoImageName
                                       logoImageSet:(NSDictionary<SPLogoKey,id> *)set
                                            qrColor:(CIColor *)qrColor backgroundColor:(CIColor *)backgroundColor logoScaleToSuperView:(CGFloat)logoScaleToSuperView {
    // 生成二维码图片
    CIImage *outputImage = [self generatateQRCIImageWithString:text];
    CGRect extent = CGRectIntegral(outputImage.extent);
    // 放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(qrWidth/extent.size.width, qrWidth/extent.size.height)];
    if (qrColor || backgroundColor) {
        // 彩色的二维码图片
        outputImage = [self colorImage:outputImage backgroundColor:backgroundColor qrColor:qrColor];
    }
    // 将CIImage类型转成UIImage类型
    //UIImage *qr_image = [self createNonInterpolatedUIImageFormCIImage:outputImage qrWidth:qrWidth];
    UIImage *qr_image = [UIImage imageWithCIImage:outputImage];
    // 开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContextWithOptions(qr_image.size, NO, [UIScreen mainScreen].scale);
    CGRect qr_imageRect = CGRectMake(0, 0, qr_image.size.width, qr_image.size.height);
    // 把二维码图片画上去 (这里是以图形上下文,左上角为(0,0)点
    [qr_image drawInRect:qr_imageRect];
    
    // 获取logo图片
    UIImage *logoImage = [UIImage imageNamed:logoImageName];
    CGFloat logoImageW = qr_image.size.width * logoScaleToSuperView;
    CGFloat logoImageH = qr_image.size.height * logoScaleToSuperView;
    CGFloat logoImageX = (qr_image.size.width - logoImageW) * 0.5;
    CGFloat logoImageY = (qr_image.size.height - logoImageH) * 0.5;
    // 小logo的矩形区域，如果有边框，则logo会在该矩形区域”内缩“边框宽度后的矩形中绘制
    CGRect logoImageRect = CGRectMake(logoImageX, logoImageY, logoImageW, logoImageH);
    
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    
    // if语句内部都是与logo相关
    if (set && set.count) {
        
        // 从字典中获取value赋值，并会打印相关错误.这个携带block的方法无非就是封装了一些累赘而又必要的代码
        [self getValueFromDictionary:set completeBlock:^(CGFloat cornerRadius, CGFloat borderWidth, UIColor *borderColor, CGFloat outerBorderWidth, UIColor *outerBorderColor, CGFloat innerBorderWidth, UIColor *innerBorderColor, CGSize shadowOffset) {
 
            // 绘制阴影
            CGContextSaveGState(ctx);
            CGContextAddArcForRect(ctx, logoImageRect, cornerRadius+borderWidth*0.5+outerBorderWidth);
            CGContextSetShadow(ctx,shadowOffset, 1);
            CGContextFillPath(ctx);
            CGContextRestoreGState(ctx);
            
            // 保存图形上下文栈
            CGContextSaveGState(ctx);
            // 绘制裁剪路径,这条曲线的作用是对本上下文栈的内容进行裁剪,注意是本上下文栈，不影响栈外内容
            // 第一个参数:上下文,第二个参数:矩形区域,第三个参数:圆角半径
            CGContextAddArcForRect(ctx, logoImageRect, cornerRadius+borderWidth*0.5+outerBorderWidth);
            // 裁剪，裁剪只对当前上下文栈中未绘制的内容有效，对已绘制的内容无效.渲染之前都被认作是未绘制
            CGContextClip(ctx);
            // 渲染
            CGContextStrokePath(ctx);
            
            // 对logoImageRect进行内缩(内缩值=最外层边框宽度+边框宽度+最内层边框宽度),得到一个新的内层矩形框。内缩后,logoImageRect与innerRect的边界之间就多了一层间隙，该间隙用于画边框
            CGRect innerImageRect = CGRectInset(logoImageRect, outerBorderWidth+borderWidth+innerBorderWidth, outerBorderWidth+borderWidth+innerBorderWidth);
            // 画小logo
            [logoImage drawInRect:innerImageRect];
            // 出栈
            CGContextRestoreGState(ctx);
            
            // ------------------------------- 画圆角矩形框的最外层边框outerBorder -------------------------
            // 对logoImageRect进行内缩(内缩值=最外层边框宽度的一半),得到一个用于绘制最外层边框的内层矩形框。
            CGRect outerBorderRect = CGRectInset(logoImageRect, outerBorderWidth*0.5, outerBorderWidth*0.5);
            // 绘制圆角边框
            // 第一个参数:上下文,第二个参数:矩形区域,第三个参数:圆角半径
            CGContextAddArcForRect(ctx, outerBorderRect, cornerRadius+borderWidth*0.5+outerBorderWidth*0.5);
            // 最外层边框的颜色
            CGContextSetStrokeColorWithColor(ctx, outerBorderColor.CGColor);
            // 最外层边框宽度
            CGContextSetLineWidth(ctx, outerBorderWidth);
            // 渲染
            CGContextStrokePath(ctx);
            
            // ------------------------------- 画圆角矩形框border -------------------------
            // 对logoImageRect进行内缩(内缩值=最外层边框宽度+边框宽度的一半),得到一个新的内层矩形框，这个矩形框夹在logoImageRect与innerRect中间
            CGRect innerCenterRect = CGRectInset(logoImageRect, outerBorderWidth+borderWidth*0.5, outerBorderWidth+borderWidth*0.5);
            
            // 边框颜色
            [borderColor set];
            // 绘制圆角边框
            // 第一个参数:上下文,第二个参数:矩形区域,第三个参数:圆角半径
            CGContextAddArcForRect(ctx, innerCenterRect, cornerRadius);
            // 边框宽度
            CGContextSetLineWidth(ctx, borderWidth);
            // 渲染
            CGContextDrawPath(ctx, kCGPathStroke);
            
            // ------------------------------- 画圆角矩形框的最内层边框innerBorder -------------------------
            // 对logoImageRect进行内缩(内缩值=最外层边框宽度+边框宽度+最内层边框宽度的一半),得到一个用于绘制最内层边框的内层矩形框。
            CGRect innerBorderRect = CGRectInset(logoImageRect,  outerBorderWidth+borderWidth+innerBorderWidth*0.5, outerBorderWidth+borderWidth+innerBorderWidth*0.5);
            
            CGFloat innerBorderCornerRadius = cornerRadius-borderWidth*0.5-innerBorderWidth*0.5;
            if (innerBorderCornerRadius < 0) {
                innerBorderCornerRadius = 0;
            }
            // 绘制圆角边框
            // 第一个参数:上下文,第二个参数:矩形区域,第三个参数:圆角半径
            CGContextAddArcForRect(ctx, innerBorderRect, innerBorderCornerRadius);
            // 最内层边框的颜色
            CGContextSetStrokeColorWithColor(ctx, innerBorderColor.CGColor);
            // 最内层边框宽度
            CGContextSetLineWidth(ctx, innerBorderWidth);
        }];
  
    } else {
        [logoImage drawInRect:logoImageRect];
    }
    
    // 渲染
    CGContextStrokePath(ctx);
    
    // 获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    return final_image;
}

// 生成普通条形码
+ (UIImage *)generateBarCodeByString:(NSString *)text barSize:(CGSize)size {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *barcodeImage = [filter outputImage];

    // 消除模糊
    CGFloat scaleX = size.width / barcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = size.height / barcodeImage.extent.size.height;
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    return [UIImage imageWithCIImage:transformedImage];
}

// 生成普彩色条形码
+ (UIImage *)generateColorBarCodeByString:(NSString *)text barSize:(CGSize)size barColor:(CIColor *)barColor backgroundColor:(CIColor *)backgroundColor{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *barcodeImage = [filter outputImage];
    barcodeImage = [self colorImage:barcodeImage backgroundColor:backgroundColor qrColor:barColor];
    // 消除模糊
    CGFloat scaleX = size.width / barcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = size.height / barcodeImage.extent.size.height;
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    return [UIImage imageWithCIImage:transformedImage];
}

#pragma private

// 生成二维码CIImage类型的图片
+ (CIImage *)generatateQRCIImageWithString:(NSString *)text {
    // 创建滤镜对象
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 恢复滤镜的默认属性
    [qrFilter setDefaults];
    // 设置数据
    NSString *info = text;
    // 将字符串转换成
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    // 通过kvo方式给一个字符串，生成二维码
    [qrFilter setValue:infoData forKeyPath:@"inputMessage"];
    // 设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 获得滤镜输出的图像（拿到二维码图片）
    CIImage *outputImage = [qrFilter outputImage];
    return outputImage;
}

/** 根据CIImage生成指定大小的UIImage */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image qrWidth:(CGFloat)qrWidth {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(qrWidth/CGRectGetWidth(extent), qrWidth/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    // width：图片宽度像素
    // height：图片高度像素
    // bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
    // bitmapInfo：指定的位图应该包含一个alpha通道。
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (CIImage *)colorImage:(CIImage *)outputImage backgroundColor:(CIColor *)backgroundColor qrColor:(CIColor *)qrColor {
    // 创建彩色过滤器(彩色的用的不多)
    CIFilter * color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    // 设置默认值
    [color_filter setDefaults];
    // KVC 给私有属性赋值
    [color_filter setValue:outputImage forKey:@"inputImage"];
    // 需要使用 CIColor
    [color_filter setValue:backgroundColor forKey:@"inputColor0"];
    [color_filter setValue:qrColor forKey:@"inputColor1"];
    // 设置输出
    outputImage = [color_filter outputImage];
    return outputImage;
}

// 绘制圆角矩形,这个方法类似于UIBezierPath的-bezierPathWithRoundedRect:cornerRadius:方法，之所以不用贝塞尔的这个方法直接绘制，是因为这个方法存在弊端，比如一个边长为200的正方形，按理是当半径设置为100时才是一个彻底的圆，然而事实上确是：半径在66～100之间，都是一个彻底圆，小于66时才是一个非整圆的圆角矩形;并非我们想的达到边长一半时才是整圆
void CGContextAddArcForRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius) {
    if (cornerRadius > MIN(rect.size.width, rect.size.height)*0.5) {
        cornerRadius = MIN(rect.size.width, rect.size.height)*0.5;
    }
    // 保存图形上下文栈,目的是保证本次设置的样式对以后的绘制不产生影响
    CGContextSaveGState(ctx);
    // 平移转换
    CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
    // 从右边的某个点开始
    CGContextMoveToPoint(ctx, rect.size.width, rect.size.height*0.5);
    // (x1,y1)为右下角,(x2,y2)为底部某个点,这两个点与起点构成右下角的一段圆弧
    CGContextAddArcToPoint(ctx, rect.size.width, rect.size.height, rect.size.width*0.5, rect.size.height, cornerRadius);
    // (x1,y1)为左下角,(x2,y2)为左边某个点,这两个点与上段圆弧的终点构成左下角的一段圆弧
    CGContextAddArcToPoint(ctx, 0, rect.size.height, 0, rect.size.height*0.5, cornerRadius);
    // (x1,y1)为左上角,(x2,y2)为顶部边某个点,这两个点与上段圆弧的终点构成左上角的一段圆弧
    CGContextAddArcToPoint(ctx, 0, 0, rect.size.width*0.5, 0, cornerRadius);
    // (x1,y1)为右上角,(x2,y2)为右边某个点,这两个点与上段圆弧的终点构成右上角的一段圆弧
    CGContextAddArcToPoint(ctx, rect.size.width, 0, rect.size.width, rect.size.height*0.5, cornerRadius);
    // 闭合路径
    CGContextClosePath(ctx);
    // 出栈
    CGContextRestoreGState(ctx);
}

+ (void)getValueFromDictionary:(NSDictionary *)set completeBlock:(void(^)(CGFloat cornerRadius,CGFloat borderWidth,UIColor *borderColor,CGFloat outerBorderWidth,UIColor *outerBorderColor,CGFloat innerBorderWidth,UIColor *innerBorderColor, CGSize shadowOffset))completeBlock {
    
    CGFloat cornerRadius = 0;
    CGFloat borderWidth = 0;
    UIColor *borderColor = nil;
    CGFloat outerBorderWidth = 0;
    UIColor *outerBorderColor = nil;
    CGFloat innerBorderWidth = 0;
    UIColor *innerBorderColor = nil;
    CGSize shadowOffset = CGSizeZero;

    if (set[SPLogoImageCornerRadiusName] != nil) {
        if ([set[SPLogoImageCornerRadiusName] respondsToSelector:@selector(floatValue)]) {
            cornerRadius = [set[SPLogoImageCornerRadiusName] floatValue];
        } else {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageCornerRadiusName的值应该为数值类型,eg,float,double..." userInfo:nil];
            [excp raise];
        }
    }
    if (set[SPLogoImageBorderWidthName] != nil) {
        if ([set[SPLogoImageBorderWidthName] respondsToSelector:@selector(floatValue)]) {
            borderWidth = [set[SPLogoImageBorderWidthName] floatValue];
        } else {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageBorderWidthName的值应该为数值类型,eg,float,double..." userInfo:nil];
            [excp raise];
        }
    }
    if (set[SPLogoImageBorderColorName] != nil) {
        if (![set[SPLogoImageBorderColorName] isKindOfClass:[UIColor class]]) {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageBorderColorName的值应该为UIColor" userInfo:nil];
            [excp raise];
        } else {
            borderColor = set[SPLogoImageBorderColorName];
        }
    }
    if (set[SPLogoImageOuterBorderWidthName] != nil) {
        if ([set[SPLogoImageOuterBorderWidthName] respondsToSelector:@selector(floatValue)]) {
            outerBorderWidth = [set[SPLogoImageOuterBorderWidthName] floatValue];
        } else {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageOuterBorderWidthName的值应该为数值类型,eg,float,double..." userInfo:nil];
            [excp raise];
        }
    }
    if (set[SPLogoImageOuterBorderColorName] != nil) {
        if (![set[SPLogoImageOuterBorderColorName] isKindOfClass:[UIColor class]]) {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageOuterBorderColorName的值应该为UIColor" userInfo:nil];
            [excp raise];
        } else {
            outerBorderColor = set[SPLogoImageOuterBorderColorName];
        }
    }
    if (set[SPLogoImageInnerBorderWidthName] != nil) {
        if ([set[SPLogoImageInnerBorderWidthName] respondsToSelector:@selector(floatValue)]) {
            innerBorderWidth = [set[SPLogoImageInnerBorderWidthName] floatValue];
        } else {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageInnerBorderWidthName的值应该为数值类型,eg,float,double..." userInfo:nil];
            [excp raise];
        }
    }
    if (set[SPLogoImageInnerBorderColorName] != nil) {
        if (![set[SPLogoImageInnerBorderColorName] isKindOfClass:[UIColor class]]) {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageInnerBorderColorName的值应该为UIColor类型" userInfo:nil];
            [excp raise];
        } else {
            innerBorderColor = set[SPLogoImageInnerBorderColorName];
        }
    }
    if (set[SPLogoImageShadowOffsetName] != nil) {
        if ([set[SPLogoImageShadowOffsetName] respondsToSelector:@selector(CGSizeValue)]) {
            shadowOffset = [set[SPLogoImageShadowOffsetName] CGSizeValue];
        } else {
            NSException *excp = [NSException exceptionWithName:@"字典的value值类型错误" reason:@"SPLogoImageShadowOffsetName的值应该为数值类型,eg,float,double..." userInfo:nil];
            [excp raise];
        }
    }
    if (completeBlock) {
    completeBlock(cornerRadius,borderWidth,borderColor,outerBorderWidth,outerBorderColor,innerBorderWidth,innerBorderColor,shadowOffset);
    }
}

@end

NSDictionary *defaultDic(void) {
    return @{SPLogoImageCornerRadiusName:@10,
             SPLogoImageBorderWidthName:@5,
             SPLogoImageBorderColorName:[UIColor whiteColor],
             SPLogoImageOuterBorderWidthName:@0,
             SPLogoImageOuterBorderColorName:[UIColor grayColor],
             SPLogoImageInnerBorderWidthName:@1,
             SPLogoImageInnerBorderColorName:[UIColor grayColor],
             SPLogoImageShadowOffsetName:@(CGSizeMake(0, 3))
             };
}




