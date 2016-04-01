//
//  CSChildRelationshipItemTableViewCell.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSChildRelationshipItemTableViewCell.h"
#import "CSAppDelegate.h"
#import "CBRelationshipInfo.h"

@interface CSChildRelationshipItemTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnMakeCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSendSms;
- (IBAction)onBtnMakeCallClicked:(id)sender;
- (IBAction)onBtnSendSmsClicked:(id)sender;

@end

@implementation CSChildRelationshipItemTableViewCell
@synthesize relationship = _relationship;

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onBtnMakeCallClicked:(id)sender {
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    
    NSString* action = [NSString stringWithFormat:@"tel://%@", _relationship.parent.phone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:action]]) {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:action]]) {
            [app alert:@"无法拨打此号码。"];
        }
    }
    else {

        [app alert:@"本设备不支持拨打电话。"];
    }
}

- (IBAction)onBtnSendSmsClicked:(id)sender {
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    
    NSString* action = [NSString stringWithFormat:@"sms://%@", _relationship.parent.phone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:action]]) {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:action]]) {
            [app alert:@"无法向此号码发送短信。"];
        }
    }
    else {
        
        [app alert:@"本设备不支持发送短信。"];
    }
}

- (void)setRelationship:(CBRelationshipInfo *)relationship {
    _relationship = relationship;
//    self.labName.text =  [NSString stringWithFormat:@"%@ %@", relationship.parentInfo.name, relationship.relationship];
    NSMutableAttributedString* mutableAttrString = [[NSMutableAttributedString alloc] init];
    NSAttributedString* name = [[NSAttributedString alloc] initWithString:relationship.parent.name attributes:@{NSForegroundColorAttributeName: [UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
    [mutableAttrString appendAttributedString:name];
    
    [mutableAttrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    
    NSAttributedString* relation = [[NSAttributedString alloc] initWithString:relationship.relationship attributes:@{NSForegroundColorAttributeName: [UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
    [mutableAttrString appendAttributedString:relation];
    
    self.labName.attributedText = mutableAttrString;
    
    self.labPhone.text = relationship.parent.phone;
    
    if (relationship.parent.phone.length > 0) {
        self.btnMakeCall.hidden = NO;
        self.btnSendSms.hidden = NO;
    }
    else {
        self.btnMakeCall.hidden = YES;
        self.btnSendSms.hidden = YES;
    }
}

@end
