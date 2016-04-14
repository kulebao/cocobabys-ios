//
//  CBIMBanTableViewCell.h
//  YouJiaoBao
//
//  Created by WangXin on 1/25/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBIMBanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UISwitch *switchBan;

@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger classId;
@property (nonatomic, strong) NSString* imUserId;

- (IBAction)onSwitchValueChanged:(id)sender;

@end
