// CSInputAccessoryView.h
//
// Copyright (c) 2014-2016 Xinus Wang. All rights reserved.
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

#import "CSInputAccessoryView.h"

@interface CSInputAccessoryView ()

@property (nonatomic) UIBarButtonItem *fixedSpace;
@property (nonatomic) UIBarButtonItem *flexibleSpace;

@end

@implementation CSInputAccessoryView
@synthesize doneButton = _doneButton;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0)];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth);
        NSArray * items = [NSArray arrayWithObjects:
                           self.flexibleSpace,
                           self.doneButton, nil];
        [self setItems:items];
    }
    return self;
}

#pragma mark - Properties
-(UIBarButtonItem *)fixedSpace
{
    if (_fixedSpace) return _fixedSpace;
    _fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    _fixedSpace.width = 22.0;
    return _fixedSpace;
}

-(UIBarButtonItem *)flexibleSpace
{
    if (_flexibleSpace) return _flexibleSpace;
    _flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return _flexibleSpace;
}

-(UIBarButtonItem *)doneButton
{
    if (_doneButton) return _doneButton;
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
    return _doneButton;
}

#pragma mark - Helpers
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
}

@end
