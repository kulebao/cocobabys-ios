//
//  CSAssignmentItemTableViewCell.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-10.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSAssignmentItemTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "CSUtils.h"
#import "CSEngine.h"
#import "EntityClassInfoHelper.h"

@interface CSAssignmentItemTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labPublisher;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumb;

@end

@implementation CSAssignmentItemTableViewCell
@synthesize assignmentInfo = _assignmentInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.labPublisher.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setAssignmentInfo:(EntityAssignmentInfo *)assignmentInfo {
    _assignmentInfo = assignmentInfo;
    
    if (_assignmentInfo) {
        self.labTitle.text = _assignmentInfo.title;
        self.labContent.text = _assignmentInfo.content;
        if (_assignmentInfo.iconUrl.length > 0) {
            [self.imgThumb setImageWithURL:[NSURL URLWithString:_assignmentInfo.iconUrl]];
        }
        else {
            self.imgThumb.image = nil;
        }
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:(_assignmentInfo.timestamp.longLongValue / 1000.0)];
        
        if (_assignmentInfo.classId.integerValue > 0) {
            EntityClassInfo* classInfo = [EntityClassInfoHelper queryEntityWithClassId:_assignmentInfo.classId.integerValue];
            self.labDate.text = [NSString stringWithFormat:@"%@  %@", [CSUtils stringFromDateStyle1:date], classInfo.name];
        }
        else {
            self.labDate.text = [NSString stringWithFormat:@"%@ %@", [CSUtils stringFromDateStyle1:date], @""];
        }
    }
}
@end
