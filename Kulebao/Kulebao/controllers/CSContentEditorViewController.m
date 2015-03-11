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
#import "CaptureViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBCaptureToolKit.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayViewController.h"

@interface CSContentEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate> {
    NSMutableArray* _imageList;
    UIImagePickerController* _imgPicker;
    NSInteger _lastDeleteItemIndexAsked;
}

- (IBAction)onFieldDidEndOnExit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textContent;
@property (weak, nonatomic) IBOutlet UIButton *btnHideKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromCamra;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnFinishEdit;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewImages;
@property (weak, nonatomic) IBOutlet UILabel *labTips;
@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;
- (IBAction)onBtnHideKeyboardClicked:(id)sender;
- (IBAction)onBtnPhotoFromCamraClicked:(id)sender;
- (IBAction)onBtnPhotoFromGalleryClicked:(id)sender;
- (IBAction)onBtnVideoClicked:(id)sender;
- (IBAction)onBtnFinishClicked:(id)sender;

@end

@implementation CSContentEditorViewController
@synthesize delegate = _delegate;

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
    
    self.collectionViewImages.delegate = self;
    self.collectionViewImages.dataSource = self;
    
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
    
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPicker.allowsEditing = NO;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
}

- (IBAction)onBtnVideoClicked:(id)sender {
    UINavigationController *navCon = [[UINavigationController alloc] init];
    navCon.navigationBarHidden = YES;
    
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    captureViewCon.delegate = self;
    [navCon pushViewController:captureViewCon animated:NO];
    [self presentViewController:navCon animated:YES completion:nil];
}


- (IBAction)onBtnFinishClicked:(id)sender {
    [self.textContent resignFirstResponder];
    
    if ([_delegate respondsToSelector:@selector(contentEditorViewController:finishEditText:withImages:)]) {
        [_delegate contentEditorViewController:self
                                finishEditText:self.textContent.text
                                    withImages:_imageList];
    }
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

- (IBAction)onFieldDidEndOnExit:(id)sender {
}

#pragma mark - CaptureViewControllerDelegate
- (void)captureViewController:(CaptureViewController *)ctrl didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL {
    if ([_delegate respondsToSelector:@selector(contentEditorViewController:finishWithVideo:)] && outputFileURL) {
        [_delegate contentEditorViewController:self finishWithVideo:outputFileURL];
    }
}

@end
