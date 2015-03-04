//
//  CSContentEditorViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-15.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSContentEditorViewController.h"
#import "GMGridView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "CSAppDelegate.h"
#import "ELCImagePickerController.h"

@interface CSContentEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, ELCImagePickerControllerDelegate, UINavigationControllerDelegate, GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate> {
    NSMutableArray* _imageList;
    UIImagePickerController* _imgPicker;
    ELCImagePickerController* _elcPicker;
    NSInteger _lastDeleteItemIndexAsked;
}

@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UITextField *fieldTitle;
@property (weak, nonatomic) IBOutlet UITextView *textContent;
@property (weak, nonatomic) IBOutlet UIButton *btnHideKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromCamra;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnFinishEdit;
@property (weak, nonatomic) IBOutlet UILabel *labTips;
@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;
- (IBAction)onBtnHideKeyboardClicked:(id)sender;
- (IBAction)onBtnPhotoFromCamraClicked:(id)sender;
- (IBAction)onBtnPhotoFromGalleryClicked:(id)sender;
- (IBAction)onBtnFinishClicked:(id)sender;
- (IBAction)onFieldDidEndOnExit:(id)sender;

@end

@implementation CSContentEditorViewController
@synthesize delegate = _delegate;
@synthesize singleImage = _singleImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customizeBackBarItem];
    
    //    self.gmGridView.centerGrid = YES;
    self.gmGridView.actionDelegate = self;
    self.gmGridView.dataSource = self;
    //    self.gmGridView.transformDelegate = self;
    //    self.gmGridView.sortingDelegate = self;
    self.gmGridView.enableEditOnLongPress = YES;
    self.gmGridView.disableEditOnEmptySpaceTap = YES;
    self.gmGridView.clipsToBounds = YES;
    
    self.textContent.delegate = self;
    
    self.btnHideKeyboard.hidden = YES;
    
    _imageList = [NSMutableArray array];
    
    self.textContent.text = nil;
    self.labTips.hidden = (self.textContent.text.length > 0);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnHideKeyboardClicked:(id)sender {
    [self.textContent resignFirstResponder];
}

- (IBAction)onBtnPhotoFromCamraClicked:(id)sender {
    [self.textContent resignFirstResponder];
    
#if TARGET_IPHONE_SIMULATOR
#else
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPicker.allowsEditing = NO;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
#endif
}

- (IBAction)onBtnPhotoFromGalleryClicked:(id)sender {
    [self.textContent resignFirstResponder];
    
    _elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    if (self.singleImage) {
        //Set the maximum number of images to select, defaults to 4
        _elcPicker.maximumImagesCount = 1;
        //For multiple image selection, display and return selected order of images
        _elcPicker.onOrder = NO;
    }
    else {
        //Set the maximum number of images to select, defaults to 4
        _elcPicker.maximumImagesCount = 9;
        //For multiple image selection, display and return selected order of images
        _elcPicker.onOrder = YES;
    }
    
    _elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    _elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    _elcPicker.imagePickerDelegate = self;
    
    //Present modally
    [self presentViewController:_elcPicker animated:YES completion:nil];
}

- (IBAction)onFieldDidEndOnExit:(id)sender {
    [self.textContent becomeFirstResponder];
}

- (IBAction)onBtnFinishClicked:(id)sender {
    [self.fieldTitle resignFirstResponder];
    [self.textContent resignFirstResponder];
    
    if ([self checkInput]) {
        if ([_delegate respondsToSelector:@selector(contentEditorViewController:finishEditText:withTitle:withImages:)]) {
            [_delegate contentEditorViewController:self
                                    finishEditText:self.textContent.text
                                         withTitle:self.fieldTitle.text
                                        withImages:_imageList];
        }
    }
    else {
        
    }
}

- (BOOL)checkInput {
    BOOL ok = YES;
    
    if (self.fieldTitle && self.fieldTitle.text.length == 0) {
        ok = NO;
        [self.fieldTitle becomeFirstResponder];
        [gApp alert:@"请填写标题"];
    }
    else if (self.textContent.text.length == 0) {
        ok = NO;
        [gApp alert:@"请填写内容"];
    }
    
    return ok;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.btnHideKeyboard.hidden = NO;
    
    self.labTips.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.btnHideKeyboard.hidden = YES;
    
    self.labTips.hidden = (self.textContent.text.length > 0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSContentEditorImageItemCell"
                                                                           forIndexPath:indexPath];
    
    UIImageView* imgView = (UIImageView*)[cell viewWithTag:1234];
    imgView.image = [_imageList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* img = info[UIImagePickerControllerOriginalImage];
    if (img) {
        if (self.singleImage) {
            [_imageList removeAllObjects];
        }
        
        [_imageList addObject:img];
        [self.gmGridView reloadData];
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (picker == _imgPicker) {
                                       _imgPicker = nil;
                                   }
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    if (picker == _imgPicker) {
        _imgPicker = nil;
    }
}

#pragma mark - ELCImagePickerControllerDelegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infoList {
    if ([picker isEqual:_elcPicker]) {
        for (NSDictionary* info in infoList) {
            UIImage* img = info[UIImagePickerControllerOriginalImage];
            if (img) {
                if (self.singleImage) {
                    [_imageList removeAllObjects];
                }
                
                [_imageList addObject:img];
                [self.gmGridView reloadData];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (picker == _elcPicker) {
                                       _elcPicker = nil;
                                   }
                               }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    if (picker == _elcPicker) {
        _elcPicker = nil;
    }
}

#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return _imageList.count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(80, 80);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    // CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.tag = 0x1234;
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //[cell addSubview:imgView];
        cell.contentView = imgView;
    }
    
    UIImageView* imgView = (UIImageView* )cell.contentView;
    imgView.image = [_imageList objectAtIndex:index];
    
    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index {
    return YES;
}

#pragma mark - GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    NSLog(@"Did tap at index %d", position);
    
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = position;
    // browser.hidenToolbar = YES;
    
    NSMutableArray* photoList = [NSMutableArray array];
    
    NSInteger index = 0;
    for (UIImage* img in _imageList) {
        MJPhoto* photo = [MJPhoto new];
        photo.image = img;
        
        GMGridViewCell* cell = [gridView cellForItemAtIndex:index];
        photo.srcImageView = (UIImageView*)cell.contentView;
        [photoList addObject:photo];
        
        ++index;
    }
    browser.photos = photoList;
    
    [browser show];
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView {
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除照片" message:@"您将删除这张照片，确认吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    
    [alert show];
    
    _lastDeleteItemIndexAsked = index;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [_imageList removeObjectAtIndex:_lastDeleteItemIndexAsked];
        [_gmGridView removeObjectAtIndex:_lastDeleteItemIndexAsked
                           withAnimation:GMGridViewItemAnimationFade];
    }
    
    [self.gmGridView setEditing:NO animated:YES];
}

@end
