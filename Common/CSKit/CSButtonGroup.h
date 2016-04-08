// CSButtonGroup.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CSButtonGroup;

@protocol CSButtonGroupDelegate <NSObject>

@optional
- (void)buttonGroup:(CSButtonGroup*)btnGroup didSelectButtonAtIndex:(NSInteger)selectedIndex;
- (BOOL)buttonGroup:(CSButtonGroup*)btnGroup shouldSelectButtonAtIndex:(NSInteger)index;

@end


@interface CSButtonGroup : NSObject
@property (nonatomic, weak) id<CSButtonGroupDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;

- (void)addButton:(UIButton*)btn;
- (void)addButtonsFromArray:(NSArray *)array;
- (void)insertButton:(UIButton*)btn atIndex:(NSInteger)index;
- (void)setSelectedIndex:(NSInteger)selectedIndex;
- (UIButton*)buttonAtIndex:(NSInteger)index;
- (void)clear;
- (NSArray*)buttons;

@end

