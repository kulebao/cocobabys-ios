//
//  CBLoginInfo.m
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBLoginInfo.h"

@implementation CBLoginInfo

- (void)setIm_token:(CBIMInfo *)im_token {
    if ([im_token isKindOfClass:[NSDictionary class]]) {
        _im_token = [CBIMInfo instanceWithDictionary:(NSDictionary*)im_token];
    }
    else if ([im_token isKindOfClass:[CBIMInfo class]]) {
        _im_token = im_token;
    }
    else {
        CSLog(@"ERR: UNKNOWN CBIMInfo: %@", im_token);
    }
}

@end
