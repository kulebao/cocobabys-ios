//
//  CSStudentPickerHeaderView.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSStudentPickerHeaderView.h"
#import "ModelClassData.h"
#import "EntityDailylogHelper.h"

@interface CSStudentPickerHeaderView()

@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *onBtnFull;
@property (weak, nonatomic) IBOutlet UILabel *labDetail;
- (IBAction)onBtnFullClicked:(id)sender;
- (IBAction)onBtnCheckClicked:(id)sender;

@end

@implementation CSStudentPickerHeaderView
@synthesize modelData = _modelData;
@synthesize sharedSelectedChildren = _sharedSelectedChildren;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

+ (instancetype)defaultClassHeaderView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CSStudentPickerHeaderView"
                                          owner:nil
                                        options:nil] firstObject];
}

- (IBAction)onBtnFullClicked:(id)sender {
    _modelData.expand = !_modelData.expand;
    [self reloadData];
    
    if ([_delegate respondsToSelector:@selector(studentPickerHeaderViewExpandChanged:)]) {
        [_delegate studentPickerHeaderViewExpandChanged:self];
    }
}

- (IBAction)onBtnCheckClicked:(id)sender {
    self.btnCheck.selected = !self.btnCheck.selected;
    for (EntityChildInfo* childInfo in _modelData.childrenList) {
        if (self.btnCheck.selected) {
            [_sharedSelectedChildren addObject:childInfo];
        }
        else {
            [_sharedSelectedChildren removeObject:childInfo];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(studentPickerHeaderViewSelectionhanged:)]) {
        [_delegate studentPickerHeaderViewSelectionhanged:self];
    }
}

- (void)setModelData:(ModelClassData *)modelData {
    _modelData = modelData;
    [self reloadData];
}

- (void)reloadData {
    if (_modelData) {
        NSInteger recordNum = 0;
        for (EntityChildInfo* childInfo in _modelData.childrenList) {
            if ([_sharedSelectedChildren containsObject:childInfo]) {
                recordNum++;
            }
        }
        
        self.labTitle.text = [NSString stringWithFormat:@"%@ (选中%d人/共%d人)", _modelData.classInfo.name, recordNum, _modelData.childrenList.count];
        self.labDetail.text = nil;
        self.imgIcon.highlighted = _modelData.expand;
        
        if (recordNum == _modelData.childrenList.count) {
            self.btnCheck.selected = YES;
        }
        else {
            self.btnCheck.selected = NO;
        }
    }
}

@end
