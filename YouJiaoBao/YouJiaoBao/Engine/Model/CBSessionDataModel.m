//
//  CBSessionDataModel.m
//  youlebao
//
//  Created by WangXin on 2/17/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBSessionDataModel.h"
#import "CSHttpClient.h"
#import "CBClassInfo.h"
#import "CSAppDelegate.h"
#import "CBTeacherInfo.h"
#import "CBRelationshipInfo.h"
#import "CSEngine.h"
#import "CBSessionDataModel.h"

static CBSessionDataModel* s_instance = NULL;

@interface CBSessionDataModel() {
    AFHTTPRequestOperation* _opReloadClassList;
}

@end

@implementation CBSessionDataModel
@synthesize username = _username;
@synthesize tag = _tag;
@synthesize imGroupTags = _imGroupTags;

@synthesize relationshipInfoList = _relationshipInfoList;
@synthesize teacherInfoList = _teacherInfoList;
@synthesize classInfoList = _classInfoList;
@synthesize childInfoList = _childInfoList;
@synthesize parentInfoList = _parentInfoList;
@synthesize dailylogInfoList = _dailylogInfoList;
@synthesize newsInfoList = _newsInfoList;
@synthesize assessInfoList = _assessInfoList;

- (NSMutableSet*)imGroupTags {
    if (_imGroupTags == nil) {
        _imGroupTags = [NSMutableSet set];
    }
    
    return _imGroupTags;
}

+ (instancetype)session:(NSString*)username {
#if COCOBABYS_USE_ENV_PROD
    return [self session:username withTag:@"prod"];
#else
    return [self session:username withTag:@"stage"];
#endif
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
    
    // Set IM Data source
    [[RCIM sharedRCIM] setGroupInfoDataSource:s_instance];
    [[RCIM sharedRCIM] setUserInfoDataSource:s_instance];
    [[RCIM sharedRCIM] setGroupUserInfoDataSource:s_instance];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:s_instance];
    
    return s_instance;
}

+ (instancetype)thisSession {
    return s_instance;
}

- (BOOL)isValid {
    return YES;
}

- (void)updateSchoolConfig:(NSInteger)schoolId{
    CSHttpClient* http = [CSHttpClient sharedInstance];
    [http reqGetConfigOfKindergarten:schoolId
                             success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                 self.schoolConfig = [CBSchoolConfigData instanceWithDictionary:dataJson];
                                 [self processConfig];
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 
                             }];
}

- (void)invalidate {
    if ([self isEqual:s_instance]) {
        s_instance = nil;
    }
}

- (void)processConfig {
    if (!self.schoolConfig.schoolGroupChat) {
        NSArray* conns = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_GROUP)]];
        for (RCConversation* con in conns) {
            [[RCIMClient sharedRCIMClient] clearMessages:con.conversationType targetId:con.targetId];
            [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:con.conversationType
                                                                    targetId:con.targetId
                                                                   isBlocked:!self.schoolConfig.schoolGroupChat
                                                                     success:^(RCConversationNotificationStatus nStatus) {
                                                                         
                                                                     } error:^(RCErrorCode status) {
                                                                         
                                                                     }];
        }
    }
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_username forKey:@"_username"];
    [aCoder encodeObject:_tag forKey:@"_tag"];
    [aCoder encodeObject:_imGroupTags forKey:@"_imGroupTags"];
    [aCoder encodeObject:_schoolConfig forKey:@"_schoolConfig"];
    [aCoder encodeObject:_loginInfo forKey:@"_loginInfo"];
    [aCoder encodeObject:_relationshipInfoList forKey:@"_relationshipInfoList"];
    [aCoder encodeObject:_teacherInfoList forKey:@"_teacherInfoList"];
    [aCoder encodeObject:_classInfoList forKey:@"_classInfoList"];
    [aCoder encodeObject:_ineligibleClassList forKey:@"_ineligibleClassList"];
    [aCoder encodeObject:_newsInfoList forKey:@"_newsInfoList"];
    [aCoder encodeObject:_dailylogInfoList forKey:@"_dailylogInfoList"];
    [aCoder encodeObject:_assessInfoList forKey:@"_assessInfoList"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _username = [aDecoder decodeObjectForKey:@"_username"];
    _tag = [aDecoder decodeObjectForKey:@"_tag"];
    _imGroupTags = [NSMutableSet setWithSet:[aDecoder decodeObjectForKey:@"_imGroupTags"]];
    _schoolConfig = [aDecoder decodeObjectForKey:@"_schoolConfig"];
    _loginInfo = [aDecoder decodeObjectForKey:@"_loginInfo"];
    _relationshipInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_relationshipInfoList"]];
    _teacherInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_teacherInfoList"]];
    _classInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_classInfoList"]];
    _ineligibleClassList = [aDecoder decodeObjectForKey:@"_ineligibleClassList"];
    _newsInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_newsInfoList"]];
    _dailylogInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_dailylogInfoList"]];
    _assessInfoList = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"_assessInfoList"]];
    
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

- (NSMutableArray*)classInfoList {
    if (_classInfoList == nil) {
        _classInfoList = [NSMutableArray array];
    }
    
    return _classInfoList;
}

- (NSMutableArray*)relationshipInfoList {
    if (_relationshipInfoList == nil) {
        _relationshipInfoList = [NSMutableArray array];
    }
    
    return _relationshipInfoList;
}

- (NSMutableArray*)teacherInfoList {
    if (_teacherInfoList == nil) {
        _teacherInfoList = [NSMutableArray array];
    }
    
    return _teacherInfoList;
}

- (NSMutableArray*)dailylogInfoList {
    if (_dailylogInfoList == nil) {
        _dailylogInfoList = [NSMutableArray array];
    }
    
    return _dailylogInfoList;
}

- (NSMutableArray*)assessInfoList {
    if (_assessInfoList == nil) {
        _assessInfoList = [NSMutableArray array];
    }
    
    return _assessInfoList;
}

- (NSArray*)childInfoList {
    return _childInfoList;
}

- (NSArray*)parentInfoList {
    return _parentInfoList;
}

- (BOOL)allowToSendAll {
    BOOL ok = NO;
    if (self.ineligibleClassList && self.ineligibleClassList.count == 0) {
        ok = YES;
    }
    
    return ok;
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

#pragma mark - Relationships
- (void)updateRelationshipsByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateRelationshipsByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateRelationshipsByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateRelationshipsByJsonObject:%@", jsonObject);
    }
    
    [self updateParentAndChild];
}

- (void)reloadRelationshipsByJsonObject:(id)jsonObject {
    [self.relationshipInfoList removeAllObjects];
    [self updateParentAndChild];
    
    [self updateRelationshipsByJsonObject:jsonObject];
}

- (void)_updateRelationshipsByJsonObject:(NSDictionary*)dictObject {
    CBRelationshipInfo* obj = [CBRelationshipInfo instanceWithDictionary:dictObject];

    NSArray* relationships = [self.relationshipInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"_id == %@", obj._id]];
    if (relationships.count > 0) {
        for (CBRelationshipInfo* o in relationships) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        [self.relationshipInfoList addObject:obj];
    }
}

- (void)updateParentAndChild {
    NSMutableArray* pInfoList = [NSMutableArray array];
    NSMutableArray* cInfoList = [NSMutableArray array];
    NSMutableSet* pInfoSet = [NSMutableSet set];
    NSMutableSet* cInfoSet = [NSMutableSet set];
    
    for (CBRelationshipInfo* o in self.relationshipInfoList) {
        if (![pInfoSet containsObject:o.parent._id]) {
            [pInfoSet addObject:o.parent._id];
            [pInfoList addObject:o.parent];
        }
        
        if (![cInfoSet containsObject:o.child.child_id]) {
            [cInfoSet addObject:o.child.child_id];
            [cInfoList addObject:o.child];
        }
    }
    
    _parentInfoList = [pInfoList copy];
    _childInfoList = [cInfoList copy];
}

- (void)updateTeacherInfosByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateTeacherInfosByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateTeacherInfosByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateTeacherInfosByJsonObject:%@", jsonObject);
    }
}

- (void)_updateTeacherInfosByJsonObject:(NSDictionary*)dictObject {
    CBTeacherInfo* obj = [CBTeacherInfo instanceWithDictionary:dictObject];
    
    NSArray* teachers = [self.teacherInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", obj.uid]];
    if (teachers.count > 0) {
        for (CBTeacherInfo* o in teachers) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        [self.teacherInfoList addObject:obj];
    }
}

- (void)updateClassInfosByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateClassInfosByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateClassInfosByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateClassInfosByJsonObject:%@", jsonObject);
    }
}

- (void)_updateClassInfosByJsonObject:(NSDictionary*)dictObject {
    CBClassInfo* obj = [CBClassInfo instanceWithDictionary:dictObject];
    
    NSArray* classList = [self.classInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class_id == %ld", obj.class_id]];
    if (classList.count > 0) {
        for (CBClassInfo* o in classList) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        [self.classInfoList addObject:obj];
    }
}

- (void)updateChildInfosByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateChildInfosByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateChildInfosByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateChildInfosByJsonObject:%@", jsonObject);
    }
}

- (void)_updateChildInfosByJsonObject:(NSDictionary*)dictObject {
    CBChildInfo* obj = [CBChildInfo instanceWithDictionary:dictObject];
    
    NSArray* objList = [self.childInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"child_id == %@", obj.child_id]];
    if (objList.count > 0) {
        for (CBChildInfo* o in objList) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        CSLog(@"ERR: UNKNOWN CHILD:%@", obj);
    }
}

- (NSArray*)updateParentInfosByJsonObject:(id)jsonObject {
    NSMutableArray* retArray = [NSMutableArray array];
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        CBParentInfo* o = [self _updateParentInfosByJsonObject:jsonObject];
        [retArray addObject:o];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            NSArray* list = [self updateParentInfosByJsonObject:obj];
            [retArray addObjectsFromArray:list];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateParentInfosByJsonObject:%@", jsonObject);
    }
    
    return [retArray copy];
}

- (CBParentInfo*)_updateParentInfosByJsonObject:(NSDictionary*)dictObject {
    CBParentInfo* obj = [CBParentInfo instanceWithDictionary:dictObject];
    
    NSArray* objList = [self.parentInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parent_id == %@", obj.parent_id]];
    if (objList.count > 0) {
        for (CBParentInfo* o in objList) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        CSLog(@"ERR: UNKNOWN PARENT:%@", obj);
    }
    
    return obj;
}

- (void)updateDailylogsByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateDailylogsByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateDailylogsByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateDailylogsByJsonObject:%@", jsonObject);
    }
}

- (void)_updateDailylogsByJsonObject:(NSDictionary*)dictObject {
    CBDailylogInfo* obj = [CBDailylogInfo instanceWithDictionary:dictObject];
    NSArray* dailylogList = [self.dailylogInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"child_id == %@", obj.child_id]];
    if (dailylogList.count > 0) {
        for (CBDailylogInfo* o in dailylogList) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        [self.dailylogInfoList addObject:obj];
    }
}

- (void)updateNewsInfosByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateNewsInfosByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateNewsInfosByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateNewsInfosByJsonObject:%@", jsonObject);
    }
    
    // Sort
    [_newsInfoList sortUsingComparator:^NSComparisonResult(CBNewsInfo* obj1, CBNewsInfo* obj2) {
        return [obj2.timestamp compare:obj1.timestamp];
    }];
}

- (void)_updateNewsInfosByJsonObject:(NSDictionary*)dictObject {
    CBNewsInfo* obj = [CBNewsInfo instanceWithDictionary:dictObject];
    NSArray* objList = [self.newsInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"news_id == %@", obj.news_id]];
    if (objList.count > 0) {
        for (CBNewsInfo* o in objList) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        [self.newsInfoList insertObject:obj atIndex:0];
    }
}

- (void)reloadNewsInfosByJsonObject:(id)jsonObject {
    [self.newsInfoList removeAllObjects];
    [self updateNewsInfosByJsonObject:jsonObject];
}

- (void)updateAssessInfosByJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [self _updateAssessInfosByJsonObject:jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]]) {
        for (id obj in jsonObject) {
            [self updateAssessInfosByJsonObject:obj];
        }
    }
    else {
        CSLog(@"ERR: Unknown updateAssessInfosByJsonObject:%@", jsonObject);
    }
}

- (void)_updateAssessInfosByJsonObject:(NSDictionary*)dictObject {
    CBAssessInfo* obj = [CBAssessInfo instanceWithDictionary:dictObject];
    NSArray* objList = [self.assessInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"child_id == %@", obj.child_id]];
    if (objList.count > 0) {
        for (CBAssessInfo* o in objList) {
            [o updateObjectsFromDictionary:dictObject];
        }
    }
    else {
        [self.assessInfoList addObject:obj];
    }
}

#pragma mark - Geters
- (CBRelationshipInfo*)getReleationshipById:(NSInteger)rid {
    NSArray* relationships = [self.relationshipInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"_id == %ld", rid]];
    return relationships.lastObject;
}

- (CBTeacherInfo*)getTeacherInfoById:(NSInteger)tid {
    NSArray* teachers = [self.teacherInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %d", tid]];
    return teachers.lastObject;
}

- (CBClassInfo*)getClassInfoByClassId:(NSInteger)class_id {
    NSArray* classList = [self.classInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class_id == %d", class_id]];
    return classList.lastObject;
}

- (CBDailylogInfo*)getDailylogInfoByChildId:(NSString*)child_id {
    NSArray* dailylogList = [self.dailylogInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"child_id == %@", child_id]];
    return dailylogList.lastObject;
}

- (CBAssessInfo*)getLatestAssessInfoByChildId:(NSString*)child_id {
    NSArray* objList = [self.assessInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"child_id == %@", child_id]];
    return objList.lastObject;
}

#pragma mark - RCIMReceiveMessageDelegate
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    if (!session.schoolConfig.schoolGroupChat && message.conversationType == ConversationType_GROUP) {
        //[[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:message.conversationType targetId:message.targetId];
        [[RCIMClient sharedRCIMClient] clearMessages:message.conversationType targetId:message.targetId];
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
        //NSString* schoolId = components[0];
        NSString* classlId = components[1];
        
        //CSEngine* engine = [CSEngine sharedInstance];
        CBSessionDataModel* session = [CBSessionDataModel thisSession];
        NSArray* classInfoList = session.classInfoList;
        for (CBClassInfo* classInfo in classInfoList) {
            NSURL* portrait = [[NSBundle mainBundle] URLForResource:@"v2-im-group@2x" withExtension:@"png"];
            if (classInfo.class_id == classlId.integerValue) {
                groupObj = [[RCGroup alloc] initWithGroupId:groupId
                                                  groupName:SAFE_STRING(classInfo.name)
                                                portraitUri:portrait.absoluteString];
                break;
            }
            
        }
        //        for (CBRelationshipInfo* relation in _relationshipInfoList) {
        //            if ([classlId isEqualToString:relation.child.class_id.stringValue]
        //                && [schoolId isEqualToString:relation.child.school_id.stringValue]) {
        //
        //                NSURL* portrait = [[NSBundle mainBundle] URLForResource:@"v2-im-group@2x" withExtension:@"png"];
        //
        //                groupObj = [[RCGroup alloc] initWithGroupId:groupId
        //                                                  groupName:SAFE_STRING(relation.child.class_name)
        //                                                portraitUri:portrait.absoluteString];
        //                break;
        //            }
        //        }
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

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    
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
            //NSString* login_name = [userId substringWithRange:[result rangeAtIndex:3]];
            
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
- (void)reloadTeachers:(void (^)(NSError *error))complete {
    CSLog(@"[Call] %s", __FUNCTION__);
    CSHttpClient* http = [CSHttpClient sharedInstance];
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    [http reqGetTeachersOfKindergarten:session.loginInfo.school_id.integerValue
                           withClassId:0 //gApp.engine.currentRelationship.child.classId
                               success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                   CSLog(@"[Success Start] %s", __FUNCTION__);
                                   [self updateTeacherInfosByJsonObject:dataJson];
                                   [self store];
                                   [[RCIM sharedRCIM] clearUserInfoCache];
                                   CSLog(@"[Success End] %s", __FUNCTION__);
                                   if (complete) {
                                       complete(nil);
                                   }
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   CSLog(@"[Failure] %s", __FUNCTION__);
                                   if (complete) {
                                       complete(error);
                                   }
                               }];
}

- (void)reloadRelationships:(void (^)(NSError *error))complete {
    CSLog(@"[Call] %s", __FUNCTION__);
    CSHttpClient* http = [CSHttpClient sharedInstance];
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    [http reqGetRelationshipsOfKindergarten:session.loginInfo.school_id.integerValue
                                withClassId:0 //gApp.engine.currentRelationship.child.classId
                                    success:^(AFHTTPRequestOperation *operation, id dataJson) {                                        CSLog(@"[Success Start] %s", __FUNCTION__);
                                        [self reloadRelationshipsByJsonObject:dataJson];
                                        [self store];
                                        [[RCIM sharedRCIM] clearUserInfoCache];
                                        [[RCIM sharedRCIM] clearGroupInfoCache];
                                        CSLog(@"[Success End] %s", __FUNCTION__);
                                        if (complete) {
                                            complete(nil);
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        CSLog(@"[Failure] %s", __FUNCTION__);
                                        if (complete) {
                                            complete(error);
                                        }
                                    }];
}

- (void)reloadSchoolInfo:(void (^)(NSError *error))complete {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    if (_loginInfo) {
        [http opGetSchoolInfo:_loginInfo.school_id.integerValue
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          _schoolInfo = [CBSchoolInfo instanceWithDictionary:responseObject];
                          if (complete) {
                              complete(nil);
                          }
                          
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          if (complete) {
                              complete(error);
                          }
                      }];
    }
    else if (complete) {
        complete([NSError errorWithDomain:@"com.cocobabys" code:401 userInfo:@{NSLocalizedDescriptionKey:@"Unauthorized"}]);
    }
}

- (void)reloadIneligibleClass:(void (^)(NSError *error))complete {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    if (_loginInfo) {
        CSLog(@"reloadIneligibleClass start.");
        [http reqGetiIneligibleClass:_loginInfo.uid.integerValue
                      inKindergarten:_loginInfo.school_id.integerValue
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 CSLog(@"reloadIneligibleClass success.");
                                 if ([responseObject isKindOfClass:[NSArray class]]) {
                                     _ineligibleClassList = responseObject;
                                 }
                                 
                                 if (complete) {
                                     complete(nil);
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 CSLog(@"reloadIneligibleClass failure.");
                                 if (complete) {
                                     complete(error);
                                 }
//                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                     [self reloadIneligibleClass];
//                                 });
                             }];
    }
    else if (complete) {
        complete([NSError errorWithDomain:@"com.cocobabys" code:401 userInfo:@{NSLocalizedDescriptionKey:@"Unauthorized"}]);
    }
}

- (void)reloadClassList:(void (^)(NSError *error))complete {
    if (_loginInfo) {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        CSEngine* engine = [CSEngine sharedInstance];
        
        id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            [self updateClassInfosByJsonObject:responseObject];
            [engine onLoadClassInfoList:_classInfoList];
            _opReloadClassList = nil;
            if (complete) {
                complete(nil);
            }
        };
        
        id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.response.statusCode == 401) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiUnauthorized
                                                                    object:error
                                                                  userInfo:nil];
            }
            _opReloadClassList = nil;
            if (complete) {
                complete(error);
            }
        };
        
        if (_opReloadClassList) {
            [_opReloadClassList cancel];
        }
        
        _opReloadClassList = [http opGetClassListOfKindergarten:_loginInfo.school_id.integerValue
                                                 withEmployeeId:_loginInfo.phone
                                                        success:success
                                                        failure:failure];
    }
    else if (complete) {
        complete([NSError errorWithDomain:@"com.cocobabys" code:401 userInfo:@{NSLocalizedDescriptionKey:@"Unauthorized"}]);
    }
}

@end
