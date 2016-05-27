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
#import "CBTeacherInfo.h"
#import "CBRelationshipInfo.h"
#import "CBSessionDataModel.h"
#import "CBCtrlMessage.h"
#import "CBTextMessage.h"
#import "CBIMCommand.h"
#import "CBIMBanInfoData.h"

@interface CBIMDataSource ()

@end

@implementation CBIMDataSource
@synthesize banList = _banList;

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
        _classInfoList = [NSMutableArray array];
        _relationshipInfoList = [NSMutableArray array];
        _teacherInfoList = [NSMutableArray array];
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_classInfoList forKey:@"_classInfoList"];
    [aCoder encodeObject:_relationshipInfoList forKey:@"_relationshipInfoList"];
    [aCoder encodeObject:_teacherInfoList forKey:@"_teacherInfoList"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _classInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_classInfoList"]];
    _relationshipInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_relationshipInfoList"]];
    _teacherInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_teacherInfoList"]];
    
    return self;
}

- (NSMutableDictionary*)banList {
    if (_banList == nil) {
        _banList = [NSMutableDictionary dictionary];
    }
    
    return _banList;
}

#pragma mark - Persistent data
+ (NSString*)dataFileName{
    return @"CBIMDataSource.cbar";
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
    [self getUserInfoWithUserId:userId inGroup:nil completion:completion];
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
        
        for (CBRelationshipInfo* relation in _relationshipInfoList) {
            if ([classlId isEqualToString:relation.child.class_id.stringValue]
                && [schoolId isEqualToString:relation.child.school_id.stringValue]) {
                
                NSURL* portrait = [[NSBundle mainBundle] URLForResource:@"v2-im-group@2x" withExtension:@"png"];
                
                groupObj = [[RCGroup alloc] initWithGroupId:groupId
                                                  groupName:SAFE_STRING(relation.child.class_name)
                                                portraitUri:portrait.absoluteString];
                break;
            }
        }
    }
    else {
        
    }
    
    if (groupObj == nil) {
        groupObj = [[RCGroup alloc] initWithGroupId:groupId
                                          groupName:groupId
                                        portraitUri:nil];
    }
    
    completion(groupObj);
}

#pragma mark - RCIMReceiveMessageDelegate
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    if (!session.schoolConfig.schoolGroupChat && message.conversationType == ConversationType_GROUP) {
        //[[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:message.conversationType targetId:message.targetId];
        [[RCIMClient sharedRCIMClient] clearMessages:message.conversationType targetId:message.targetId];
    }
    else if ([message.content isKindOfClass:[CBCtrlMessage class]]) {
        CBCtrlMessage* ctrlMsgContent = (CBCtrlMessage*)message.content;
        CBIMCommand* cmd = [CBIMCommand new];
        BOOL ok = [cmd parse:ctrlMsgContent.content];
        if (ok) {
            [self processCmd:cmd];
        }
        
        CSLog(@"CBCtrlMessage=%@", ctrlMsgContent.content);
    }
    else if (message.conversationType == ConversationType_GROUP) {
        if ([message.content respondsToSelector:@selector(extra)]) {
            NSString* extra = [(id)message.content extra];
            if ([extra containsString:@"forbidden_msg"]) {
                BOOL ok = [[RCIMClient sharedRCIMClient] deleteMessages:@[@(message.messageId)]];
                CSLog(@"deleted forbidden_msg success=%@", @(ok));
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti.cb.rm.msg" object:message];
            }
        }
    }
}

- (void)processCmd:(CBIMCommand*)cmd {
    if ([cmd.cmd isEqualToString:@"ban"]) {
        [[CBIMDataSource sharedInstance] setGroup:[NSString stringWithFormat:@"%@_%@", cmd.schoolId, cmd.classId]
                                             user:cmd.userId
                                              ban:YES];
    }
    else if ([cmd.cmd isEqualToString:@"approval"]) {
        [[CBIMDataSource sharedInstance] setGroup:[NSString stringWithFormat:@"%@_%@", cmd.schoolId, cmd.classId]
                                             user:cmd.userId
                                              ban:NO];
    }
    else if ([cmd.cmd isEqualToString:@"hidemsg"]) {
        RCMessage* msg = [[RCIMClient sharedRCIMClient] getMessageByUId:cmd.msgUid];
        BOOL ok = [[RCIMClient sharedRCIMClient] deleteMessages:@[@(msg.messageId)]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti.cb.rm.msg" object:msg];
    }
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
    
    NSString* group_school_id = nil;
    NSString* group_class_id = nil;
    
    NSArray* components = [groupId componentsSeparatedByString:@"_"];
    if (components.count == 2) {
        group_school_id = components[0];
        group_class_id = components[1];
    }
    
    if ([userId isEqualToString:@"im_system_admin"]) {
        userObj = [[RCUserInfo alloc] initWithUserId:userId name:@"系统管理员" portrait:nil];
    }
    else {
        NSError* error = nil;
        // p_8901_Some(9331)_18762242606
        // t_8901_Some(1361)_221919
        NSString* pattern = @"\\w+_(.*)_Some\\((.*)\\)_(.*)$";
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult* result = [regex firstMatchInString:userId options:0 range:NSMakeRange(0, userId.length)];
        if (result && result.numberOfRanges>3) {
            NSString* school_id = [userId substringWithRange:[result rangeAtIndex:1]];
            NSString* user_id = [userId substringWithRange:[result rangeAtIndex:2]];
            NSString* login_name = [userId substringWithRange:[result rangeAtIndex:3]];
            
            //CSLog(@"user_id=%@, full_userId=%@", user_id, userId);
            
            if ([userId hasPrefix:@"p_"]) {
                // https://stage2.cocobabys.com/kindergarten/8901/relationship?class_id=20001
                
                NSString* im_name = @"家长";
                NSString* im_portrait = nil;
                
                if (group_class_id) {
                    for (CBRelationshipInfo* relation in _relationshipInfoList) {
                        if ([user_id isEqualToString:relation.parent._id.stringValue]
                            && relation.parent.school_id.integerValue == [school_id integerValue]) {
                            if ([group_class_id isEqualToString:relation.child.class_id.stringValue]) {
                                im_name = [NSString stringWithFormat:@"%@%@", [relation.child displayNick], relation.relationship];
                                im_portrait = relation.parent.portrait;
                                break;
                            }
                        }
                    }
                }
                else {
                    
                    NSMutableArray* im_relationships = [NSMutableArray array];
                    for (CBRelationshipInfo* relation in _relationshipInfoList) {
                        if ([user_id isEqualToString:relation.parent._id.stringValue]
                            && relation.parent.school_id.integerValue == [school_id integerValue]) {
                            [im_relationships addObject:relation];
                        }
                    }
                    
                    if (im_relationships.count > 1) {
                        NSMutableArray* im_name_list = [NSMutableArray array];
                        for (CBRelationshipInfo* relation in im_relationships) {
                            //[im_name_list addObject:[NSString stringWithFormat:@"%@%@", [relation.child displayNick], relation.relationship]];
                            [im_name_list addObject:[relation.child displayNick]];
                            im_portrait = relation.parent.portrait;
                        }
                        
                        im_name = [NSString stringWithFormat:@"%@的亲属", [im_name_list componentsJoinedByString:@","]];
                    }
                    else {
                        CBRelationshipInfo* relation = im_relationships.firstObject;
                        if (relation) {
                            im_name = [NSString stringWithFormat:@"%@%@", [relation.child displayNick], relation.relationship];
                            im_portrait = relation.parent.portrait;
                        }
                    }
                }
                
                userObj = [[RCUserInfo alloc] initWithUserId:userId
                                                        name:im_name
                                                    portrait:im_portrait];
            }
            else if ([userId hasPrefix:@"t_"]) {
                // https://stage2.cocobabys.com/kindergarten/8901/class/20001/manager
                // NSArray* objList = [_teacherInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid==%@",user_id]];
                
                for (CBTeacherInfo* teacherInfo in _teacherInfoList) {
                    if ([user_id isEqualToString:teacherInfo.uid.stringValue]
                        && teacherInfo.school_id.integerValue == [school_id integerValue]) {
                        userObj = [[RCUserInfo alloc] initWithUserId:userId
                                                                name:[NSString stringWithFormat:@"%@老师", teacherInfo.name]
                                                            portrait:teacherInfo.portrait];
                        break;
                    }
                }
            }
            else {
                
            }
        }
        else {
            
        }
    }
    
    if (userObj == nil) {
        userObj = [[RCUserInfo alloc] initWithUserId:userId name:userId portrait:nil];
    }
    
    completion(userObj);
}

#pragma mark - Network
- (void)reloadTeachers {
    //[RCIM sharedRCIM] refreshGroupInfoCache:<#(RCGroup *)#> withGroupId:<#(NSString *)#>
    
    CBHttpClient* http = [CBHttpClient sharedInstance];
    [http reqGetTeachersOfKindergarten:gApp.engine.currentRelationship.parent.schoolId
                           withClassId:0 //gApp.engine.currentRelationship.child.classId
                               success:^(NSURLSessionDataTask *task, id dataJson) {
                                   for (NSDictionary* json in dataJson) {
                                       CBTeacherInfo* newObj = [CBTeacherInfo instanceWithDictionary:json];
                                       
                                       NSArray* objList = [_teacherInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid==%@",newObj.uid]];
                                       
                                       if (objList.count == 0) {
                                           [_teacherInfoList addObject:newObj];
                                       }
                                       else {
                                           for (CBTeacherInfo* obj in objList) {
                                               [obj updateObjectsFromDictionary:json];
                                           }
                                       }
                                   }
                                   
                                   //[self store];
                                   [[RCIM sharedRCIM] clearUserInfoCache];
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                               }];
}

- (void)reloadRelationships {
    CBHttpClient* http = [CBHttpClient sharedInstance];
    [http reqGetRelationshipsOfKindergarten:gApp.engine.currentRelationship.parent.schoolId
                                withClassId:0 //gApp.engine.currentRelationship.child.classId
                                    success:^(NSURLSessionDataTask *task, id dataJson) {
                                        for (NSDictionary* json in dataJson) {
                                            CBRelationshipInfo* newObj = [CBRelationshipInfo instanceWithDictionary:json];
                                            
                                            NSArray* objList = [_relationshipInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"_id==%@", newObj._id]];
                                            if (objList.count == 0) {
                                                [_relationshipInfoList addObject:newObj];
                                            }
                                            else {
                                                for (CBRelationshipInfo* obj in objList) {
                                                    [obj updateObjectsFromDictionary:json];
                                                }
                                            }
                                        }
                                        
                                        //[self store];
                                        [[RCIM sharedRCIM] clearUserInfoCache];
                                        [[RCIM sharedRCIM] clearGroupInfoCache];
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        
                                    }];
}

- (BOOL)isBandInGroup:(NSString*)groupId {
    BOOL ban = NO;
    
    NSMutableArray* banInfoList = [self.banList objectForKey:groupId];
    NSString* userId = [[[RCIM sharedRCIM] currentUserInfo] userId];
    for (CBIMBanInfoData* info in banInfoList) {
        if ([userId isEqualToString:info._id]) {
            ban = YES;
            break;
        }
    }
    
    return ban;
}

- (void)setGroup:(NSString*)groupId user:(NSString*)userId ban:(BOOL)ban {
    NSMutableArray* banInfoList = [self.banList objectForKey:groupId];
    if (banInfoList == nil) {
        banInfoList = [NSMutableArray array];
        [self.banList setObject:banInfoList forKey:groupId];
    }
    
    if (ban) {
        CBIMBanInfoData* info = [CBIMBanInfoData new];
        info._id = [[[RCIM sharedRCIM] currentUserInfo] userId];
        [banInfoList addObject:info];
    }
    else {
        for (CBIMBanInfoData* info in banInfoList) {
            if ([userId isEqualToString:info._id]) {
                info._id = @"";
            }
        }
    }
}

/*!
 当App处于后台时，接收到消息并弹出本地通知的回调方法
 
 @param message     接收到的消息
 @param senderName  消息发送者的用户名称
 @return            当返回值为NO时，SDK会弹出默认的本地通知提示；当返回值为YES时，SDK针对此消息不再弹本地通知提示
 
 @discussion 如果您设置了IMKit消息监听之后，当App处于后台，收到消息时弹出本地通知之前，会执行此方法。
 如果App没有实现此方法，SDK会弹出默认的本地通知提示。
 流程：
 SDK接收到消息 -> App处于后台状态 -> 通过用户/群组/群名片信息提供者获取消息的用户/群组/群名片信息
 -> 用户/群组信息为空 -> 不弹出本地通知
 -> 用户/群组信息存在 -> 回调此方法准备弹出本地通知 -> App实现并返回YES        -> SDK不再弹出此消息的本地通知
 -> App未实现此方法或者返回NO -> SDK弹出默认的本地通知提示
 
 
 您可以通过RCIM的disableMessageNotificaiton属性，关闭所有的本地通知(此时不再回调此接口)。
 
 @warning 如果App在后台想使用SDK默认的本地通知提醒，需要实现用户/群组/群名片信息提供者，并返回正确的用户信息或群组信息。
 参考RCIMUserInfoDataSource、RCIMGroupInfoDataSource与RCIMGroupUserInfoDataSource
 */
-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message
                      withSenderName:(NSString *)senderName {
    BOOL ok = NO;
    
    if ([message isKindOfClass:[CBCtrlMessage class]]) {
        ok = YES;
    }
    else {
        NSString* extra = [(id)message.content extra];
        if ([extra containsString:@"forbidden_msg"]) {
            ok = YES;
        }
    }
    
    return ok;
}

/*!
 当App处于前台时，接收到消息并播放提示音的回调方法
 
 @param message 接收到的消息
 @return        当返回值为NO时，SDK会播放默认的提示音；当返回值为YES时，SDK针对此消息不再播放提示音
 
 @discussion 到消息时播放提示音之前，会执行此方法。
 如果App没有实现此方法，SDK会播放默认的提示音。
 流程：
 SDK接收到消息 -> App处于前台状态 -> 回调此方法准备播放提示音 -> App实现并返回YES        -> SDK针对此消息不再播放提示音
 -> App未实现此方法或者返回NO -> SDK会播放默认的提示音
 
 您可以通过RCIM的disableMessageAlertSound属性，关闭所有前台消息的提示音(此时不再回调此接口)。
 */
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message {
    BOOL ok = NO;
    
    if ([message isKindOfClass:[CBCtrlMessage class]]) {
        ok = YES;
    }
    else {
        NSString* extra = [(id)message.content extra];
        if ([extra containsString:@"forbidden_msg"]) {
            ok = YES;
        }
    }
    
    return ok;
}

@end