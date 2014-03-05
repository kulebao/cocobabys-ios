//
//  CSKuleMainViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleMainViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleMainViewController ()

- (IBAction)onBtnSettingsClicked:(id)sender;
- (IBAction)onBtnNoticeClicked:(id)sender;
- (IBAction)onBtnRecipeClicked:(id)sender;
- (IBAction)onBtnCheckinInfoClicked:(id)sender;
- (IBAction)onBtnScheduleInfoClicked:(id)sender;
- (IBAction)onBtnHomeworkClicked:(id)sender;
- (IBAction)onBtnChatingClicked:(id)sender;

@end

@implementation CSKuleMainViewController

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
    
    [gApp.engine addObserver:self
                  forKeyPath:@"currentChild"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    
    [self performSelector:@selector(getRelationshipInfos) withObject:nil afterDelay:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [gApp.engine removeObserver:self forKeyPath:@"currentChild"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == gApp.engine) && [keyPath isEqualToString:@"currentChild"]) {
        CSLog(@"currentChild changed.");
    }
}

#pragma mark - Segues
- (IBAction)onBtnSettingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.settings" sender:nil];
}

- (IBAction)onBtnNoticeClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.notice" sender:nil];
}

- (IBAction)onBtnRecipeClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.recipe" sender:nil];
}

- (IBAction)onBtnCheckinInfoClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.checkin" sender:nil];
}

- (IBAction)onBtnScheduleInfoClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.schedule" sender:nil];
}

- (IBAction)onBtnHomeworkClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.homework" sender:nil];
}

- (IBAction)onBtnChatingClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.chating" sender:nil];
}

#pragma mark - Private
- (void)getRelationshipInfos {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        /*
         [ {
         "parent" : {
         "id" : "2_1394011814045",
         "school_id" : 93740362,
         "name" : "鑫哥",
         "phone" : "18782242007",
         "portrait" : "/assets/images/portrait_placeholder.png",
         "gender" : 0,
         "birthday" : "1980-01-01"
         },
         "child" : {
         "child_id" : "1_1393768956259",
         "name" : "袋鼠小朋友",
         "nick" : "袋鼠小朋",
         "birthday" : "2009-01-01",
         "gender" : 1,
         "portrait" : "/assets/images/portrait_placeholder.png",
         "class_id" : 777888,
         "className" : "苹果班"
         },
         "card" : "2133123232",
         "relationship" : "爸爸"
         }, {
         "parent" : {
         "id" : "2_1394011814045",
         "school_id" : 93740362,
         "name" : "鑫哥",
         "phone" : "18782242007",
         "portrait" : "/assets/images/portrait_placeholder.png",
         "gender" : 0,
         "birthday" : "1980-01-01"
         },
         "child" : {
         "child_id" : "1_1390359054366",
         "name" : "烦烦烦",
         "nick" : "烦烦烦",
         "birthday" : "2009-01-01",
         "gender" : 1,
         "portrait" : "http://cocobabys.oss.aliyuncs.com/child_photo/93740362/1_1390359054366/1_1390359054366.jpg",
         "class_id" : 777999,
         "className" : "香蕉班"
         },
         "card" : "3333222323",
         "relationship" : "奶奶"
         } ]
         */
        
        CSLog(@"%@", dataJson);
        
        gApp.engine.currentChild = [CSKuleChildInfo new];
        
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    [gApp waitingAlert:@"更新小朋友信息"];
    [gApp.engine reqGetFamilyRelationship:gApp.engine.bindInfo.accountName
                           inKindergarten:gApp.engine.bindInfo.schoolId
                                  success:sucessHandler
                                  failure:failureHandler];
}

@end
