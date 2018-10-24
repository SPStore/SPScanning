//
//  FFCodeReaderView.m
//  FashionFox
//
//  Created by develop1 on 2018/10/19.
//  Copyright © 2018 iDress. All rights reserved.
//

#import "CodeReaderView.h"
#import <QuartzCore/QuartzCore.h>

@interface CodeReaderView ()
{
    __weak id<CodeReaderViewDelegate> delegate;
    CGRect       innerViewRect;
}
@property (nonatomic, strong) CAShapeLayer *overlay;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation CodeReaderView
@synthesize innerViewRect,delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupLayers];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    _shapeLayer.frame = rect;
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRect:rect];

    CGRect innerRect = CGRectInset(rect, 50.0, 50.0);

    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    if (innerRect.size.width != minSize) {
        innerRect.origin.x   += 50;
        innerRect.size.width = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y   += (ceil((rect.size.height - minSize) / 2.0 - rect.size.height / 6.0));
        innerRect.size.height = minSize;
    }
    CGRect offsetRect = CGRectOffset(innerRect, 0.0, 15.0);

    innerViewRect = offsetRect;
    if(delegate){
        [delegate codeReaderViewDrawRect:innerViewRect];
    }
    // 扫描区域的白线边框，之所以内缩0.4，是要让白线的边框的最外缘对齐扫描区域，否则则是白线边框的中心对齐扫描区域
    UIBezierPath *innerPath    = [UIBezierPath bezierPathWithRect:CGRectInset(innerViewRect, 0.4, 0.4)];
    _overlay.path = innerPath.CGPath;

    [outerPath appendPath:[innerPath bezierPathByReversingPath]]; // innerPath先取逆向路径，再拼接路径
    _shapeLayer.path = outerPath.CGPath;

}

#pragma mark - Private Methods

- (void)setupLayers {
    _overlay = [[CAShapeLayer alloc] init];
    _overlay.backgroundColor = [UIColor redColor].CGColor;
    _overlay.fillColor       = [UIColor clearColor].CGColor;
    _overlay.strokeColor     = [UIColor whiteColor].CGColor;
    _overlay.lineWidth       = 0.8;
    _overlay.lineDashPattern = @[@50,@0];
    _overlay.lineDashPhase   = 1;
    _overlay.opacity         = 1;
    [self.layer addSublayer:_overlay];

    _shapeLayer   = [CAShapeLayer layer];
    _shapeLayer.fillColor       = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    _shapeLayer.strokeColor     = nil;
    _shapeLayer.opacity         = 1.0;
    [self.layer addSublayer:_shapeLayer];
}

@end
