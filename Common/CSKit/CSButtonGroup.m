// CSButtonGroup.m
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

#import "CSButtonGroup.h"

@interface CSButtonGroup() {
    NSMutableOrderedSet* _btns;
}

@end

@implementation CSButtonGroup
@synthesize selectedIndex = _selectedIndex;

- (id)init {
    if (self = [super init]) {
        _selectedIndex = -1;
        _btns = [[NSMutableOrderedSet alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    for (UIButton* btn in _btns) {
        [self __releaseButton:btn];
    }
}

- (void)addButton:(UIButton*)btn {
    if (btn && ![_btns containsObject:btn]) {
        [_btns addObject:btn];
        [self __initButton:btn];
    }
}

- (void)addButtonsFromArray:(NSArray *)array {
    for (UIButton* btn in array) {
        [self addButton:btn];
    }
}

- (void)insertButton:(UIButton*)btn atIndex:(NSInteger)index {
    if (btn && ![_btns containsObject:btn]) {
        [_btns insertObject:btn atIndex:index];
        [self __initButton:btn];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= 0 && selectedIndex < _btns.count) {
        _selectedIndex = selectedIndex;
        UIButton* btn = [_btns objectAtIndex:selectedIndex];
        btn.selected = YES;
    }
    else {
        UIButton* btn = [_btns objectAtIndex:_selectedIndex];
        btn.selected = NO;
    }
}

- (UIButton*)buttonAtIndex:(NSInteger)index {
    UIButton* btn = nil;
    if (index >=0 && index < _btns.count) {
        btn = [_btns objectAtIndex:index];
    }
    return btn;
}

- (void)__initButton:(UIButton*)btn {
    btn.selected = NO;
    [btn addTarget:self action:@selector(__onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)__releaseButton:(UIButton*)btn {
    [btn removeTarget:self action:@selector(__onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn removeObserver:self forKeyPath:@"selected" context:nil];
}

- (void)__onBtnClicked:(UIButton*)btn {
    NSInteger btnIndex = [_btns indexOfObject:btn];
    if (btnIndex != NSNotFound && btnIndex!=_selectedIndex) {
        BOOL shouldSelect = YES;
        if ([_delegate respondsToSelector:@selector(buttonGroup:shouldSelectButtonAtIndex:)]) {
            shouldSelect = [_delegate buttonGroup:self
                      shouldSelectButtonAtIndex:btnIndex];
        }
        
        if (shouldSelect) {
            NSInteger preSelectedIndex = _selectedIndex;
            _selectedIndex = btnIndex;
            
            if (preSelectedIndex >=0 && preSelectedIndex <_btns.count) {
                UIButton* preSelectedBtn = [_btns objectAtIndex:preSelectedIndex];
                preSelectedBtn.selected = NO;
            }
            
            btn.selected = YES;

            if ([_delegate respondsToSelector:@selector(buttonGroup:didSelectButtonAtIndex:)]) {
                [_delegate buttonGroup:self didSelectButtonAtIndex:_selectedIndex];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"selected"] && [object isKindOfClass:[UIButton class]]) {
        UIButton* btn = object;
         NSInteger btnIndex = [_btns indexOfObject:btn];
        if (btnIndex != NSNotFound) {
            NSInteger preSelectedIndex = _selectedIndex;
            
            if (btn.selected && btnIndex != _selectedIndex) {
                _selectedIndex = btnIndex;
                if (preSelectedIndex >=0 && preSelectedIndex <_btns.count)  {
                    UIButton* preSelectedBtn = [_btns objectAtIndex:preSelectedIndex];
                    preSelectedBtn.selected = NO;
                }
            }
            else if (!btn.selected && btnIndex == _selectedIndex) {
                _selectedIndex = -1;
            }
        }
    }
}

- (void)clear {
    for (UIButton* btn in [self buttons]) {
        btn.selected = NO;
    }
    _selectedIndex = -1;
}

- (NSArray*)buttons {
    NSArray* btns = nil;
    if (_btns.count > 0) {
        btns = [_btns array];
    }
    return btns;
}

@end
