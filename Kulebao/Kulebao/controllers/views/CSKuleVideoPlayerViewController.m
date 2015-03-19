//
//  CSKuleVideoPlayerViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/3/20.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleVideoPlayerViewController.h"
#import "CSVideoView.h"

@interface CSKuleVideoPlayerViewController ()
@property (weak, nonatomic) IBOutlet CSVideoView *videoView;

@end

@implementation CSKuleVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoView.videoURL = self.videoURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
