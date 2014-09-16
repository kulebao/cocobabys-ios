//
//  CSClassHeaderView.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSClassHeaderView.h"
#import "ModelClassData.h"
#import "EntityDailylogHelper.h"

@interface CSClassHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *onBtnFull;
@property (weak, nonatomic) IBOutlet UILabel *labDetail;
- (IBAction)onBtnFullClicked:(id)sender;

@end

@implementation CSClassHeaderView
@synthesize modelData = _modelData;

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
   return [[[NSBundle mainBundle] loadNibNamed:@"CSClassHeaderView"
                                         owner:nil
                                       options:nil] firstObject];
}

- (IBAction)onBtnFullClicked:(id)sender {
    _modelData.expand = !_modelData.expand;
    [self reloadData];
    
    if ([_delegate respondsToSelector:@selector(classHeaderViewExpandChanged:)]) {
        [_delegate classHeaderViewExpandChanged:self];
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
            if ([EntityDailylogHelper isDailylogOfToday:childInfo.dailylog] && childInfo.dailylog.noticeType.integerValue == kKuleNoticeTypeCheckIn) {
                recordNum++;
            }
        }
        
        self.labTitle.text = [NSString stringWithFormat:@"%@", _modelData.classInfo.name];
        self.labDetail.text = [NSString stringWithFormat:@"(实到%d人/应到%d人)", recordNum, _modelData.childrenList.count];
        self.imgIcon.highlighted = _modelData.expand;
    }
}

@end
