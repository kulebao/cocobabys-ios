//
//  CSAssessmentEditorViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSAssessmentEditorViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface CSAssessmentEditorViewController ()
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@end

@implementation CSAssessmentEditorViewController
@synthesize childInfo = _childInfo;

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
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 600);
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

@end
