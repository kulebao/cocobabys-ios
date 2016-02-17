//
//  CBSessionDataModel.m
//  youlebao
//
//  Created by WangXin on 2/17/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBSessionDataModel.h"

static CBSessionDataModel* s_instance = NULL;

@interface CBSessionDataModel()

@end

@implementation CBSessionDataModel
@synthesize username = _username;
@synthesize tag = _tag;
@synthesize imGroupTags = _imGroupTags;

- (NSMutableSet*)imGroupTags {
    if (_imGroupTags == nil) {
        _imGroupTags = [NSMutableSet set];
    }
    
    return _imGroupTags;
}

+ (instancetype)session:(NSString*)username {
    return [self session:username withTag:@"none"];
}

+ (instancetype)session:(NSString*)username withTag:(NSString*)tag {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[self dataFileName:username withTag:tag]];
    CBSessionDataModel* localObject = nil;
    @try {
        localObject = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    @catch (NSException *exception) {
        CSLog(@"exception:%@", exception);
    }
    @finally {
        
    }
    
    if (localObject == nil) {
        localObject = [[CBSessionDataModel alloc] initUsername:username withTag:tag];
        [localObject store];
    }
    
    if (s_instance) {
        [s_instance invalidate];
    }
    
    s_instance = localObject;
    
    return s_instance;
}

+ (instancetype)thisSession {
    return s_instance;
}

- (BOOL)isValid {
    return YES;
}

- (void)invalidate {
    if ([self isEqual:s_instance]) {
        s_instance = nil;
    }
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_username forKey:@"_username"];
    [aCoder encodeObject:_tag forKey:@"_tag"];
    [aCoder encodeObject:_imGroupTags forKey:@"_imGroupTags"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _username = [aDecoder decodeObjectForKey:@"_username"];
    _tag = [aDecoder decodeObjectForKey:@"_tag"];
    _imGroupTags = [NSMutableSet setWithSet:[aDecoder decodeObjectForKey:@"_imGroupTags"]];
    
    [self setup];
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initUsername:(NSString*)username withTag:(NSString*)tag {
    if (self = [self init]) {
        _username = username;
        _tag = tag;
        
    }
    
    return self;
}

- (void)setup {

}

#pragma mark - Persistent data
+ (NSString*)dataFileName:(NSString*)username withTag:(NSString*)tag{
    return [NSString stringWithFormat:@"userSessionModelData_%@_%@.cbar", SAFE_STRING(tag), SAFE_STRING(username.lowercaseString)];
}

- (NSString*)dataFileName:(NSString*)username withTag:(NSString*)tag{
    return [self.class dataFileName:username withTag:tag];
}

- (void)store {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[self dataFileName:self.username withTag:self.tag]];
    BOOL ok = [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    if (ok) {
        CSLog(@"[*]Write %@ Successed.", [filePath lastPathComponent]);
    }
    else {
        CSLog(@"[*]Write %@ Failed.", [filePath lastPathComponent]);
    }
}

@end
