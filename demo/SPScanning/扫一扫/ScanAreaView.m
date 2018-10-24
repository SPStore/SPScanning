//
//  FFScanAreaView.m
//  FashionFox
//
//  Created by develop1 on 2018/10/23.
//  Copyright © 2018 iDress. All rights reserved.
//

#import "ScanAreaView.h"

@interface ScanAreaView()
@property (nonatomic, weak) UIImageView *scanImageViewLeftTop;
@property (nonatomic, weak) UIImageView *scanImageViewRightTop;
@property (nonatomic, weak) UIImageView *scanImageViewLeftBottom;
@property (nonatomic, weak) UIImageView *scanImageViewRightBottom;
@end

@implementation ScanAreaView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        UIImageView *scanImageViewLeftTop = [[UIImageView alloc] init];
        scanImageViewLeftTop.image = [UIImage imageNamed:@"ScanQR1"];
        [self addSubview:scanImageViewLeftTop];
        _scanImageViewLeftTop = scanImageViewLeftTop;

        UIImageView *scanImageViewRightTop = [[UIImageView alloc] init];
        scanImageViewRightTop.image = [UIImage imageNamed:@"ScanQR2"];
        [self addSubview:scanImageViewRightTop];
        _scanImageViewRightTop = scanImageViewRightTop;

        UIImageView *scanImageViewLeftBottom = [[UIImageView alloc] init];
        scanImageViewLeftBottom.image = [UIImage imageNamed:@"ScanQR3"];
        [self addSubview:scanImageViewLeftBottom];
        _scanImageViewLeftBottom = scanImageViewLeftBottom;

        UIImageView *scanImageViewRightBottom = [[UIImageView alloc] init];
        scanImageViewRightBottom.image = [UIImage imageNamed:@"ScanQR4"];
        [self addSubview:scanImageViewRightBottom];
        _scanImageViewRightBottom = scanImageViewRightBottom;

        UIImageView *scanAnimationImageView = [[UIImageView alloc] init];
        scanAnimationImageView.image = [UIImage imageNamed:@"ff_QRCodeScanLine"];
        [self addSubview:scanAnimationImageView];
        _scanAnimationImageView = scanAnimationImageView;
    }
    return self;
}

- (void)performAnimation {
    CAAnimation *anim = [_scanAnimationImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanAnimationImageView.layer.timeOffset;
        // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;

        // 3. 要把偏移时间清零
        [_scanAnimationImageView.layer setTimeOffset:0.0];
        // 4. 设置图层的开始动画时间
        [_scanAnimationImageView.layer setBeginTime:beginTime];

        [_scanAnimationImageView.layer setSpeed:1.0];

    } else{

        CGFloat c_width = self.bounds.size.width;
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(c_width);
        scanNetAnimation.duration = 2.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanAnimationImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    CGFloat corWidth = 16;
    _scanImageViewLeftTop.frame = CGRectMake(0, 0, corWidth, corWidth);
    _scanImageViewRightTop.frame = CGRectMake(width-corWidth, 0, corWidth, corWidth);
    _scanImageViewLeftBottom.frame = CGRectMake(0, height-corWidth, corWidth, corWidth);
    _scanImageViewRightBottom.frame = CGRectMake(width-corWidth, height-corWidth, corWidth, corWidth);

    _scanAnimationImageView.frame = CGRectMake(-50, 0, width+100, 12);
}

@end
