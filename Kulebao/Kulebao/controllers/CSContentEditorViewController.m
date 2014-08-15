//
//  CSContentEditorViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-15.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSContentEditorViewController.h"

@interface CSContentEditorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSMutableArray* _imageList;
    UIImagePickerController* _imgPicker;
}

@property (weak, nonatomic) IBOutlet UITextView *textContent;
@property (weak, nonatomic) IBOutlet UIButton *btnHideKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromCamra;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoFromGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnFinishEdit;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewImages;
@property (weak, nonatomic) IBOutlet UILabel *labTips;
- (IBAction)onBtnHideKeyboardClicked:(id)sender;
- (IBAction)onBtnPhotoFromCamraClicked:(id)sender;
- (IBAction)onBtnPhotoFromGalleryClicked:(id)sender;
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
        [self.collectionViewImages reloadData];
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

@end
