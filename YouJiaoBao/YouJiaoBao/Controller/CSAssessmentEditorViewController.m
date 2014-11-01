//
//  CSAssessmentEditorViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSAssessmentEditorViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EDStarRating.h"

@interface CSAssessmentEditorViewController () <EDStarRatingProtocol>
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating0;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating1;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating2;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating3;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating4;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating5;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating6;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating7;
@property (weak, nonatomic) IBOutlet UIImageView *imgText1Bg;
@property (weak, nonatomic) IBOutlet UITextView *textView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgText2Bg;
@property (weak, nonatomic) IBOutlet UITextView *textView2;

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
    self.imgText1Bg.image = [[UIImage imageNamed:@"bg-2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgText2Bg.image = [[UIImage imageNamed:@"bg-2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    self.textView1.frame = self.imgText1Bg.frame;
    self.textView2.frame = self.imgText2Bg.frame;
    
    NSArray* starRatings = @[self.starRating0,
                             self.starRating1,
                             self.starRating2,
                             self.starRating3,
                             self.starRating4,
                             self.starRating5,
                             self.starRating6,
                             self.starRating7];
    
    for (EDStarRating* starRating in starRatings) {
        
        starRating.frame = CGRectMake(0, 64, 64, 28);
        starRating.backgroundColor  = [UIColor clearColor];
        starRating.maxRating = 3.0;
        starRating.delegate = self;
        starRating.horizontalMargin = 2.0;
        starRating.editable=YES;
        starRating.rating = 3;
        starRating.displayMode=EDStarRatingDisplayFull;

        starRating.starImage = [UIImage imageNamed:@"star_grey.png"];
        starRating.starHighlightedImage = [UIImage imageNamed:@"star_red.png"];
        
        [starRating setNeedsDisplay];
        starRating.tintColor = [UIColor orangeColor];
    }
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

-(void)starsSelectionChanged:(EDStarRating*)control rating:(float)rating {
    if (rating < 1) {
        control.rating = 1;
    }
}
@end
