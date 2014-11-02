//
//  CSUserOptionMenuView.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-2.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSUserOptionMenuView.h"

@interface CSUserOptionMenuView()
- (IBAction)onBtnChangeNickClicked:(id)sender;
- (IBAction)onBtnChangePhotoFromCameraClicked:(id)sender;
- (IBAction)onBtnChangePhtotFromLibraryClicked:(id)sender;

@end

@implementation CSUserOptionMenuView
@synthesize delegate = _delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)userOptionMenuView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CSUserOptionMenuView"
                                          owner:nil
                                        options:nil] firstObject];
}

- (IBAction)onBtnChangeNickClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(userOptionMenuView:selectedMenuAtIndex:)]) {
        [_delegate userOptionMenuView:self selectedMenuAtIndex:0];
    }
}

- (IBAction)onBtnChangePhotoFromCameraClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(userOptionMenuView:selectedMenuAtIndex:)]) {
        [_delegate userOptionMenuView:self selectedMenuAtIndex:1];
    }
}

- (IBAction)onBtnChangePhtotFromLibraryClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(userOptionMenuView:selectedMenuAtIndex:)]) {
        [_delegate userOptionMenuView:self selectedMenuAtIndex:2];
    }
}

@end
