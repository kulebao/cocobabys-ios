//
//  CSKuleHistoryItemTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryItemTableViewCell.h"
#import "CSAppDelegate.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "CSEngine.h"

@interface CSKuleHistoryItemTableViewCell() {
    NSString* _shareToken;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UIView *viewImageContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGes;

@end

@implementation CSKuleHistoryItemTableViewCell
@synthesize historyInfo = _historyInfo;
@synthesize tapGes = _tapGes;
@synthesize delegate = _delegate;

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
    self.viewImageContainer.backgroundColor = [UIColor clearColor];
    self.imgPortrait.layer.cornerRadius = 4.0;
    self.btnShare.hidden = YES;
    self.imgPortrait.clipsToBounds = YES;
    
    self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self addGestureRecognizer:self.longPressGes];
    
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.viewImageContainer addGestureRecognizer:self.tapGes];
    [self.tapGes requireGestureRecognizerToFail:self.longPressGes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHistoryInfo:(CBHistoryInfo *)historyInfo {
    _historyInfo = historyInfo;
    _shareToken = nil;
    
    self.longPressGes.enabled = NO;
    
    [self updateUI];
}

- (void)updateUI {
    CBSenderInfo* senderInfo = _historyInfo.sender;
    
    self.labName.text = senderInfo.type;
    self.labContent.text = _historyInfo.content;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:_historyInfo.timestamp.doubleValue/1000];
    self.labDate.text = [fmt stringFromDate:timestamp];
    
    CGSize sz = [self.labContent sizeThatFits:CGSizeMake(230, 999)];
    self.labContent.frame = CGRectMake(70, 50, sz.width, sz.height);
    
    NSInteger index = 0;
    for (CBMediaInfo* media in _historyInfo.medium) {
        if ([media.type isEqualToString:@"image"]) {
            NSInteger vTag = 0x2000 + index;
            UIImageView* imgView = (UIImageView*)[_viewImageContainer viewWithTag:vTag];
            if (imgView == nil) {
                imgView = [[UIImageView alloc] initWithFrame:CGRectNull];
                imgView.tag = vTag;
                [_viewImageContainer addSubview:imgView];
            }
            
            imgView.backgroundColor = [UIColor clearColor];
            
            [imgView sd_setImageWithURL:[NSURL URLWithString:media.url]
                       placeholderImage:[UIImage imageNamed:@"gallery.png"]];
            
            imgView.frame = CGRectMake((index%3)* (64+16), (index / 3) * (64+10), 64, 64);
            imgView.hidden = NO;
            
            ++index;
        }
        else {
            CSLog(@"%@", media.type);
        }
    }
    
    NSInteger kBaseTag = 0x2000 + index;
    BOOL con = YES;
    for (NSInteger i=0; i<100 && con; i++) {
        NSInteger vTag = kBaseTag + i;
        UIImageView* imgView = (UIImageView*)[_viewImageContainer viewWithTag:vTag];
        if (imgView) {
            imgView.frame = CGRectNull;
            imgView.image = nil;
            imgView.hidden = YES;
        }
        else {
            con = NO;
        }
    }
    
    _viewImageContainer.frame = CGRectMake(70, 5+CGRectGetMaxY(self.labContent.frame), 230,
                                           ((index + 2) / 3 ) * 70);
    
    
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    [self.imgPortrait sd_setImageWithURL:[NSURL URLWithString:session.loginInfo.portrait]
                        placeholderImage:[UIImage imageNamed:@"chat_head_icon.gif"]];
    self.labName.text = session.loginInfo.name;
    
}

+ (CGFloat)calcHeight:(CBHistoryInfo*)historyInfo width:(CGFloat)width{
    CGFloat yy = 51;
    //CGFloat xx = 70;
    
    const CGFloat kFixedWidth = width-64-8;
    
    CGSize sz = [historyInfo.content sizeWithFont:[UIFont systemFontOfSize:14.0]
                                constrainedToSize:CGSizeMake(kFixedWidth, 9999)];
    
    yy += sz.height + 5;
    
    yy += ((historyInfo.medium.count + 2) / 3 ) * (64+8) + 2;

    //yy += 28; // share button
    
    return yy;
}

- (void)onLongPress:(UILongPressGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (ges.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(historyItemTableCellDidLongPress:)]) {
            [_delegate historyItemTableCellDidLongPress:self];
        }
    }
}

- (void)onTap:(UITapGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [ges locationInView:self.viewImageContainer];
        UIImageView* imgView = nil;
        for (UIImageView* img in self.viewImageContainer.subviews) {
            if(CGRectContainsPoint(img.frame, point)) {
                imgView = img;
                break;
            }
        }
        
        if (imgView) {
            MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
            browser.currentPhotoIndex = imgView.tag - 0x2000;
            
            NSMutableArray* photoList = [NSMutableArray array];
            
            NSInteger index = 0;
            for (CBMediaInfo* media in _historyInfo.medium) {
                if ([media.type isEqualToString:@"image"]) {
                    NSInteger vTag = 0x2000 + index;
                    UIImageView* imgView = (UIImageView*)[_viewImageContainer viewWithTag:vTag];
                    MJPhoto* photo = [MJPhoto new];
                    photo.srcImageView = imgView;
                    photo.url = [NSURL URLWithString:media.url];
                    
                    [photoList addObject:photo];
                }
            }
            
            browser.photos = photoList;
            
            [browser show];
        }
    }
}

#pragma mark - Share
- (IBAction)onBtnShareClicked:(id)sender {
}

@end
