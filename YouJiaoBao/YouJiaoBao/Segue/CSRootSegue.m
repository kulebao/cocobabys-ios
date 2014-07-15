//
//  CSRootSegue.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSRootSegue.h"

@implementation CSRootSegue

- (void)perform {
    UIViewController* source = self.sourceViewController;
    UIViewController* destination = self.destinationViewController;
    
    [source addChildViewController:destination];
    [source.view addSubview:destination.view];
    destination.view.frame = source.view.bounds;
}

@end
