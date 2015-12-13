//
//  CBIMDataSource.m
//  youlebao
//
//  Created by WangXin on 12/3/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBIMDataSource.h"
#import "CBHttpClient.h"
#import "CBClassInfo.h"
#import "CSAppDelegate.h"
#import "CBParentInfo.h"
#import "CBTeacherInfo.h"

@interface CBIMDataSource ()

@property (nonatomic, strong) NSMutableArray* classInfoList;
@property (nonatomic, strong) NSMutableArray* parentInfoList;
@property (nonatomic, strong) NSMutableArray* teacherInfoList;


@end

@implementation CBIMDataSource

+ (instancetype)sharedInstance {
    static CBIMDataSource* s_instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [CBIMDataSource loadFromLocalData];
        if (s_instance == nil) {
            s_instance = [CBIMDataSource new];
        }
    });
    
    return s_instance;
}

- (id)init {
    if (self = [super init]) {
        self.classInfoList = [NSMutableArray array];
        self.parentInfoList = [NSMutableArray array];
        self.teacherInfoList = [NSMutableArray array];
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_classInfoList forKey:@"_classInfoList"];
    [aCoder encodeObject:_parentInfoList forKey:@"_parentInfoList"];
    [aCoder encodeObject:_teacherInfoList forKey:@"_teacherInfoList"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _classInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_classInfoList"]];
    _parentInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_parentInfoList"]];
    _teacherInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_teacherInfoList"]];
    
    return self;
}

#pragma mark - Persistent data
+ (NSString*)dataFileName{
    return @"CBIMDataSource.dat";
}

- (NSString*)dataFileName{
    return [self.class dataFileName];
}

+ (CBIMDataSource*)loadFromLocalData {
    CBIMDataSource* localObject = nil;
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
        CSLog(@"Write %@ successed.", [filePath lastPathComponent]);
    }
    else {
        CSLog(@"Write %@ failed.", [filePath lastPathComponent]);
    }
}

#pragma mark - RCIMUserInfoDataSource
/**
 *  获取用户信息。
 *
 *  @param userId     用户 Id。
 *  @param completion 用户信息
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion {
    RCUserInfo* userObj = nil;
    
    if ([userId isEqualToString:@"im_system_admin"]) {
        userObj = [[RCUserInfo alloc] initWithUserId:userId name:@"系统管理员" portrait:nil];
    }
    else {
        NSError* error = nil;
        // p_8901_Some(9331)_18762242606
        NSString* pattern = @"\\w+_Some\\((.*)\\)_\\w+";
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult* result = [regex firstMatchInString:userId options:0 range:NSMakeRange(0, userId.length)];
        if (result && result.numberOfRanges>1) {
            NSString* user_id = [userId substringWithRange:[result rangeAtIndex:1]];
            
            if ([userId hasPrefix:@"p_"]) {
                CSLog(@"p=%@, userId=%@", user_id, userId);
                // https://stage2.cocobabys.com/kindergarten/8901/parent
                
                NSArray* objList = [_parentInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ssid==%@",user_id]];
                CBParentInfo* parentInfo = [objList lastObject];
                if (parentInfo) {
                    userObj = [[RCUserInfo alloc] initWithUserId:userId name:parentInfo.name portrait:parentInfo.portrait];
                }
            }
            else if ([userId hasPrefix:@"t_"]) {
                CSLog(@"t=%@, userId=%@", user_id, userId);
                // https://stage2.cocobabys.com/kindergarten/8901/employee
            }
            else {
                
            }
        }
        else {
            
        }
    }
    
    completion(userObj);
}

#pragma mark - RCIMGroupInfoDataSource
/**
 *  获取群组信息。
 *
 *  @param groupId  群组ID.
 *  @param completion 获取完成调用的BLOCK.
 */

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion {
    RCGroup* groupObj = nil;
    NSArray* components = [groupId componentsSeparatedByString:@"_"];
    if (components.count == 2) {
        NSString* schoolId = components[0];
        NSString* classlId = components[1];
        
        for (CSKuleRelationshipInfo* relationShip in gApp.engine.relationships) {
            if (relationShip.child.classId == [classlId integerValue]
                && relationShip.parent.schoolId == [schoolId integerValue]) {
                groupObj = [[RCGroup alloc] initWithGroupId:groupId
                                                  groupName:SAFE_STRING(relationShip.child.className)
                                                portraitUri:nil];
                break;;
            }
        }
    }
    else {
        
    }
    
    completion(groupObj);
}

#pragma mark - RCIMGroupUserInfoDataSource
/**
 *  获取用户在群组中的用户信息。
 *  如果该用户在该群组中没有设置群名片，请注意：1，不要调用别的接口返回全局用户信息，直接回调给我们nil就行，SDK会自己调用普通用户信息提供者获取用户信息；2一定要调用completion(nil)，这样SDK才能继续往下操作。
 *
 *  @param userId     用户 Id。
 *  @param groupId  群组ID.
 *  @param completion 获取完成调用的BLOCK.
 */
- (void)getUserInfoWithUserId:(NSString *)userId inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion {
    RCUserInfo* userObj = nil;
    
    if ([userId isEqualToString:@"im_system_admin"]) {
        userObj = [[RCUserInfo alloc] initWithUserId:userId name:@"系统管理员" portrait:nil];
    }
    else {
        NSError* error = nil;
        // p_8901_Some(9331)_18762242606
        NSString* pattern = @"\\w+_Some\\((.*)\\)_\\w+";
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult* result = [regex firstMatchInString:userId options:0 range:NSMakeRange(0, userId.length)];
        if (result && result.numberOfRanges>1) {
            NSString* user_id = [userId substringWithRange:[result rangeAtIndex:1]];
            
            if ([userId hasPrefix:@"p_"]) {
                //CSLog(@"p=%@", user_id);
                // https://stage2.cocobabys.com/kindergarten/8901/parent
                
                NSArray* objList = [_parentInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ssid==%@",user_id]];
                CBParentInfo* parentInfo = [objList lastObject];
                if (parentInfo) {
                    userObj = [[RCUserInfo alloc] initWithUserId:userId name:parentInfo.name portrait:parentInfo.portrait];
                }
            }
            else if ([userId hasPrefix:@"t_"]) {
                //CSLog(@"t=%@", user_id);
                // https://stage2.cocobabys.com/kindergarten/8901/employee
            }
            else {
                
            }
        }
        else {
            
        }
    }
    
    completion(userObj);
}

#pragma mark - Network
- (void)reloadParents {
    //[RCIM sharedRCIM] refreshGroupInfoCache:<#(RCGroup *)#> withGroupId:<#(NSString *)#>
    
    CBHttpClient* http = [CBHttpClient sharedInstance];
    [http reqGetParentsOfKindergarten:gApp.engine.currentRelationship.parent.schoolId
                              success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                  for (NSDictionary* json in dataJson) {
                                      CBParentInfo* newObj = [CBParentInfo instanceWithDictionary:json];
                                      
                                      NSArray* objList = [_parentInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parent_id==%@ && school_id==%@", newObj.parent_id, newObj.school_id]];
                                      
                                      if (objList.count == 0) {
                                          [_parentInfoList addObject:newObj];
                                      }
                                      else {
                                          for (CBParentInfo* obj in objList) {
                                              [obj updateObjectsFromDictionary:json];
                                          }
                                      }
                                  }
                                  
                                  [self store];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                              }];
}

- (void)reloadTeachers {
    CBHttpClient* http = [CBHttpClient sharedInstance];
    [http reqGetTeachersOfKindergarten:gApp.engine.currentRelationship.parent.schoolId
                               success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                   for (NSDictionary* json in dataJson) {
                                       CBTeacherInfo* newObj = [CBTeacherInfo instanceWithDictionary:json];
                                       
                                       NSArray* objList = [_teacherInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ssid==%@ && school_id==%@", newObj.ssid, newObj.school_id]];
                                       
                                       if (objList.count == 0) {
                                           [_teacherInfoList addObject:newObj];
                                       }
                                       else {
                                           for (CBTeacherInfo* obj in objList) {
                                               [obj updateObjectsFromDictionary:json];
                                           }
                                       }
                                   }
                                   
                                   [self store];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   
                               }];
}

@end