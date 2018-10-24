//
//  FFCodeReaderView.h
//  FashionFox
//
//  Created by develop1 on 2018/10/19.
//  Copyright © 2018 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CodeReaderViewDelegate <NSObject>
- (void)codeReaderViewDrawRect:(CGRect)rect;
@end

@interface CodeReaderView : UIView
@property (nonatomic, weak)   id<CodeReaderViewDelegate> delegate;
@property (nonatomic, assign) CGRect innerViewRect;
@end

NS_ASSUME_NONNULL_END
