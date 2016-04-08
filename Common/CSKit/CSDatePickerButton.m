// CSDatePickerButton.h
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

#import "CSDatePickerButton.h"
#import "CSInputAccessoryView.h"

@interface CSDatePickerButton () {
    CSInputAccessoryView* _navigationAccessoryView;
}

@property (nonatomic, strong) UIDatePicker* datePicker;

@end

@implementation CSDatePickerButton
@synthesize datePicker = _datePicker;
@synthesize date = _date;
@synthesize defaultLabelText = _defaultLabelText;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)setDate:(NSDate *)date {
    _date = date;
    if (_date) {
        self.datePicker.date = _date;
    }
    [self updateLabels];
}

- (void)setDefaultLabelText:(NSString *)defaultLabelText {
    _defaultLabelText = defaultLabelText;
    [self updateLabels];
}

-(UIDatePicker *)datePicker {
    if (_datePicker) return _datePicker;
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return _datePicker;
}

- (void)datePickerValueChanged:(id)sender {
}

- (void)updateLabels {
    if (self.date) {
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd";
        [self setTitle:[fmt stringFromDate:self.date] forState:UIControlStateNormal];
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
    if (self.date) {
        self.datePicker.date = self.date;
    }

    return self.datePicker;
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
    self.date = self.datePicker.date;
    [self updateLabels];
    [self resignFirstResponder];
}

@end
