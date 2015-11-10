// UIButton+Countdown.m
//
// Copyright (c) 2014-2015 Xinus Wang. All rights reserved.
// https://github.com/xinus/CSKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIButton+Countdown.h"
#import <objc/runtime.h>

@implementation UIButton(Countdown)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSDate*)timerDate {
    NSDate* c = objc_getAssociatedObject(self, @selector(timerDate));
    return c;
}

- (void)setTimerDate:(NSDate*)date {
    objc_setAssociatedObject(self, @selector(timerDate), date, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)counter {
    NSNumber* c = objc_getAssociatedObject(self, @selector(counter));
    return c.integerValue;
}

- (void)setCounter:(NSInteger)counter {
    NSNumber* c =  @(counter);
    objc_setAssociatedObject(self, @selector(counter), c, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(NSInteger))timerHandler {
    void(^handler)(NSInteger);
    handler = objc_getAssociatedObject(self, @selector(timerHandler));
    return handler;
}

-(void)setTimerHandler:(void(^)(NSInteger))handler {
    objc_setAssociatedObject(self, @selector(timerHandler), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(void))completeHandler {
    void(^handler)(void);
    handler = objc_getAssociatedObject(self, @selector(completeHandler));
    return handler;
}

-(void)setCompleteHandler:(void(^)(void))handler {
    objc_setAssociatedObject(self, @selector(completeHandler), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSTimer*)timer {
    NSTimer* t1 = objc_getAssociatedObject(self, @selector(timer));
    return t1;
}

- (void)setTimer:(NSTimer*)t {
    NSTimer* t1 = objc_getAssociatedObject(self, @selector(timer));
    if (t1) {
        [t1 invalidate];
    }
    
    if (t) {
        objc_setAssociatedObject(self, @selector(timer), t, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)onTimer:(NSTimer*)timer {
    NSTimeInterval duration = [self.timerDate timeIntervalSinceNow];
    
    NSInteger left = round(self.counter + duration);
    
    void(^timerHandler)(NSInteger);
    void(^completeHandler)(void);
    
    timerHandler = self.timerHandler;
    completeHandler = self.completeHandler;
    
    if (timerHandler) {
        timerHandler(left);
    }
    
    if (left <=0 && completeHandler) {
        [timer invalidate];
        self.timerDate = nil;
        self.timer = nil;
        completeHandler();
    }
}

- (void)startTimer:(NSInteger)count
          callback:(void(^)(NSInteger))hander
           timeout:(void(^)(void))complete {
    self.counter = count;
    self.completeHandler = complete;
    self.timerHandler = hander;
    self.timerDate = [NSDate date];
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)stopTimer {
    
}

@end
