//
//  CSKuleChatingTableCell.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingTableCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "CSEngine.h"

@implementation CSKuleChatingTableCell
@synthesize msg = _msg;
@synthesize delegate = _delegate;
@synthesize longPressGes = _longPressGes;
@synthesize tapGes = _tapGes;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(longPressHandle:)];
        
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tapHandle:)];
        [self.tapGes requireGestureRecognizerToFail:self.longPressGes];
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

+ (CGFloat)calcHeightForMsg:(EntityTopicMsg*)msg {
    CGFloat height = 0.0;
    if (msg.mediaUrl.length > 0) {
        if ([msg.mediaType isEqualToString:@"voice"]) {
            height = 65;
        }
        else {
            height = 95;
        }
    }
    else {
        CGSize sz = [self textSize:msg.content];
        height = sz.height + 35;
        height = MAX(height, 60);
    }
    
    height += 12; // sender name;
    
    return height;
}


+ (CGSize)textSize:(NSString*)text {
    CGSize sz = CGSizeMake(200.0, 999.0);
    CGSize textSz = [text sizeWithFont:[UIFont systemFontOfSize:14.0]
                     constrainedToSize:sz];
    
    textSz.width = MAX(textSz.width, 32);
    textSz.height = MAX(textSz.height, 32);
    
    return textSz;
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
    if ([_msg.mediaType isEqualToString:@"voice"]) {
        
        if ([_delegate respondsToSelector:@selector(chatingTableCell:playVoice:)]) {
            [_delegate chatingTableCell:self playVoice:_msg];
        }
    }
    else if ([_msg.mediaType isEqualToString:@"image"]) {
        UIImageView* imgView = (UIImageView*)[self.contentView viewWithTag:102];
        
        MJPhoto* photo = [MJPhoto new];
        photo.url = [NSURL URLWithString:_msg.mediaUrl];
        photo.srcImageView = imgView;
        
        MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
        browser.photos = @[photo];
        [browser show];
    }
}

- (void)tapVoiceHandle:(UITapGestureRecognizer *)tap {
    if ([_msg.mediaType isEqualToString:@"voice"]) {
        
        if ([_delegate respondsToSelector:@selector(chatingTableCell:playVoice:)]) {
            [_delegate chatingTableCell:self playVoice:_msg];
        }
    }
}


- (void)longPressHandle:(UILongPressGestureRecognizer*)ges {

    if (ges.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (ges.state == UIGestureRecognizerStateBegan) {
            NSLog(@"longPressHandle");
        if ([_delegate respondsToSelector:@selector(chatingTableCellDidLongPress:)]) {
            [_delegate chatingTableCellDidLongPress:self];
        }
    }
    
//    [self becomeFirstResponder];
//    UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"Flag" action:@selector(flag:)];
//    UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"Approve" action:@selector(approve:)];
//    UIMenuItem *deny = [[UIMenuItem alloc] initWithTitle:@"Deny" action:@selector(deny:)];
//    UIMenuController *menu = [UIMenuController sharedMenuController];
//    [menu setMenuItems:[NSArray arrayWithObjects:flag, approve, deny, nil]];
//    [menu setTargetRect:self.contentView.frame inView:self];
//    [menu setMenuVisible:YES animated:YES];
}

- (void)setMsg:(EntityTopicMsg*)msg {
    _msg = msg;
    
    CSEngine* engine = [CSEngine sharedInstance];
    
    if ([msg.senderId isEqualToString:engine.loginInfo.uid]) {
        self.longPressGes.enabled = YES;
    }
    else {
        self.longPressGes.enabled = NO;
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
