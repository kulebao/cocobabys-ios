// CSJsonObject.m
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

#import "CSJsonObject.h"

@interface CSJsonObject ()

@property (nonatomic, strong) NSMutableDictionary* rawDict;

@end

@implementation CSJsonObject
@synthesize rawDict = _rawDict;

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@] -> %@", NSStringFromClass(self.class), _rawDict];
}

+ (instancetype)instanceWithDictionary:(NSDictionary*)dict {
    id object = [[self alloc] initWithDictionary:dict];
    return object;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [self init]) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            self.rawDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            
            for (NSString* key in self.rawDict) {
                @try {
                    if ([key isEqualToString:@"id"]) {
                        [self setValue:self.rawDict[key] forKey:@"_id"];
                    }
                    else {
                        [self setValue:self.rawDict[key] forKey:key];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"ERR: Unknown '%@' in %@", key, NSStringFromClass(self.class));
                }
                @finally {
                    
                }
            }
        }
        else {
            self.rawDict = nil;
            self = nil;
        }
    }
    return self;
}

- (void)updateObject:(NSObject*)value forKey:(NSString*)key {
    if (value) {
        [self.rawDict setObject:value forKey:key];
    }
    else {
        [self.rawDict removeObjectForKey:key];
    }
}

- (void)updateObjectsFromDictionary:(NSDictionary*)dict {
    [self.rawDict addEntriesFromDictionary:dict];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_rawDict forKey:@"_rawDict"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSDictionary* dictData = [aDecoder decodeObjectForKey:@"_rawDict"];
    self = [self initWithDictionary:dictData];
    return self;
}

- (NSDictionary*)dictionary {
    return [NSDictionary dictionaryWithDictionary:(self.rawDict ? self.rawDict : @{})];
}

@end
