// CSJsonEntityData.h
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

#import <Foundation/Foundation.h>

#define GET_DICT_OBJECT(dict, key, dest) \
if ([dict objectForKey:key]) { dest = [dict objectForKey:key]; if([dest isKindOfClass:[NSNull class]]){dest=nil;} }

#define GET_DICT_STRING(dict, key, dest) \
if ([dict objectForKey:key]) { dest = [NSString stringWithFormat:@"%@",[dict objectForKey:key]]; }

#define GET_DICT_INTEGER(dict, key, dest) \
if ([dict objectForKey:key]) { dest = [[dict objectForKey:key] integerValue]; }

#define GET_DICT_FLOAT(dict, key, dest) \
if ([dict objectForKey:key]) { dest = [[dict objectForKey:key] floatValue]; }

#define GET_LIST_OBJECT(jsonList, className, objList) \
if ([jsonList isKindOfClass:[NSArray class]]) { \
NSMutableArray* tempList = [NSMutableArray array]; \
for (NSDictionary* jsonDict in jsonList) { \
id obj = [className instanceWithDictionary:jsonDict]; \
if (obj) { \
[tempList addObject:obj]; \
} \
} \
objList = tempList; \
} \
else { \
objList = nil; \
}

@interface CSJsonEntityData : NSObject

+(instancetype)instanceWithDictionary:(NSDictionary*)dict;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
- (void)updateObject:(NSObject*)value forKey:(NSString*)key;
- (void)updateObjectsFromDictionary:(NSDictionary*)dict;

@end
