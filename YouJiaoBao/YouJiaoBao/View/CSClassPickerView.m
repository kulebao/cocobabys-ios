//
//  CSClassPickerView.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSClassPickerView.h"
#import "CSEngine.h"
#import "EntityClassInfo.h"

@interface CSClassPickerView () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
- (IBAction)onBtnOkClicked:(id)sender;
- (IBAction)onBtnCancelClicked:(id)sender;

@end

@implementation CSClassPickerView
@synthesize delegate = _delegate;

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

+ (instancetype)defaultClassPickerView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CSClassPickerView"
                                          owner:nil
                                        options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.btnOk.enabled = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[CSEngine sharedInstance] classInfoList] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSArray* classInfoList = [[CSEngine sharedInstance] classInfoList];
    EntityClassInfo* classInfo = [classInfoList objectAtIndex:indexPath.row];
    cell.textLabel.text = classInfo.name;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.btnOk.enabled = YES;
}

- (void)reset {
    self.btnOk.enabled = NO;
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (IBAction)onBtnOkClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(classPickerViewDidOk:withClassInfo:)]) {
        NSArray* classInfoList = [[CSEngine sharedInstance] classInfoList];
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        EntityClassInfo* classInfo = [classInfoList objectAtIndex:indexPath.row];
        
        [_delegate classPickerViewDidOk:self withClassInfo:classInfo];
    }
}

- (IBAction)onBtnCancelClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(classPickerViewDidCancel:)]) {
        [_delegate classPickerViewDidCancel:self];
    }
}

@end
