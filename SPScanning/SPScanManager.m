//
//  SPScanManager.m
//  SPScanManager
//
//  Created by leshengping on 2017/12/7.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "SPScanManager.h"

@interface SPScanManager() <AVCaptureMetadataOutputObjectsDelegate,AVCapturePhotoCaptureDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    BOOL bNeedScanResult; // 为了禁止拍照也走扫描的代理方法，用这个属性作为禁止标记
}
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
#pragma clang diagnostic pop
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
#pragma clang diagnostic pop
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
// 扫码区域
@property (nonatomic, assign) CGRect cropRect;
// 扫码结果数组
@property (nonatomic, strong) NSMutableArray<SPScanResult *> *arrayResult;
// 扫码类型
@property (nonatomic, strong) NSArray *arrayBarCodeType;
// 预览视图
@property (nonatomic,weak) UIView *preView;
// 扫描完成的回调
@property(nonatomic,copy)void (^blockScanResult)(NSArray<SPScanResult*> *array);
@end

@implementation SPScanManager

static SPScanManager *_instance;

+ (instancetype)sharedScanManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - public

- (void)scanWithPreView:(UIView *)preView cropRect:(CGRect)cropRect objectType:(NSArray *)objType completed:(void (^)(NSArray<SPScanResult *> *))completedBlock {
    [self configureWithPreView:preView cropRect:cropRect objectType:objType sessionPreset:nil videoGravit:nil completed:completedBlock];
}


- (void)scanWithPreView:(UIView *)preView
                       cropRect:(CGRect)cropRect
                     objectType:(NSArray*)objType
                  sessionPreset:(AVCaptureSessionPreset)sessionPreset
                    videoGravit:(AVLayerVideoGravity)videoGravit
                      completed:(void(^)(NSArray<SPScanResult *> *array))completedBlock {
    [self configureWithPreView:preView cropRect:cropRect objectType:objType sessionPreset:sessionPreset videoGravit:videoGravit completed:completedBlock];
}

- (void)configureWithPreView:(UIView *)preView
                       cropRect:(CGRect)cropRect
                     objectType:(NSArray*)objType
                  sessionPreset:(AVCaptureSessionPreset)sessionPreset
                    videoGravit:(AVLayerVideoGravity)videoGravit
                      completed:(void(^)(NSArray<SPScanResult *> *array))completedBlock {
    
    self.arrayBarCodeType = objType;
    self.blockScanResult = completedBlock;
    self.preView = preView;
    self.cropRect = cropRect;
    
    // 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        return;
    }
    
    // 创建设备输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!deviceInput) {
        return;
    }
    _deviceInput = deviceInput;
    // 创建设备输出流（用于扫码）
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _metadataOutput = metadataOutput;
    // 创建设备输出流（用于拍照）
    NSString *imageFormat = nil;
    if (@available(iOS 11.0, *)) {
        imageFormat = AVVideoCodecTypeJPEG;
    } else {
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        imageFormat = AVVideoCodecJPEG;
#pragma clang diagnostic pop
    }
    if (@available(iOS 10.0, *)) {
        AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
        _photoOutput = photoOutput;
    } else {
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        imageFormat, AVVideoCodecKey,
                                        nil];
        [stillImageOutput setOutputSettings:outputSettings];
        _stillImageOutput = stillImageOutput;
    }
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    bNeedScanResult = YES;
    
    // 创建会话对象
    _session = [[AVCaptureSession alloc] init];
    // 设置图像输出分辨率,通俗讲就是画面质量
    if (!sessionPreset) { // 如果参数sessionPreset为空，默认采用高分辨率
        sessionPreset = AVCaptureSessionPresetHigh;
    }
    if ([_session canSetSessionPreset:sessionPreset]) {
        [_session setSessionPreset:sessionPreset];  // 设置输出分辨率
    }
    // 添加输入流到会话对象
    if ([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
    }
    // 添加输出流到会话对象
    if ([_session canAddOutput:metadataOutput]) {
        [_session addOutput:metadataOutput];     // 扫码
    }
    if ([_session canAddOutput:_photoOutput]) {
        [_session addOutput:_photoOutput];       // 拍照
    }
    if ([_session canAddOutput:videoOutput]) { // 用于获取光线亮度
        [_session addOutput:videoOutput];
    }
    
    // 如果编码格式为空，使用默认编码格式
    if (!objType) {
        objType = [self defaultMetaDataObjectTypes];
    }
    // 设置扫码支持的编码格式
    metadataOutput.metadataObjectTypes = objType;
    
    // 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];

    // 设置填充模式
    _previewLayer.videoGravity = videoGravit;

    CGSize size = [preView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        // 设置frame
        _previewLayer.frame = (CGRect){{0,0},size};
    } else {
        [preView layoutIfNeeded];
        _previewLayer.frame = preView.bounds;
    }
    // 添加预览图层
    [preView.layer insertSublayer:_previewLayer atIndex:0];
    
    // 进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        // 修改设备属性前,先锁定,再解锁，防止多处同时修改
        [deviceInput.device lockForConfiguration:nil];
        // 设置对焦模式
        [deviceInput.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        // 解锁
        [deviceInput.device unlockForConfiguration];
    }
    
    // 设置有效扫描区域
    [self coverToMetadataOutputRectOfInterestForRect:cropRect];
}

// 此方法类似于系统的metadataOutputRectOfInterestForRect
- (void)coverToMetadataOutputRectOfInterestForRect:(CGRect)cropRect {
    if (CGRectEqualToRect(cropRect, CGRectZero)) {
        return;
    }
    CGSize size = _previewLayer.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 0.0;

    if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        p2 = 1920./1080.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset352x288]) {
        p2 = 352./288.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        p2 = 960./540.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetHigh]) {
        p2 = 1920./1080.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetMedium]) {
        p2 = 480./360.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetLow]) {
        p2 = 192./144.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) { // 暂时未查到具体分辨率，但是在iPhone6s中可以推导出分辨率的比例为4/3，其余真机还未测试
         p2 = 4./3.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPresetInputPriority]) {
        p2 = 1920./1080.;
    }
    else if (@available(iOS 9.0, *)) {
        if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
            p2 = 3840./2160.;
        }
    } else {
        
    }
    if ([_previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize]) {
        _metadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y)/size.height,(size.width-(cropRect.size.width+cropRect.origin.x))/size.width, cropRect.size.height/size.height,cropRect.size.width/size.width);
    } else if ([_previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (p1 < p2) {
            CGFloat fixHeight = size.width * p2;
            CGFloat fixPadding = (fixHeight - size.height)/2;
            _metadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                        cropRect.size.height/fixHeight,
                                                        cropRect.size.width/size.width);
        } else {
            CGFloat fixWidth = size.height * (1/p2);
            CGFloat fixPadding = (fixWidth - size.width)/2;
            _metadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                        cropRect.size.height/size.height,
                                                        cropRect.size.width/fixWidth);
        }
    } else if ([_previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (p1 > p2) {
            CGFloat fixHeight = size.width * p2;
            CGFloat fixPadding = (fixHeight - size.height)/2;
            _metadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                        cropRect.size.height/fixHeight,
                                                        cropRect.size.width/size.width);
        } else {
            CGFloat fixWidth = size.height * (1/p2);
            CGFloat fixPadding = (fixWidth - size.width)/2;
            _metadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                        (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                        cropRect.size.height/size.height,
                                                        cropRect.size.width/fixWidth);
        }
    }
}

// 开启扫描
- (void)startScan {
    if (_deviceInput && !_session.running) {
        [_session startRunning];
        bNeedScanResult = YES;
    }
    bNeedScanResult = YES;
}

// 停止扫描
- (void)stopScan {
    bNeedScanResult = NO;
    if (_deviceInput && _session.running) {
        [_session stopRunning];
        bNeedScanResult = NO;
    }
}

- (void)updatePreViewLayerFrame {
    
    self.previewLayer.frame = self.preView.bounds;
    // 特别要注意的是previewLayer的frame改变后，需要重新置videoGravity属性
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 重新设置有效扫描区域
    [self coverToMetadataOutputRectOfInterestForRect:_cropRect];
}

#pragma mark - setter
// 是否需要拍照
- (void)setNeedCaptureImage:(BOOL)needCaptureImage {
    _needCaptureImage = needCaptureImage;
}

// 设置扫码支持的类型
- (void)setObjTypes:(NSArray *)objTypes {
    _objTypes = objTypes;
    _metadataOutput.metadataObjectTypes = objTypes;
}

// 设置镜头拉近拉远系数
- (void)setVideoScale:(CGFloat)videoScale {
    
    [_deviceInput.device lockForConfiguration:nil];
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.stillImageOutput connections]];
    if (videoScale <= 0) {
        _videoScale = videoConnection.videoMaxScaleAndCropFactor;
    } else {
        _videoScale = videoScale;
    }
    CGFloat zoom = videoScale / videoConnection.videoScaleAndCropFactor;
    videoConnection.videoScaleAndCropFactor = videoScale;
    [_deviceInput.device unlockForConfiguration];
    CGAffineTransform transform = _preView.transform;
    _preView.transform = CGAffineTransformScale(transform, zoom, zoom);
}

// 开关手电筒
- (void)setTorchOn:(BOOL)torchOn {
    _torchOn = torchOn;
    // 获取当前设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 不要用这种方式获取设备，因为如果没有开启相机权限，self.deviceInput为nil，从而导致获取的device也是nil
    //AVCaptureDevice *device = self.deviceInput.device;
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: torchOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

// 识别二维码图片
+ (void)recognizeImage:(UIImage *)image success:(void (^)(NSArray<SPScanResult *> *))block {
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray<SPScanResult *> *mutableArray = [[NSMutableArray alloc]initWithCapacity:1];
    for (int index = 0; index < features.count; index ++){
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        SPScanResult *item = [[SPScanResult alloc]init];
        item.strScanned = scannedResult;
        item.strBarCodeType = CIDetectorTypeQRCode;
        item.imgScanned = image;
        [mutableArray addObject:item];
    }
    if (block) {
        block(mutableArray);
    }
}

// 默认支持码的类别
- (NSArray *)defaultMetaDataObjectTypes {
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_0) {
        [types addObjectsFromArray:@[
                                     AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    }
    return types;
}

// 拍照
- (void)captureImage {
    if (@available(iOS 10.0, *)) {
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}];
        [photoSettings setFlashMode:self.torchOn];
        [_photoOutput capturePhotoWithSettings:photoSettings delegate:self];
    } else {
        AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.stillImageOutput connections]];
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
             [self stopScan];
    
             if (imageDataSampleBuffer) {
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 UIImage *img = [UIImage imageWithData:imageData];
                 for (SPScanResult *result in self.arrayResult) {
                     result.imgScanned = img;
                 }
             }
             if (self.blockScanResult) {
                 self.blockScanResult(self.arrayResult);
             }
         }];
    }
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!bNeedScanResult) {
        return;
    }
    bNeedScanResult = NO;
    if (!_arrayResult) {
        self.arrayResult = [NSMutableArray arrayWithCapacity:1];
    } else {
        [_arrayResult removeAllObjects];
    }
    // 识别扫码类型
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            bNeedScanResult = NO;
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *)current stringValue];
            if (scannedResult && ![scannedResult isEqualToString:@""]) {
                SPScanResult *result = [SPScanResult new];
                result.strScanned = scannedResult;
                result.strBarCodeType = current.type;
                [_arrayResult addObject:result];
            }
            // 测试可以同时识别多个二维码
        }
    }
    if (_needCaptureImage) {
        [self captureImage];
    } else {
        [self stopScan];
        if (self.blockScanResult) {
            self.blockScanResult(_arrayResult);
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    if ([self.delegate respondsToSelector:@selector(scanManagerBrightnessValueDidChanged:)]) {
        [self.delegate scanManagerBrightnessValueDidChanged:brightnessValue];
    }
}
                           

#pragma mark - AVCapturePhotoCaptureDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error {
    
    [self stopScan];
    
    if (photoSampleBuffer) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:photoSampleBuffer];
        UIImage *img = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
        for (SPScanResult *result in self.arrayResult) {
            result.imgScanned = img;
        }
    }
    if (self.blockScanResult) {
        self.blockScanResult(_arrayResult);
    }
}
#pragma clang diagnostic pop

- (void)dealloc {
    NSLog(@"scanManager销毁");
}
@end














