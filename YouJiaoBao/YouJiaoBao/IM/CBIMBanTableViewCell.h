//
//  CBIMBanTableViewCell.h
//  YouJiaoBao
//
//  Created by WangXin on 1/25/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBIMBanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UISwitch *switchBan;
- (IBAction)onSwitchValueChanged:(id)sender;

@end
