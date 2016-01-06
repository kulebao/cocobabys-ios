//
//  CBIMSettingsModel.m
//  youlebao
//
//  Created by WangXin on 1/6/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBIMSettingsModel.h"

@interface CBIMSettingsModel()

@property (nonatomic, strong) NSMutableDictionary* modelData;

@end

@implementation CBIMSettingsModel

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {

}

+ (instancetype)sharedInstance {
    static CBIMSettingsModel* s_instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [CBIMSettingsModel loadFromLocalData];
        if (s_instance == nil) {
            s_instance = [CBIMSettingsModel new];
        }
    });
    
    return s_instance;
}

- (void)setGroup:(NSString*)targetId disturb:(BOOL)enabled {
    if (targetId) {
        [[self.modelData objectForKey:targetId] setObject:@(enabled) forKey:targetId];
    }
    
    [self store];
}

- (BOOL)getGroupDistrubEnabled:(NSString*)targetId {
    return [[self.modelData objectForKey:targetId] boolValue];
}

- (NSMutableDictionary*)modelData {
    if (_modelData == nil) {
        _modelData = [NSMutableDictionary dictionary];
    }
    
    return _modelData;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSDictionary dictionaryWithDictionary:_modelData] forKey:@"_modelData"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _modelData = [NSMutableDictionary dictionaryWithDictionary:[aDecoder decodeObjectForKey:@"_modelData"]];
    [self setup];
    return self;
}

#pragma mark - Persistent data
+ (NSString*)dataFileName{
    return @"CBIMSettingsModel.dat";
}

- (NSString*)dataFileName{
    return [self.class dataFileName];
}

+ (CBIMSettingsModel*)loadFromLocalData {
    CBIMSettingsModel* localObject = nil;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[self dataFileName]];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        localObject = [unarchiver decodeObjectForKey:@"root"];
    }
    
    return localObject;
}

- (void)store {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[self dataFileName]];
    
    NSMutableData* data = [NSMutableData data];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"root"];
    [archiver finishEncoding];
    
    BOOL ok = [data writeToFile:filePath atomically:NO];
    if (ok) {
        CSLog(@"[*]Write %@ Successed.", [filePath lastPathComponent]);
    }
    else {
        CSLog(@"[*]Write %@ Failed.", [filePath lastPathComponent]);
    }
}

@end
