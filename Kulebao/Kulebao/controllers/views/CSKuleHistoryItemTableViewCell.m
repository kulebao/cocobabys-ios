//
//  CSKuleHistoryItemTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryItemTableViewCell.h"
#import "CSAppDelegate.h"
#import "EntityMediaInfoHelper.h"
#import "EntitySenderInfoHelper.h"
#import "EntityHistoryInfoHelper.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "UIImageView+WebCache.h"

#import <ShareSDK/ShareSDK.h>

@interface CSKuleHistoryItemTableViewCell() <ISSShareViewDelegate> {
    NSString* _shareToken;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UIView *viewImageContainer;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGes;

@end

@implementation CSKuleHistoryItemTableViewCell
@synthesize historyInfo = _historyInfo;
@synthesize tapGes = _tapGes;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.viewImageContainer.backgroundColor = [UIColor clearColor];
    self.imgPortrait.layer.cornerRadius = 4.0;
    self.imgPortrait.clipsToBounds = YES;
    
    self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self addGestureRecognizer:self.longPressGes];
    
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.viewImageContainer addGestureRecognizer:self.tapGes];
    [self.tapGes requireGestureRecognizerToFail:self.longPressGes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHistoryInfo:(EntityHistoryInfo *)historyInfo {
    _historyInfo = historyInfo;
    _shareToken = nil;
    
    if ([_historyInfo.sender.senderId isEqualToString:gApp.engine.currentRelationship.parent.parentId]) {
        self.longPressGes.enabled = YES;
    }
    else {
        self.longPressGes.enabled = NO;
    }
    
    [self updateUI];
}

- (void)updateUI {
    EntitySenderInfo* senderInfo = (EntitySenderInfo*)_historyInfo.sender;
    
    self.labName.text = senderInfo.type;
    self.labContent.text = _historyInfo.content;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:_historyInfo.timestamp.doubleValue/1000];
    self.labDate.text = [fmt stringFromDate:timestamp];
    
    CGSize sz = [self.labContent sizeThatFits:CGSizeMake(230, 999)];
    self.labContent.frame = CGRectMake(70, 50, sz.width, sz.height);
    
    NSInteger index = 0;
    for (CSKuleMediaInfo* media in _historyInfo.medium) {
        NSInteger vTag = 0x2000 + index;
        UIImageView* imgView = (UIImageView*)[_viewImageContainer viewWithTag:vTag];
        if (imgView == nil) {
            imgView = [[UIImageView alloc] initWithFrame:CGRectNull];
            imgView.tag = vTag;
            [_viewImageContainer addSubview:imgView];
        }
        
        imgView.backgroundColor = [UIColor clearColor];

        if ([media.type isEqualToString:@"image"]) {
            [imgView sd_setImageWithURL:[NSURL URLWithString:media.url]
                    placeholderImage:[UIImage imageNamed:@"gallery.png"]];
        }
//        else if([media.type isEqualToString:@"video"]) {
//            imgView.backgroundColor = [UIColor blackColor];
//            imgView.image = [UIImage imageNamed:@"video_icon.png"];
//        }
        else {
            CSLog(@"%@", media.type);
        }
        
        imgView.frame = CGRectMake((index%3)* (64+16), (index / 3) * (64+10), 64, 64);
        imgView.hidden = NO;
        
        ++index;
    }
    
    NSInteger kBaseTag = 0x2000 + index;
    BOOL con = YES;
    for (NSInteger i=0; i<100 && con; i++) {
        NSInteger vTag = kBaseTag + i;
        UIImageView* imgView = (UIImageView*)[_viewImageContainer viewWithTag:vTag];
        if (imgView) {
            imgView.frame = CGRectNull;
            imgView.image = nil;
            imgView.hidden = YES;
        }
        else {
            con = NO;
        }
    }
    
    _viewImageContainer.frame = CGRectMake(70, 5+CGRectGetMaxY(self.labContent.frame), 230,
                                           ((_historyInfo.medium.count + 2) / 3 ) * 70);
    
    
    
    
    // Get Sender avatar and name.
    CSKuleSenderInfo* sender = [CSKuleSenderInfo new];
    sender.type = senderInfo.type;
    sender.senderId = senderInfo.senderId;
    
    [gApp.engine reqGetSenderProfileOfKindergarten:gApp.engine.loginInfo.schoolId
                                        withSender:sender
                                          complete:^(id obj) {
                                              NSURL* qiniuImgUrl = nil;
                                              NSString* senderName = nil;
                                              if ([obj isKindOfClass:[CSKuleEmployeeInfo class]]) {
                                                  CSKuleEmployeeInfo* employeeInfo = obj;
                                                  if (employeeInfo.portrait.length > 0) {
                                                      qiniuImgUrl = [gApp.engine urlFromPath:employeeInfo.portrait];
                                                  }
                                                  
                                                  senderName = employeeInfo.name;
                                              }
                                              else if ([obj isKindOfClass:[CSKuleParentInfo class]]) {
                                                  CSKuleParentInfo* parentInfo = obj;
                                                  if (parentInfo.portrait.length > 0) {
                                                      qiniuImgUrl = [gApp.engine urlFromPath:parentInfo.portrait];
                                                  }
                                                  else {
                                                      qiniuImgUrl = [gApp.engine urlFromPath:gApp.engine.currentRelationship.child.portrait];
                                                  }
                                                  
                                                  if ([sender.senderId isEqualToString:gApp.engine.currentRelationship.parent.parentId]) {
                                                      senderName = @"我";
                                                  }
                                                  else {
                                                      senderName = parentInfo.name;
                                                  }
                                              }
                                              
                                              if (qiniuImgUrl) {
                                                  qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/64/h/64"];
                                                  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:qiniuImgUrl];
                                                  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
                                                  request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                                                  [self.imgPortrait setImageWithURLRequest:request
                                                                     placeholderImage:[UIImage imageNamed:@"chat_head_icon.png"]
                                                                              success:nil
                                                                              failure:nil];
                                              }
                                              else {
                                                  self.imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.png"];
                                              }
                                              
                                              self.labName.text = senderName;
                                          }];

}

+ (CGFloat)calcHeight:(CSKuleHistoryInfo*)historyInfo {
    CGFloat yy = 50;
    //CGFloat xx = 70;
    
    const CGFloat kFixedWidth = 230.0;
    
    CGSize sz = [historyInfo.content sizeWithFont:[UIFont systemFontOfSize:14.0]
                                constrainedToSize:CGSizeMake(kFixedWidth, 9999)];
    
    yy += sz.height + 5;
    
    yy += ((historyInfo.medium.count + 2) / 3 ) * (64+10) + 2;
    
    yy += 28; // share button
    
    return yy;
}

- (void)onLongPress:(UILongPressGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (ges.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(historyItemTableCellDidLongPress:)]) {
            [_delegate historyItemTableCellDidLongPress:self];
        }
    }
}

- (void)onTap:(UITapGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [ges locationInView:self.viewImageContainer];
        UIImageView* imgView = nil;
        for (UIImageView* img in self.viewImageContainer.subviews) {
            if(CGRectContainsPoint(img.frame, point)) {
                imgView = img;
                break;
            }
        }
        
        if (imgView) {
            MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
            browser.currentPhotoIndex = imgView.tag - 0x2000;
            
            NSMutableArray* photoList = [NSMutableArray array];
            
            NSInteger index = 0;
            for (CSKuleMediaInfo* media in _historyInfo.medium) {
                NSInteger vTag = 0x2000 + index;
                UIImageView* imgView = (UIImageView*)[_viewImageContainer viewWithTag:vTag];
                MJPhoto* photo = [MJPhoto new];
                photo.srcImageView = imgView;
                photo.url = [NSURL URLWithString:media.url];
                
                [photoList addObject:photo];
            }
            
            browser.photos = photoList;
            
            [browser show];
        }
    }
}

#pragma mark - Share
- (IBAction)onBtnShareClicked:(id)sender {
    [self doGetShareToken];
}

- (void)doGetShareToken {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        if (dataJson) {
            _shareToken = [dataJson objectForKey:@"token"];
            if (_shareToken.length > 0) {
                [self performSelector:@selector(doShare:) withObject:_shareToken afterDelay:0.1];
            }
        }
        
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
    };
    
    [gApp waitingAlert:@"分享中" withTitle:@"请稍候"];
    [gApp.engine reqGetShareTokenOfKindergarten:gApp.engine.loginInfo.schoolId
                                    withChildId:gApp.engine.currentRelationship.child.childId
                                   withRecordId:self.historyInfo.uid.integerValue
                                        success:sucessHandler
                                        failure:failureHandler];
}

- (void)doShare:(NSString*)shareToken {
    NSString* sharePath = [NSString stringWithFormat:@"/s/%@/", shareToken];
    NSURL* shareURL = [gApp.engine urlFromPath:sharePath];
    
    NSString* shareTitle = @"";
    if (shareTitle.length == 0) {
        shareTitle = @"[成长经历]分享";
    }
    NSString* shareContent = self.historyInfo.content;
    NSString* shareImgPath = [[NSBundle mainBundle] pathForResource:@"v2-logo_weixin" ofType:@"png"];
    id<ISSCAttachment> shareImage = [ShareSDK imageWithPath:shareImgPath];

    for (CSKuleMediaInfo* media in _historyInfo.medium) {
        if ([media.type isEqualToString:@"image"]) {
            shareImage = [ShareSDK imageWithUrl:media.url];
            break;
        }
        else if ([media.type isEqualToString:@"video"]) {
            //shareImage = [ShareSDK imageWithUrl:media.url];
            break;
        }
    }
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareContent
                                       defaultContent:shareContent
                                                image:shareImage
                                                title:shareTitle
                                                  url:[shareURL absoluteString]
                                          description:shareContent
                                            mediaType:SSPublishContentMediaTypeApp];
    
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          ShareTypeWeixiTimeline,
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
