//
//  CSKuleCommon.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#ifndef Kulebao_CSKuleCommon_h
#define Kulebao_CSKuleCommon_h

#define kKuleAppleID    @"854211863"

// 性别
enum KuleGender {
    kKuleGenderFemale = 0,
    kKuleGenderMale = 1,
};

// 设备类型
enum KuleDeviceType{
    kKuleDeviceTypeAndroid = 3,
    kKuleDeviceTypeiPhone = 4,
};

// 通知类型
enum KuleNoticeType {
    kKuleNoticeTypeCheckOut = 0,
    kKuleNoticeTypeCheckIn = 1,
    //早上上车，早上下车，下午上车，下午下车
    kKuleNoticeTypeCheckInCarMorning = 10,
    kKuleNoticeTypeCheckOutCarMorning = 11,
    kKuleNoticeTypeCheckInCarAfternoon = 12,
    kKuleNoticeTypeCheckOutCarAfternoon = 13,
};

// 其他
enum {
    // 宝宝昵称长度
    kKuleNickMaxLength = 4,
};

// 模块类别
enum KuleModule {
    kKuleModuleNews,        // 校园公告
    kKuleModuleRecipe,      // 每周食谱
    kKuleModuleCheckin,     // 接送信息
    kKuleModuleSchedule,    // 课程表
    kKuleModuleAssignment,  // 亲子作业
    kKuleModuleChating,     // 家园互动
    kKuleModuleAssess,      // 在园表现
    kKuleModuleHistory,     // 成长经历
    kKuleModuleCCTV,        // 看宝贝
    kKuleModuleBus,         // 校车
    kKuleModuleSize,        // -模块数量-统计
};

// 评价类别
enum KuleAssess {
    kKuleAssessEmotion,     // 情绪
    kKuleAssessDining,      // 进餐
    kKuleAssessRest,        // 睡觉
    kKuleAssessActivity,    // 集体活动
    kKuleAssessGame,        // 游戏
    kKuleAssessExercise,    // 锻炼
    kKuleAssessSelfcare,    // 自我服务
    kKuleAssessManner,      // 礼貌
    kKuleAssessSize,
};

// From Android.
typedef enum {
    PHONE_NUM_IS_INVALID = 1100,
    PHONE_NUM_IS_FIRST_USE = 1101,
    PHONE_NUM_IS_ALREADY_BIND = 1102,
    
    AUTH_CODE_IS_VALID = 1130,
    AUTH_CODE_IS_INVALID = 1131,
    
    GET_AUTH_CODE_SUCCESS = 1140,
    GET_AUTH_CODE_FAIL = 1141,
    
    NET_WORK_INVALID = 1201,
    AUTHCODE_COUNTDOWN_GO = 1210,
    AUTHCODE_COUNTDOWN_OVER = 1211,
    SERVER_INNER_ERROR = 1221,
    SERVER_BUSY = 1225,
    
    PHONE_NUM_INPUT_ERROR = 1301,
    AUTH_CODE_INPUT_ERROR = 1302,
    
    PWD_FORMAT_ERROR = 1310,
    OLD_PWD_FORMAT_ERROR = 1311,
    NEW_PWD_FORMAT_ERROR = 1312,
    
    CHANGE_PWD_SUCCESS = 1320,
    OLD_PWD_NOT_EQUAL = 1322,
    
    LOADING_SUCCESS = 1400,
    LOADING_TO_GUARD = 1401,
    LOADING_TO_MAIN = 1402,
    LOADING_TO_VALIDATEPHONE = 1403,
    
    RESET_PWD_SUCCESS = 1410,
    RESET_PWD_FAILED = 1411,
    
    BIND_SUCCESS = 1500,
    BIND_FAILED = 1501,
    
    UPLOAD_SUCCESS = 1505,
    UPLOAD_FAILED = 1506,
    
    GET_SWIPE_RECORD_SUCCESS = 1510,
    GET_SWIPE_RECORD_FAILED = 1511,
    
    GET_COOKBOOK_FAILED = 1525,
    GET_COOKBOOK_SUCCESS = 1526,
    GET_COOKBOOK_LATEST = 1527,
    
    GET_NOTICE_SUCCESS = 1540,
    GET_NOTICE_FAILED = 1541,
    
    LOGIN_SUCCESS = 1600,
    PWD_INCORRECT = 1601,
    
    UPDATE_SCHOOL_INFO = 1610,
    SCHOOL_INFO_IS_LATEST = 1611,
    GET_SCHOOL_INFO_FAILED = 1612,
    
    UPDATE_CHILDREN_INFO = 1620,
    CHILDREN_INFO_IS_LATEST = 1621,
    GET_CHILDREN_INFO_FAILED = 1622,
    
    GET_SCHEDULE_FAILED = 1625,
    GET_SCHEDULE_SUCCESS = 1626,
    GET_SCHEDULE_LATEST = 1627,
    
    DOWNLOAD_IMG_SUCCESS = 1630,
    DOWNLOAD_IMG_FAILED = 1631,
    
    HAS_NEW_VERSION = 1700,
    HAS_NO_VERSION = 1701,
    
    SUCCESS = 2000,
    FAIL = 2001,
    
}KubaoEventType;

#endif
