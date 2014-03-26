//
//  CSKuleAssessViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-19.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleAssessViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleAssessViewController () {
    NSArray* _assessModules;
    NSMutableArray* _assesses;
}
@property (weak, nonatomic) IBOutlet UIView *viewTipsContainer;
@property (weak, nonatomic) IBOutlet UIView *viewCommentsContainer;
@property (weak, nonatomic) IBOutlet UILabel *labTips;
@property (weak, nonatomic) IBOutlet UILabel *labPublisher;
@property (weak, nonatomic) IBOutlet UILabel *labComments;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
- (IBAction)onBtnPreviousClicked:(id)sender;
- (IBAction)onBtnNextClicked:(id)sender;

@end

@implementation CSKuleAssessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    [self setupAssessModules];
    
    NSArray* assessModuleInfo = [_assessModules firstObject];
    if (assessModuleInfo) {
        NSString* tips = assessModuleInfo[3];
        self.labTips.text = tips;
    }
    else {
        self.labTips.text = nil;
    }
    
    self.labPublisher.text = nil;
    self.labComments.text = nil;
    
    _assesses = [NSMutableArray array];
    [self doGetAssesses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Private
- (void) setupAssessModules {
    /*
     情绪： 情绪稳定、适应集体生活、乐于亲近老师和同学。
     进餐： 能愉快的进餐、不挑食、能吃完一份饭菜。
     睡觉： 能安静的就寝、正确地穿脱衣帽和鞋袜、按时起床。
     集体活动：乐于参加各种集体活动、注意力集中、能积极发言。
     游戏：喜欢玩游戏、能与同学分享玩具，学习并遵守游戏规则。
     锻炼：喜欢参加体育活动、能坚持锻炼身体、并注意运动安全。
     自我服务：能自己收拾整理玩具和用具、自己入厕。
     礼貌：对人有礼貌、会主动使用礼貌用语、尊重他人、不打扰别人。
     */
    
    _assessModules =
    @[
      @[@"情绪", @"assess-emotion.png", @(kKuleAssessEmotion),
        @"情绪：情绪稳定、适应集体生活、乐于亲近老师和同学。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      
      @[@"进餐", @"assess-dining.png", @(kKuleAssessDining),
        @"进餐：能愉快的进餐、不挑食、能吃完一份饭菜。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      
      @[@"睡觉", @"assess-rest.png", @(kKuleAssessRest),
        @"睡觉：能安静的就寝、正确地穿脱衣帽和鞋袜、按时起床。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
        
      @[@"集体活动", @"assess-activity.png", @(kKuleAssessActivity),
        @"集体：乐于参加各种集体活动、注意力集中、能积极发言。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      
      @[@"游戏", @"assess-game.png", @(kKuleAssessGame),
        @"游戏：喜欢玩游戏、能与同学分享玩具，学习并遵守游戏规则。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      
      @[@"锻炼", @"assess-exercise.png", @(kKuleAssessExercise),
        @"锻炼：喜欢参加体育活动、能坚持锻炼身体、并注意运动安全。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      
      @[@"自我服务", @"assess-selfcare.png", @(kKuleAssessSelfcare),
        @"自我服务：能自己收拾整理玩具和用具、自己入厕。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      
      @[@"礼貌", @"assess-manner.png", @(kKuleAssessManner),
        @"礼貌：对人有礼貌、会主动使用礼貌用语、尊重他人、不打扰别人。",
        [[UIImageView alloc] initWithFrame:CGRectNull]],
      ];
    
    const CGSize kModuleIconSize = CGSizeMake(71, 71);
    const CGSize kModuleRatingSize = CGSizeMake(71, 23);
    const NSInteger kModuleColumns = 4;
    //const NSInteger kModuleRows = (kKuleModuleSize + MAX((kKuleModuleSize -1), 0)) / kModuleColumns;
    const CGFloat kModuleTopMagin = 45;
    const CGFloat kModuleRatingTopMagin = 5;
    const CGFloat kModuleRowSpace = 10;
    const CGFloat kModuleColumnSpace = (self.view.bounds.size.width - kModuleIconSize.width*kModuleColumns)/(kModuleColumns*2.0);
    
    CGFloat xx = 0.0;
    CGFloat yy = 0.0;
    NSInteger row = 0;
    NSInteger col = 0;
    
    NSInteger index = 0;
    for (NSArray* assessModuleInfo in _assessModules) {
        row = index / kModuleColumns;
        col = index % kModuleColumns;
        xx = kModuleColumnSpace + col * (kModuleIconSize.width+2*kModuleColumnSpace);
        yy = kModuleTopMagin + row*(kModuleIconSize.height+kModuleRatingSize.height+kModuleRatingTopMagin+kModuleRowSpace);
        
        //NSString* name = assessModuleInfo[0];
        NSString* image = assessModuleInfo[1];
        //NSInteger type = [assessModuleInfo[2] integerValue];
        //NSString* tips = assessModuleInfo[3];
        UIImageView* ratingImageView = assessModuleInfo[4];
        
        UIButton* btnIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnIcon setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        btnIcon.tag = index;
        btnIcon.frame = CGRectMake(xx, yy, kModuleIconSize.width, kModuleIconSize.height);
        [self.view addSubview:btnIcon];
        [btnIcon addTarget:self action:@selector(onBtnAssessesClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        yy += kModuleIconSize.height+kModuleRatingTopMagin;
        ratingImageView.frame = CGRectMake(xx, yy, kModuleRatingSize.width, kModuleRatingSize.height);
        ratingImageView.image = [UIImage imageNamed:@"rating-bg.png"];
        [self.view addSubview:ratingImageView];
        
        index++;
    }
    
    yy += kModuleRatingSize.height + kModuleRowSpace;
    
    CGRect tipsFrame = self.viewTipsContainer.frame;
    tipsFrame = CGRectMake(tipsFrame.origin.x, yy, tipsFrame.size.width, tipsFrame.size.height);
    self.viewTipsContainer.frame = tipsFrame;
    
    yy += tipsFrame.size.height + kModuleRowSpace;
    CGRect commentsFrame = self.viewCommentsContainer.frame;
    commentsFrame = CGRectMake(commentsFrame.origin.x, yy, commentsFrame.size.width, commentsFrame.size.height);
    self.viewCommentsContainer.frame = commentsFrame;
}

- (void)doGetAssesses {
    CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
    if (childInfo) {
        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            NSMutableArray* assessInfos = [NSMutableArray array];

            for (id assessInfoJson in dataJson) {
                CSKuleAssessInfo* assessInfo = [CSKuleInterpreter decodeAssessInfo:assessInfoJson];
                [assessInfos addObject:assessInfo];
            }
            
            if (assessInfos.count > 0) {
                [_assesses addObjectsFromArray:assessInfos];
                [gApp hideAlert];
                
                [self updateWithAssessInfo:[assessInfos firstObject]];
            }
            else {
                [gApp alert:@"没有更多评价"];
            }
        };
        
        FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
            CSLog(@"failure:%@", error);
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp waitingAlert:@"获取评价中"];
        [gApp.engine reqGetAssessesOfChild:childInfo
                            inKindergarten:gApp.engine.loginInfo.schoolId
                                      from:-1
                                        to:-1
                                      most:-1
                                   success:sucessHandler
                                   failure:failureHandler];
    }
}

- (void)updateWithAssessInfo:(CSKuleAssessInfo*)assessInfo {
    for (NSArray* assessModuleInfo in _assessModules) {
        //NSString* name = assessModuleInfo[0];
        //NSString* image = assessModuleInfo[1];
        NSInteger type = [assessModuleInfo[2] integerValue];
        //NSString* tips = assessModuleInfo[3];
        UIImageView* ratingImageView = assessModuleInfo[4];
        
        switch (type) {
            case kKuleAssessEmotion:
                ratingImageView.image = [self ratingImage:assessInfo.emotion];
                break;
            case kKuleAssessRest:
                ratingImageView.image = [self ratingImage:assessInfo.rest];
                break;
            case kKuleAssessDining:
                ratingImageView.image = [self ratingImage:assessInfo.dining];
                break;
            case kKuleAssessActivity:
                ratingImageView.image = [self ratingImage:assessInfo.activity];
                break;
            case kKuleAssessGame:
                ratingImageView.image = [self ratingImage:assessInfo.game];
                break;
            case kKuleAssessSelfcare:
                ratingImageView.image = [self ratingImage:assessInfo.selfcare];
                break;
            case kKuleAssessManner:
                ratingImageView.image = [self ratingImage:assessInfo.manner];
                break;
            case kKuleAssessExercise:
                ratingImageView.image = [self ratingImage:assessInfo.exercise];
                break;
            default:
                ratingImageView.image = [self ratingImage:0];
                break;
        }
        
        self.labComments.text = assessInfo.comments;
        self.labPublisher.text = [NSString stringWithFormat:@"来自 %@ 的评语:", assessInfo.publisher];
    }
}

- (UIImage*)ratingImage:(NSInteger)rate {
    UIImage* img = nil;
    
    NSArray* imgNames = @[@"rating-bg.png", @"rating-1star.png", @"rating-2stars.png", @"rating-3stars.png"];
    
    if (rate >=0 && rate < imgNames.count) {
        img = [UIImage imageNamed:imgNames[rate]];
    }
    
    return img;
}

#pragma mark - UI Actions
- (void)onBtnAssessesClicked:(UIButton*)sender {
    NSInteger index = sender.tag;
    if (index < _assessModules.count) {
        NSArray* assessModuleInfo = _assessModules[index];
        //NSString* name = assessModuleInfo[0];
        //NSString* image = assessModuleInfo[1];
        //NSInteger type = [assessModuleInfo[2] integerValue];
        NSString* tips = assessModuleInfo[3];
        //UIImageView* ratingImageView = assessModuleInfo[4];
        
        self.labTips.text = tips;
    }
    else {
        self.labTips.text = nil;
        self.labPublisher.text = nil;
        self.labComments.text = nil;
    }
}

- (IBAction)onBtnPreviousClicked:(id)sender {
}

- (IBAction)onBtnNextClicked:(id)sender {
}

@end
