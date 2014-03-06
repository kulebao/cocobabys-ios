//
//  CSKuleMainViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleMainViewController.h"
#import "CSAppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface CSKuleMainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labSchoolName;
@property (weak, nonatomic) IBOutlet UILabel *labClassName;
@property (weak, nonatomic) IBOutlet UILabel *labChildAge;
@property (weak, nonatomic) IBOutlet UIImageView *imgChildPortrait;
- (IBAction)onBtnShowChildMenuListClicked:(id)sender;

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
    self.labClassName.text = nil;
    self.labSchoolName.text = gApp.engine.loginInfo.schoolName;
    self.labChildAge.text = nil;
    self.imgChildPortrait.layer.cornerRadius = 6.0;
    self.imgChildPortrait.clipsToBounds = YES;
    
    [gApp.engine addObserver:self
                  forKeyPath:@"currentRelationship"
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
    [gApp.engine removeObserver:self forKeyPath:@"currentRelationship"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == gApp.engine) && [keyPath isEqualToString:@"currentRelationship"]) {
        CSLog(@"currentRelationship changed.");
        [self updateUI];
    }
}

#pragma mark - UI
- (void)updateUI {
    CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
    if (childInfo) {
        [self.imgChildPortrait setImageWithURL:[gApp.engine urlFromPath:childInfo.portrait]];
        self.labClassName.text = childInfo.className;
        self.labSchoolName.text = gApp.engine.loginInfo.schoolName;
        self.labChildAge.text = childInfo.name;
    }
}

#pragma mark - Segues
- (IBAction)onBtnShowChildMenuListClicked:(id)sender {
}

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
        NSMutableArray* relationships = [NSMutableArray array];
        
        for (id relationshipJson in dataJson) {
            CSKuleRelationshipInfo* relationshipInfo = [CSKuleInterpreter decodeRelationshipInfo:relationshipJson];
            [relationships addObject:relationshipInfo];
        }
        
        gApp.engine.relationships = [NSArray arrayWithArray:relationships];
        
        CSKuleRelationshipInfo* relationshipInfo = [gApp.engine.relationships firstObject];
        gApp.engine.currentRelationship = relationshipInfo;
        
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    [gApp waitingAlert:@"更新小朋友信息"];
    [gApp.engine reqGetFamilyRelationship:gApp.engine.loginInfo.accountName
                           inKindergarten:gApp.engine.loginInfo.schoolId
                                  success:sucessHandler
                                  failure:failureHandler];
}

@end
