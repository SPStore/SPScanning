//
//  SPScanTypes.m
//  SPScanManager
//
//  Created by leshengping on 2017/12/7.
//  Copyright © 2017年 leshengping. All rights reserved.
//

#import "SPScanResult.h"

@implementation SPScanResult

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type
{
    if (self = [super init]) {
        
        self.strScanned = str;
        self.imgScanned = img;
        self.strBarCodeType = type;
    }
    
    return self;
}

@end
