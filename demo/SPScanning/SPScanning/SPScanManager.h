//
//  SPScanManager.h
//  SPScanManager
//
//  Created by leshengping on 2017/12/7.
//  Copyright © 2017年 leshengping. All rights reserved.
//  扫描管理类

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SPScanResult.h"

@protocol SPScanManagerDelegate <NSObject>
@optional;
// 光线亮度(拍照画面的环境光)发生了改变
- (void)scanManagerBrightnessValueDidChanged:(float)brightnessValue;
@end

@interface SPScanManager : NSObject

+ (instancetype)sharedScanManager;

@property (nonatomic, weak) id<SPScanManagerDelegate> delegate;

/**
 @brief          初始化采集相机
 @param preView  视频显示区域
 @param scanRect 有效识别区域，CGRectZero则默认为preView的全部区域
 @param objType  识别码类型：如果为nil，默认支持很多类型。(二维码如QR：AVMetadataObjectTypeQRCode,条码如：AVMetadataObjectTypeCode93Code)
 @param completedBlock   识别结果
 */
- (void)scanWithPreView:(UIView *)preView
                       scanRect:(CGRect)scanRect
                     objectType:(NSArray *)objType
                      completed:(void(^)(NSArray<SPScanResult *> *array))completedBlock;

/**
 @brief          初始化采集相机,如果参数sessionPreset和videoGravit都为nil，则与上面的方法等效
 @param preView  视频显示区域,preView要求全屏frame,所以一般都是传控制器的view居多
 @param scanRect 有效识别区域，CGRectZero则默认为preView的全部区域
 @param objType  识别码类型：如果为nil，默认支持很多类型。(二维码如QR：AVMetadataObjectTypeQRCode,条码如：AVMetadataObjectTypeCode93Code)
 @param sessionPreset 图像、音频等输出分辨率,如果传nil，默认以高质量(AVCaptureSessionPresetHigh)分辨率输出
 @param videoGravit   输出模式，如果为nil,默认为AVLayerVideoGravityResizeAspectFill
 @param completedBlock   识别结果
 */
- (void)scanWithPreView:(UIView *)preView
                       scanRect:(CGRect)scanRect
                     objectType:(NSArray *)objType
                  sessionPreset:(AVCaptureSessionPreset)sessionPreset
                    videoGravit:(AVLayerVideoGravity)videoGravit
                        completed:(void(^)(NSArray<SPScanResult *> *array))completedBlock;

/**
 *  开始扫描
 */
- (void)startScan;

/**
 *  停止扫描
 */
- (void)stopScan;

/**
 *  更新预览视图的frame，preViewLayer的frame依赖的是preView，但是如果preView是由xib生成的，有时preView的frame是不准的，例如在控制器的viewDidLoad中就是不准的。所以以下这个方法，保证能够在恰当的时刻更新preViewLayer的frame
 */
- (void)updatePreViewLayerFrame;

/**
 *  扫码区域
 */
@property (nonatomic, assign) CGRect scanRect;


/**
 *  修改扫码类型：二维码、条形码,如:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode39Code等
 */
@property (nonatomic, strong) NSArray *objTypes;

/**
 *  是否开启闪光灯
 */
@property(nonatomic,getter=isTorchOn) BOOL torchOn;

/*!
 *  扫码成功后是否拍照
 */
@property (nonatomic, assign, getter=isNeedCaptureImage) BOOL needCaptureImage;

/**
 *  拉近拉远镜头
 */
@property (nonatomic, assign) CGFloat videoScale;


#pragma mark --识别图片
/**
 识别QR二维码图片,ios8.0以上支持
 
 @param image 图片
 @param block 返回识别结果
 */
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<SPScanResult *> *array))block;


@end





