// The MIT License (MIT)
//
// Copyright (c) 2013 Ivan Lisovoy, Denis Kotenko
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

static NSString *const InputValidationErrorDomain  = @"InputValidationErrorDomain";
static NSInteger const InputValidationNumericErrorCode = 1001;
static NSInteger const InputValidationAlphabetErrorCode = 1002;
static NSInteger const InputValidationEmailErrorCode = 1003;
static NSInteger const InputValidationRequiredErrorCode = 1004;
static NSInteger const InputValidationMultipleErrorCode = 1100;


@protocol LKValidator <NSObject>

+ (NSError *) errorWithReason:(NSString *)aReason code:(NSInteger)code;

@end


@interface LKValidator : NSObject <LKValidator>

@property (nonatomic, strong) NSString *reason;

+ (instancetype) validator;

- (BOOL) validateInput:(NSString *)input error:(NSError **)error;

@end
