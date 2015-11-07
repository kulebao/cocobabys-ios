//
//  CBShareIntroView.m
//  youlebao
//
//  Created by xin.c.wang on 11/6/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBShareIntroView.h"
#import <ShareSDK/ShareSDK.h>

@interface CBShareIntroView ()  <ISSShareViewDelegate>

@end

@implementation CBShareIntroView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showInView:(UIView*)view {
    [view addSubview:self];
    [view bringSubviewToFront:self];
    self.frame = view.bounds;
}

- (IBAction)onBtnBgClicked:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)onBtnShareClicked:(id)sender {
    [self doShare];
}

+ (id)instance {
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CBShareIntroView" owner:nil options:nil];
    CBShareIntroView* oView  = nibs.lastObject;
    return oView;
}

- (void)doShare {
    NSURL* shareURL = [NSURL URLWithString:@"http://dwz.cn/28iWj2"];
    NSString* shareUrlString = [shareURL absoluteString];
    shareUrlString = [shareUrlString stringByReplacingOccurrencesOfString:@"https" withString:@"http" options:0 range:NSMakeRange(0, 5)];
    
    NSString* shareTitle = @"";
    if (shareTitle.length == 0) {
        shareTitle = @"免费下载【幼乐宝】";
    }
    NSString* shareContent = @"请用浏览器打开 http://dwz.cn/28iWj2，免费下载【幼乐宝】吧！";
    NSString* shareImgPath = [[NSBundle mainBundle] pathForResource:@"v2-logo_weixin" ofType:@"png"];
    id<ISSCAttachment> shareImage = [ShareSDK imageWithPath:shareImgPath];

    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareContent
                                       defaultContent:shareContent
                                                image:shareImage
                                                title:shareTitle
                                                  url:shareUrlString
                                          description:shareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          ShareTypeWeixiTimeline,
                          ShareTypeMail,
                          ShareTypeSMS,
                          ShareTypeCopy,
                          nil];
    
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:nil
                                                              oneKeyShareList:shareList
                                                               qqButtonHidden:YES
                                                        wxSessionButtonHidden:YES
                                                       wxTimelineButtonHidden:YES
                                                         showKeyboardOnAppear:NO
                                                            shareViewDelegate:self
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:nil
                         shareList:[shareOptions oneKeyShareList]
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess) {
                                    CSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    CSLog(@"分享失败,错误码:%ld,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType{
    //[AppAppearance setNavigationBar:viewController.navigationController.navigationBar];
}

@end
