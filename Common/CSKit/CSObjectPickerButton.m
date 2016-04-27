// CSObjectPickerButton.h
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

#import "CSObjectPickerButton.h"
#import "CSInputAccessoryView.h"
#import "CSPickerItemProtocol.h"

@interface CSObjectPickerButton () <UIPickerViewDataSource, UIPickerViewDelegate> {
    CSInputAccessoryView* _navigationAccessoryView;
}

@property (nonatomic, strong) UIPickerView* pickerView;

@end

@implementation CSObjectPickerButton
@synthesize pickerView = _pickerView;
@synthesize currentItem = _currentItem;
@synthesize pickerItems = _pickerItems;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)setCurrentItem:(id)currentItem {
    _currentItem = currentItem;
    [self updateLabels];
    [self.pickerView reloadAllComponents];
}

- (void)setPickerItems:(NSArray *)pickerItems {
    _pickerItems = pickerItems;
    [self.pickerView reloadAllComponents];
}

- (BOOL)canBecomeFirstResponder {
    return self.pickerItems.count > 0;
}

- (UIPickerView*)pickerView {
    if (_pickerView == nil) {
        _pickerView = [UIPickerView new];
        _pickerView.translatesAutoresizingMaskIntoConstraints = NO;
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    
    return _pickerView;
}

- (void)updateLabels {
    if (self.currentItem) {
        [self setTitle:[self itemText:self.currentItem] forState:UIControlStateNormal];
    }
    else {
        if (self.defaultLabelText) {
            [self setTitle:self.defaultLabelText forState:UIControlStateNormal];
        }
        else {
            [self setTitle:@"请选择" forState:UIControlStateNormal];
        }
    }
}

- (UIView*)inputView {
    if (self.currentItem) {
        NSUInteger index = [self.pickerItems indexOfObject:self.currentItem];
        if (index != NSNotFound) {
            [self.pickerView selectRow:index inComponent:0 animated:NO];
        }
    }
    else {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }

    return self.pickerView;
}

- (UIView*)inputAccessoryView {
    if (_navigationAccessoryView == nil) {
        _navigationAccessoryView = [CSInputAccessoryView new];
        _navigationAccessoryView.doneButton.target = self;
        _navigationAccessoryView.doneButton.action = @selector(rowNavigationDone:);
        _navigationAccessoryView.tintColor = self.tintColor;
    }
    
    return _navigationAccessoryView;
}

- (void)rowNavigationDone:(id)sender {
    NSInteger index = [self.pickerView selectedRowInComponent:0];
    self.currentItem = [self.pickerItems objectAtIndex:index];
    [self updateLabels];
    [self resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(objectPickerButton:didSelectedItemChanged:)]) {
        [self.delegate objectPickerButton:self didSelectedItemChanged:index];
    }
}

- (NSString*)itemText:(id)item {
    NSString* text = @"undefined";
    if ([item isKindOfClass:[NSString class]]) {
        text = item;
    }
    else if ([item conformsToProtocol:@protocol(CSPickerItemProtocol)]) {
        text = [item itemDisplayText];
    }
    else if ([item respondsToSelector:@selector(itemDisplayText)]) {
        text = [item itemDisplayText];
    }
    else {
        text = [item description];
    }
    
    return text;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id item = [self.pickerItems objectAtIndex:row];
    NSString* text = [self itemText:item];
    
    return text;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerItems.count;
}

@end
