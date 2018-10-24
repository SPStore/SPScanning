//
//  FFScanAreaView.h
//  FashionFox
//
//  Created by develop1 on 2018/10/23.
//  Copyright © 2018 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanAreaView : UIView

@property (nonatomic, weak) UIImageView *scanAnimationImageView;

- (void)performAnimation;

@end

NS_ASSUME_NONNULL_END
