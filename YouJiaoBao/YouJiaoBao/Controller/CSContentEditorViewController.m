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
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TZImagePickerController.h"
#import "CSAppDelegate.h"

enum {
    kPictureMaxCount = 9
};

@interface CSContentEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate,
    UIActionSheetDelegate, TZImagePickerControllerDelegate> {
    NSMutableArray* _imageList;
    UIImagePickerController* _imgPicker;
    TZImagePickerController* _elcPicker;
    NSInteger _lastDeleteItemIndexAsked;
}

- (IBAction)onFieldDidEndOnExit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textContent;
@property (weak, nonatomic) IBOutlet UIButton *btnHideKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromCamra;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnFinishEdit;
@property (weak, nonatomic) IBOutlet UILabel *labTips;
@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;
@property (weak, nonatomic) IBOutlet UIImageView *imgContentBg;
- (IBAction)onBtnHideKeyboardClicked:(id)sender;
- (IBAction)onBtnPhotoFromCamraClicked:(id)sender;
- (IBAction)onBtnPhotoFromGalleryClicked:(id)sender;
- (IBAction)onBtnVideoClicked:(id)sender;
- (IBAction)onBtnFinishClicked:(id)sender;

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
    //[self customizeBackBarItem];

    self.imgContentBg.image = [[UIImage imageNamed:@"v2-input_bg_家园互动.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    //[self setNeedsStatusBarAppearanceUpdate];
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
    
    if (!self.singleImage && _imageList.count >= kPictureMaxCount) {
        [gApp alert:@"最多只能选择9张图片"];
        return;
    }
    
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
#if 0
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _imgPicker.allowsEditing = NO;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
#else
    if (_elcPicker == nil) {
        _elcPicker = [[TZImagePickerController alloc] initWithMaxImagesCount:kPictureMaxCount
                                                                    delegate:self];
        _elcPicker.allowPickingOriginalPhoto = NO;
        
        if (self.singleImage) {
            //Set the maximum number of images to select, defaults to 4
            _elcPicker.maxImagesCount = 1;
            //For multiple image selection, display and return selected order of images
        }
        else {
            //Set the maximum number of images to select, defaults to 4
            _elcPicker.maxImagesCount = kPictureMaxCount;
            //For multiple image selection, display and return selected order of images
        }
    }
    
    //Present modally
    [self presentViewController:_elcPicker animated:YES completion:nil];
#endif
}

- (IBAction)onBtnVideoClicked:(id)sender {
    [self.textContent resignFirstResponder];
    
    UIActionSheet* actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"录像", @"选择视频文件", nil];
    [actSheet showInView:self.view];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        //录像
        //检查相机模式是否可用
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"sorry, no camera or camera is unavailable!!!");
            return;
        }
        
#if TARGET_IPHONE_SIMULATOR
#else
        _imgPicker = [[UIImagePickerController alloc] init];
        _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        @try{
            // exception:cameraCaptureMode 1 not available because mediaTypes does contain public.movie
            // _imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            _imgPicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            _imgPicker.videoMaximumDuration = 90; // 90s
            _imgPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        }
        @catch(NSException *exception) {
            CSLog(@"exception:%@", exception);
        }
        @finally {
            
        }
        _imgPicker.allowsEditing = NO;
        _imgPicker.delegate = self;
        [self presentViewController:_imgPicker animated:YES completion:^{
            
        }];
#endif
        /*
        _imgPicker = [[UIImagePickerController alloc] init];
        _imgPicker.delegate = self;
        _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        _imgPicker.videoMaximumDuration = 90; // 90s
        _imgPicker.videoQuality = UIImagePickerControllerQualityType640x480;
        _imgPicker.allowsEditing = NO;
        [self presentViewController:_imgPicker animated:YES completion:^{
            
        }];
         */
    }
    else if (buttonIndex == (actionSheet.firstOtherButtonIndex+1)) {
        //选择视频文件
        
        _imgPicker = [[UIImagePickerController alloc] init];
        _imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _imgPicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
        _imgPicker.videoMaximumDuration = 90; // 90s
        _imgPicker.videoQuality = UIImagePickerControllerQualityType640x480;
        _imgPicker.allowsEditing = NO;
        _imgPicker.delegate = self;
        [self presentViewController:_imgPicker animated:YES completion:^{
            
        }];
    }
}


- (IBAction)onBtnFinishClicked:(id)sender {
    [self.textContent resignFirstResponder];
    NSString* content = [self.textContent.text trim];
    if (content.length == 0 && _imageList.count==0) {
        [gApp alert:@"发布内容不能为空"];
    }
    else if ([_delegate respondsToSelector:@selector(contentEditorViewController:finishEditText:withImages:)]) {
        [_delegate contentEditorViewController:self
                                finishEditText:content
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
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.image = [_imageList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    /*
     {
     UIImagePickerControllerMediaType = "public.movie";
     UIImagePickerControllerMediaURL = "file:///private/var/mobile/Containers/Data/Application/70F97512-9F16-482D-9A25-B60F8BCF6550/tmp/capture-T0x170067940.tmp.epvD4C/capturedvideo.MOV";
     }
     
     {
     UIImagePickerControllerMediaType = "public.movie";
     UIImagePickerControllerMediaURL = "file:///private/var/mobile/Containers/Data/Application/CBFBF882-4F26-4156-B703-A1D668479B7C/tmp/trim.8DA2F943-52D8-4A1F-AECA-BFD81B27B1E1.MOV";
     UIImagePickerControllerReferenceURL = "assets-library://asset/asset.MOV?id=19AA1392-795A-4EA2-9AF3-816D4E4C2521&ext=MOV";
     }
     
     {
     UIImagePickerControllerMediaType = "public.image";
     UIImagePickerControllerOriginalImage = "<UIImage: 0x170498380> size {2448, 3264} orientation 3 scale 1.000000";
     ..........
     
     }
     */
    
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage* img = info[UIImagePickerControllerOriginalImage];
        if (img) {
            if (self.singleImage) {
                [_imageList removeAllObjects];
            }
            
            [_imageList addObject:img];
            [self.gmGridView reloadData];
        }
    }
    else if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL* fileURL = info[UIImagePickerControllerMediaURL];
        [self performSelectorInBackground:@selector(doCompressMovFile:) withObject:fileURL];
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (picker == _imgPicker) {
                                       _imgPicker = nil;
                                   }
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (picker == _imgPicker) {
        _imgPicker = nil;
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - TZImagePickerControllerDelegate
/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets{
    if ([picker isEqual:_elcPicker]) {
        [_imageList removeAllObjects];
        [_imageList addObjectsFromArray:photos];
        [self.gmGridView reloadData];
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (picker == _elcPicker) {
                                       _elcPicker = nil;
                                   }
                               }];
}

/// User finish picking video,
/// 用户选择好了视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
}

#pragma mark - 
- (void)doCompressMovFile:(NSURL*)movFileURL {
    CSLog(@"%s %@", __FUNCTION__, movFileURL);
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movFileURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    CSLog(@"%@", compatiblePresets);
    
    if([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        //NSString* mp4Path = [movFileURL.absoluteString.stringByDeletingPathExtension stringByAppendingPathExtension:@"mp4"];
        //mp4Path = [NSTemporaryDirectory() stringByAppendingPathComponent:[mp4Path.pathComponents lastObject]];
        NSString* mp4Path = @"cocobabys-tmp.mp4";
        mp4Path = [NSTemporaryDirectory() stringByAppendingPathComponent:[mp4Path.pathComponents lastObject]];
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:mp4Path error:nil];
        
        exportSession.outputURL = [NSURL fileURLWithPath: mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [gApp waitingAlert:@"处理视频中"];
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    CSLog(@"AVAssetExportSessionStatusFailed! %@", exportSession.error);
                    [self performSelectorOnMainThread:@selector(showAlertOnMain:)
                                           withObject:exportSession.error
                                        waitUntilDone:NO];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    CSLog(@"AVAssetExportSessionStatusCancelled!");
                    [self performSelectorOnMainThread:@selector(showAlertOnMain:)
                                           withObject:exportSession.error
                                        waitUntilDone:NO];
                    break;
                case AVAssetExportSessionStatusCompleted:
                    CSLog(@"AVAssetExportSessionStatusCompleted!");
                    [self performSelectorOnMainThread:@selector(hideAlertOnMain)
                                           withObject:nil
                                        waitUntilDone:NO];
                    [self performSelectorOnMainThread:@selector(convertFinish:)
                                           withObject:exportSession.outputURL
                                        waitUntilDone:NO];
                    break;
                default:
                    [self performSelectorOnMainThread:@selector(hideAlertOnMain)
                                           withObject:nil
                                        waitUntilDone:NO];
                    break;
            }
        }];
    }
}

- (void)showAlertOnMain:(NSError*)error {
    [gApp alert:error.localizedDescription withTitle:error.localizedFailureReason];
}

- (void)hideAlertOnMain {
    [gApp hideAlert];
}

- (void)convertFinish:(NSURL*)mp4FileURL {
    if ([_delegate respondsToSelector:@selector(contentEditorViewController:finishEditText:withVideo:)] && mp4FileURL) {
        [_delegate contentEditorViewController:self
                                finishEditText:self.textContent.text
                                     withVideo:mp4FileURL];
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
        cell.deleteButtonIcon = [UIImage imageNamed:@"delete_cell"];
        cell.deleteButtonOffset = CGPointMake(-10, -10);
        
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.userInteractionEnabled = YES;
        imgView.clipsToBounds = YES;
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

@end
