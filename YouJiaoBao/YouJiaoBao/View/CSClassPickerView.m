//
//  CSClassPickerView.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSClassPickerView.h"
#import "CSEngine.h"
#import "CSSelectableTableViewCell.h"

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
    
    [self.tableView registerClass:[CSSelectableTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.btnOk.enabled = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0 && self.canSelectAll) {
        numberOfRows = 1;
    }
    else if (section == 1) {
        CBSessionDataModel* session = [CBSessionDataModel thisSession];
        numberOfRows = session.classInfoList.count;
    }
    return numberOfRows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSelectableTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSInteger section = indexPath.section;
    if (section == 0) {
        cell.textLabel.text = @"全校范围";
    }
    else if (section == 1) {
        CBSessionDataModel* session = [CBSessionDataModel thisSession];
        NSArray* classInfoList = session.classInfoList;
        CBClassInfo* classInfo = [classInfoList objectAtIndex:indexPath.row];
        cell.textLabel.text = classInfo.name;
        
    }
    
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
    if ([_delegate respondsToSelector:@selector(classPickerViewDidOk:withClassId:)]) {
        CBSessionDataModel* session = [CBSessionDataModel thisSession];
        NSArray* classInfoList = session.classInfoList;
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        NSInteger section = indexPath.section;
        NSNumber* classId = nil;
        if (section == 0) {
            classId = @(0);
        }
        else {
            CBClassInfo* classInfo = [classInfoList objectAtIndex:indexPath.row];
            if (classInfo) {
                classId = @(classInfo.class_id);
            }
        }
        
        if (classId) {
            [_delegate classPickerViewDidOk:self withClassId:classId];
        }
    }
}

- (IBAction)onBtnCancelClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(classPickerViewDidCancel:)]) {
        [_delegate classPickerViewDidCancel:self];
    }
}

@end
