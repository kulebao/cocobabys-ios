//
//  CSKuleChatingEditorViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingEditorViewController.h"
#import "CSAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"

@interface CSKuleChatingEditorViewController () <AVAudioRecorderDelegate> {
    BOOL _isRecording;
    NSString* _fileName;
    NSString* _wavfilePath;
    NSString* _amrfilePath;
    NSTimer* _timer;
}
@property (strong, nonatomic) AVAudioRecorder* recorder;

@property (weak, nonatomic) IBOutlet UITextView *textMsgBody;
@property (weak, nonatomic) IBOutlet UIImageView *imgContentBg;
@property (weak, nonatomic) IBOutlet UIButton *btnSendVoice;
@property (weak, nonatomic) IBOutlet UIImageView *imgVoice;
- (IBAction)onBtnSendVoiceTouchDragOutside:(id)sender;
- (IBAction)onBtnSendVoiceTouchUpInside:(id)sender;
- (IBAction)onBtnSendVocieTouchDown:(id)sender;

@end

@implementation CSKuleChatingEditorViewController
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
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    [self customizeOkBarItemWithTarget:self
                                   action:@selector(onBtnSendClicked:)
                                     text:@"发送"];
    
    self.textMsgBody.backgroundColor = [UIColor clearColor];
    self.imgContentBg.image = [[UIImage imageNamed:@"v2-input_bg_家园互动.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImage* imgBtnGreenBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnSendVoice setBackgroundImage:imgBtnGreenBg forState:UIControlStateNormal];
    
    //[self.textMsgBody becomeFirstResponder];
    self.imgVoice.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_timer invalidate];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UI Actions
- (void)onBtnSendClicked:(id)sender {
    [self.textMsgBody resignFirstResponder];
    
    NSString* msgBody = [self.textMsgBody.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (msgBody.length > 0) {
        [self doSendText:msgBody];
    }
    else {
        [gApp alert:@"不能发送空消息 ^_^"];
    }
}

- (void)doSendText:(NSString*)msgBody {
    if ([_delegate respondsToSelector:@selector(willSendMsgWithText:)]) {
        [_delegate willSendMsgWithText:msgBody];
    }
}

- (void)doSendVoice:(NSData*)voiceData {
    if ([_delegate respondsToSelector:@selector(willSendMsgWithVoice:)]) {
        [_delegate willSendMsgWithVoice:voiceData];
    }
}

#pragma mark - Voice
- (void)startRecord {
    _isRecording = NO;
    
    _fileName = [self.class getCurrentTimeString];
    _wavfilePath = [self.class getPathByFileName:_fileName ofType:@"wav"];
    NSError* error = nil;
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:_wavfilePath]
                                                settings:[self.class getAudioRecorderSettingDict]
                                                   error:&error];
    if (error == nil) {
        self.recorder.meteringEnabled = YES;
        self.recorder.delegate = self;
        
        if ([self.recorder prepareToRecord]) {
            //开始
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:&error];
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            UInt32 doChangeDefault = 1;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
            
            [self.recorder record];
            _isRecording = YES;
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(onTimerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
            self.imgVoice.hidden = NO;
        }
    }
    else {
        CSLog(@"startRecord Error:%@", error);
    }
}

- (void)sendRecord {
    if (_isRecording) {
        double cTime = self.recorder.currentTime;
        [self stopRecord];
        if (cTime >= 2) {
            
            NSString* wavFilePath = [self.class getPathByFileName:_fileName ofType:@"wav"];
            NSString* amrFilePath = [self.class getPathByFileName:_fileName ofType:@"amr"];
            
            int err = [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
            
            NSData* amrData = [NSData dataWithContentsOfFile:amrFilePath];
            if (amrData.length > 0) {
                CSLog(@"准备发送语音");
                [self doSendVoice:amrData];
            }
            else {
                CSLog(@"amr 文件错误");
            }
        }
        else {
            [gApp alert:@"语音时间小于2秒，取消发送。"];
            [self.recorder deleteRecording];
        }
    }
}

- (void)cancelRecord {
    if (_isRecording) {
        [self stopRecord];
        [gApp alert:@"取消发送。"];
        [self.recorder deleteRecording];
    }
}

- (void)stopRecord {
    [self.recorder stop];
    _isRecording = NO;
    [_timer invalidate];
    self.imgVoice.hidden = YES;
}

- (IBAction)onBtnSendVoiceTouchDragOutside:(id)sender {
    //CSLog(@"%s", __FUNCTION__);
    [self cancelRecord];
}

- (IBAction)onBtnSendVoiceTouchUpInside:(id)sender {
    //CSLog(@"%s", __FUNCTION__);
    [self sendRecord];
}

- (IBAction)onBtnSendVocieTouchDown:(id)sender {
    //CSLog(@"%s", __FUNCTION__);
    [self startRecord];
}

/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}


/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0]stringByAppendingPathComponent:@"Voice"];
}

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[CSKuleChatingEditorViewController getCacheDirectory]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName{
    NSString* fileDirectory = [[CSKuleChatingEditorViewController getCacheDirectory]stringByAppendingPathComponent:_fileName];
    return fileDirectory;
}

/**
 获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}

#pragma mark - Private
- (void)onTimerFired:(id)sender {
    if (self.recorder.isRecording && !self.imgVoice.hidden) {
        [self.recorder updateMeters];
        float power = [self.recorder peakPowerForChannel:0];
        float peakPower = pow(10, (0.05 * power));
        if (peakPower < 0.05) {
            self.imgVoice.image = [UIImage imageNamed:@"mic_1.png"];
        }
        else if (peakPower < 0.15) {
            self.imgVoice.image = [UIImage imageNamed:@"mic_2.png"];
        }
        else if (peakPower < 0.3) {
            self.imgVoice.image = [UIImage imageNamed:@"mic_3.png"];
        }
        else if (peakPower < 0.7) {
            self.imgVoice.image = [UIImage imageNamed:@"mic_4.png"];
        }
        else {
            self.imgVoice.image = [UIImage imageNamed:@"mic_5.png"];
        }
    }
}

@end
