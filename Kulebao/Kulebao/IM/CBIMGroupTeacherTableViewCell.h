//
//  CBIMGroupTeacherTableViewCell.h
//  youlebao
//
//  Created by WangXin on 12/16/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBRelationshipInfo.h"
#import "CBTeacherInfo.h"

@interface CBIMGroupTeacherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;

@property (nonatomic, strong) CBRelationshipInfo* relationshipInfo;
@property (nonatomic, strong) CBTeacherInfo* teacherInfo;

@end
