//
//  CSClassHeaderView.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSClassHeaderView.h"
#import "ModelClassData.h"

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

- (void)setModelData:(ModelBaseData *)modelData {
    _modelData = modelData;
    [self reloadData];
}

- (void)reloadData {
    if (_modelData) {
        self.imgIcon.highlighted = _modelData.expand;
        self.labTitle.text = [_modelData title];
        self.labDetail.text = [_modelData detail];
    }
}
@end
