// CSPopupController.m
//
// Copyright (c) 2014 Xinus Wang. All rights reserved.
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

#import "CSPopupController.h"

@interface CSPopupController() <UIGestureRecognizerDelegate> {
    UIView* _viewContainer;
    UIView* _viewToPresent;
    
    CGRect _fromFrame;
    CGRect _toFrame;
}

@property (nonatomic, strong, readonly) UIView* maskView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) UIView* viewToPresent;

@end

@implementation CSPopupController
@synthesize maskView =_maskView;
@synthesize tapGes = _tapGes;

+ (id)popupControllerWithView:(UIView*)container {
    CSPopupController* ctrl = [[CSPopupController alloc] initWithView:container];
    
    return ctrl;
}

- (id)initWithView:(UIView*)container {
    if (self = [super init]) {
        _viewContainer = container;
    }
    
    return self;
}

- (UIView*)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:CGRectNull];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_maskView addGestureRecognizer:self.tapGes];
    }
    
    return _maskView;
}

- (UITapGestureRecognizer*)tapGes {
    if (_tapGes == nil) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapGes:)];
        _tapGes.delegate = self;
    }
    
    return _tapGes;
}

- (void)_onTapGes:(UITapGestureRecognizer*)tapGes {
    if ([tapGes.view isEqual:_maskView]) {
        CGPoint pt = [tapGes locationInView:_maskView];
        if (!CGRectContainsPoint(_viewToPresent.frame, pt)) {
            [self performSelector:@selector(_hidePop) withObject:nil];
        }
    }
}

- (void)_hidePop {
    _viewToPresent.hidden = YES;
    [_viewContainer addSubview:_viewToPresent];
    _viewToPresent = nil;
    _maskView.hidden = YES;
}

- (void)presentView:(UIView*)viewToPresent
           animated:(BOOL)flag
         completion:(void (^)(void))completion {

    CGRect toFrame = viewToPresent.frame;
    CGRect fromFrame = CGRectMake((CGRectGetMinX(toFrame) + CGRectGetMaxX(toFrame))/2,
                                  (CGRectGetMinY(toFrame) + CGRectGetMaxY(toFrame))/2,
                                  0, 0);
    
    [self presentView:viewToPresent
            fromFrame:fromFrame
              toFrame:toFrame
             animated:flag
           completion:completion];
}

- (void)presentView:(UIView*)viewToPresent
            toFrame:(CGRect)toFrame
           animated:(BOOL)flag
         completion:(void (^)(void))completion {
    viewToPresent.frame = toFrame;
    [self presentView:viewToPresent animated:flag completion:completion];
}

- (void)presentView:(UIView*)viewToPresent
          fromFrame:(CGRect)fromFrame
            toFrame:(CGRect)toFrame
           animated:(BOOL)flag
         completion:(void (^)(void))completion {
    if (viewToPresent!= nil && _viewContainer!=nil) {
        [_viewContainer addSubview:self.maskView];
        self.maskView.frame = _viewContainer.bounds;
        self.maskView.hidden = NO;
        
        _viewToPresent = viewToPresent;
        [self.maskView addSubview:_viewToPresent];
        _viewToPresent.hidden = NO;
        
        _fromFrame = fromFrame;
        _toFrame = toFrame;
        
        if (flag) {
            _viewToPresent.frame = _fromFrame;
            [UIView animateWithDuration:0.3 animations:^{
                _viewToPresent.frame = _toFrame;
            } completion:^(BOOL finished) {
                _viewToPresent.frame = _toFrame;
                if (completion) completion();
            }];
        }
        else {
            _viewToPresent.frame = _toFrame;
            if (completion) completion();
        }
    }
}

- (void)dismissAnimated:(BOOL)flag {
    [self performSelector:@selector(_hidePop) withObject:nil];
}

- (void)dismiss {
    [self dismissAnimated:NO];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL ok = NO;
    if ([gestureRecognizer.view isEqual:_maskView]) {
        CGPoint pt = [gestureRecognizer locationInView:_maskView];
        if (!CGRectContainsPoint(_viewToPresent.frame, pt)) {
            ok = YES;
        }
    }
    
    return ok;
}

@end
