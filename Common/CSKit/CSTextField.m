// CSTextField.m
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

#import "CSTextField.h"

@implementation CSTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)borderRectForBounds:(CGRect)bounds {
    return [super borderRectForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect superRect = [super textRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(superRect, self.textInsets);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect superRect = [super placeholderRectForBounds:bounds];
    return superRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect superRect = [super editingRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(superRect, self.textInsets);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    return [super clearButtonRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return [super leftViewRectForBounds:bounds];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    return [super rightViewRectForBounds:bounds];
}

@end
