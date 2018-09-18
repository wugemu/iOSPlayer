//
//  AliyunPlayerVodPlayViewController.m
//  AliyunPlayerDemo
//
//  Created by 王凯 on 2017/9/21.
//  Copyright © 2017年 shiping chen. All rights reserved.
//

#import "AliyunPlayerVodPlayViewController.h"
#import "AliyunPlayMessageShowView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>
#import "Reachability.h"

#define URLSTRING  @"http://player.alicdn.com/video/aliyunmedia.mp4"
#import "UIAliyunSlider.h"

@interface AliyunPlayerVodPlayViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *bufferLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightTimeLabel;
@property (weak, nonatomic) IBOutlet UIAliyunSlider *progressSlider;
@property (weak, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *displayModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *variableSpeedModel;
@property (nonatomic, strong) Reachability *reachability;


@property (nonatomic, assign)BOOL isRunTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong)UIActivityIndicatorView *indicationrView;

@property (nonatomic, strong) AliVcMediaPlayer* mediaPlayer;
@property (nonatomic, strong) AliyunPlayMessageShowView *showMessageView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *rotatedSegment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *mirrorSegment;




@end

@implementation AliyunPlayerVodPlayViewController

#pragma mark - 展示log界面
-(AliyunPlayMessageShowView *)showMessageView{
    if (!_showMessageView){
        _showMessageView = [[AliyunPlayMessageShowView alloc] init];
        _showMessageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
        _showMessageView.alpha = 1;
    }
    
    return _showMessageView;
}

#pragma mark - naviBar
- (void)InitNaviBar{
    NSString *backString = NSLocalizedString(@"Back",nil);
    NSString *logString = NSLocalizedString(@"Log",nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logString style:UIBarButtonItemStylePlain target:self action:@selector(LogButtonItemCliceked:)];
}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    
    sender.enabled = NO;
    
    [self.mediaPlayer stop];
    [self.mediaPlayer destroy];
    self.mediaPlayer = nil;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self removePlayerObserver];
    
    [self.navigationController popViewControllerAnimated:YES];
    sender.enabled = YES;
}

- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self InitNaviBar];
    
    self.indicationrView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicationrView.frame = CGRectMake(0, 0, 100, 100);
    self.indicationrView.center = self.mediaPlayer.view.center;
    self.indicationrView.color = [UIColor clearColor];
    //将这个控件加到父容器中。
    [self.view addSubview:self.indicationrView];
    
    /***************集成部分*******************/
    self.mediaPlayer = [[AliVcMediaPlayer alloc] init];
    [self.mediaPlayer create:self.contentView];
    
    self.mediaPlayer.circlePlay = YES;
    self.mediaPlayer.mediaType = MediaType_AUTO;
    self.mediaPlayer.timeout = 25000;//毫秒
    self.mediaPlayer.dropBufferDuration = 8000;
    /****************************************/
    
    
    //通知
    [self addPlayerObserver];
    
    //初始设置
    self.isRunTime = YES;
    self.volumeSlider.value = self.mediaPlayer.volume;
    self.brightnessSlider.value = self.mediaPlayer.brightness;
    self.variableSpeedModel.selectedSegmentIndex = 1;
    
    //按钮状态
    self.stopButton.enabled = NO;
    self.pauseButton.enabled = NO;
    self.resumeButton.enabled = NO;
//    self.replayButton.enabled = NO;
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
    
    // Do any additional setup after loading the view.
}

- (void)becomeActive{
   
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    if (status == NotReachable) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"notreachable", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"clicked_ok", nil), nil];
        [av show];
    }else if (status == ReachableViaWiFi){
        if (self.mediaPlayer){
            if (!self.isRunTime) {
                [self resume];
            }
        }
    }else if (status == ReachableViaWWAN ){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_show_title_cancel",nil) otherButtonTitles:NSLocalizedString(@"clicked_ok",nil), nil];
        
        [av show];
    }else{
        
    }
    
    self.isRunTime = YES;
}


- (void)resignActive{

    if (self.mediaPlayer){
        if (self.mediaPlayer.isPlaying) {
            [self pause];
            self.isRunTime = NO;
        }
    }
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.indicationrView.center = self.mediaPlayer.view.center;
    self.showMessageView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)networkStateChange{
    if(!self.mediaPlayer) return;
//    [self networkChangePop:NO];
}

-(BOOL) networkChangePop:(BOOL)isShow{
    BOOL ret = NO;
    
    switch ([self.reachability currentReachabilityStatus]) {
        case NotReachable:
        {
            ret = YES;
            if (isShow) {
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"notreachable", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"clicked_ok", nil), nil];
                [av show];
            }
            
        }
            break;
        case ReachableViaWiFi:
            
            break;
        case ReachableViaWWAN:
        {
            ret = YES;
            if (self.mediaPlayer.isPlaying) {
                [self pause];
            }
            
            if (isShow) {
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_show_title_cancel",nil) otherButtonTitles:NSLocalizedString(@"clicked_ok",nil), nil];
                
                [av show];
            }
            
            
        }
            break;
        default:
            break;
    }
    
    return ret;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1://ok
        {
            if(self.mediaPlayer){
                if (self.mediaPlayer.isPlaying) {
                    [self resume];
                }else{
                    [self start];
                }
            }
            
            
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - add NSNotification
-(void)addPlayerObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoPrepared:)
                                                 name:AliVcMediaPlayerLoadDidPreparedNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoFinish:)
                                                 name:AliVcMediaPlayerPlaybackDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoError:)
                                                 name:AliVcMediaPlayerPlaybackErrorNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnSeekDone:)
                                                 name:AliVcMediaPlayerSeekingDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnStartCache:)
                                                 name:AliVcMediaPlayerStartCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnEndCache:)
                                                 name:AliVcMediaPlayerEndCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoStop:)
                                                 name:AliVcMediaPlayerPlaybackStopNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoFirstFrame:)
                                                 name:AliVcMediaPlayerFirstFrameNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCircleStart:)
                                                 name:AliVcMediaPlayerCircleStartNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];

}
#pragma mark - remove NSNotification
-(void)removePlayerObserver
{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerLoadDidPreparedNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackErrorNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerSeekingDidFinishNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerStartCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerEndCachingNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackStopNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerFirstFrameNotification object:self.mediaPlayer];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerCircleStartNotification object:self.mediaPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - receive
- (void)OnVideoPrepared:(NSNotification *)notification{
    NSTimeInterval duration = self.mediaPlayer.duration/1000;
    self.progressSlider.maximumValue = duration;
    self.progressSlider.value = self.mediaPlayer.currentPosition;
    self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",duration]];
    
    [self.showMessageView addTextString:NSLocalizedString(@"onVideoPrepared",nil)];
}

- (void)onVideoFirstFrame :(NSNotification *)notification{
    [self.indicationrView stopAnimating];
    [self.showMessageView addTextString:NSLocalizedString(@"onVideoFirstFrame",nil)];
    
}
- (void)OnVideoError:(NSNotification *)notification{
    NSDictionary* userInfo = [notification userInfo];
    NSString* errorMsg = [userInfo objectForKey:@"errorMsg"];
    NSNumber* errorCodeNumber = [userInfo objectForKey:@"error"];
    NSLog(@"%@-%@",errorMsg,errorCodeNumber);
    
    [self.showMessageView addTextString:[NSString stringWithFormat:@"%@-%@",errorCodeNumber,errorMsg]];
    
}
- (void)OnVideoFinish:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnVideoFinish",nil)];
}
- (void)OnSeekDone:(NSNotification *)notification{
    self.isRunTime = YES;
    [self.showMessageView addTextString:NSLocalizedString(@"OnSeekDone",nil)];
    
}
- (void)OnStartCache:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnStartCache",nil)];
    
}
- (void)OnEndCache:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnEndCache",nil)];
    
}

- (void)onVideoStop:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnVideoStop",nil)];
    
}

- (void)onCircleStart:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"onCircleStart",nil)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - clicked
- (IBAction)onClicked:(UIButton *)sender {
    
    switch (sender.tag) {
        case 201://播放
        {
            [self.indicationrView startAnimating];
            if ([self networkChangePop:YES]) {
            [self.indicationrView stopAnimating];
                return;
            }
            [self.mediaPlayer setRenderRotate:self.rotatedSegment.selectedSegmentIndex*90];
            [self.mediaPlayer setRenderMirrorMode:self.mirrorSegment.selectedSegmentIndex];
            
            [self start];
        }
            break;
            
        case 202://停止
        {
            [self stop];
        }
            break;
            
        case 203://暂停
        {
            [self pause];
        }
            break;
            
        case 204://继续
        {
            [self resume];
        }
            break;
            
        case 205://重播
        {
            [self.indicationrView startAnimating];
            [self replay];
        }
            break;
            
        default:
            break;
    }
}

- (void)start{
    //本地视频
//    NSURL *fileUrl = [NSURL fileURLWithPath:@""];

    //网络视频
    NSURL * strUrl = nil;
    if (self.tempUrl&&self.tempUrl.length>0) {
        strUrl = [NSURL URLWithString:self.tempUrl];
    }else{
        strUrl = [NSURL URLWithString:URLSTRING];
    }
    

    NSURL *url = strUrl;
    self.mediaPlayer.playSpeed = self.variableSpeedModel.selectedSegmentIndex;
    AliVcMovieErrorCode err = [self.mediaPlayer prepareToPlay:url];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
        [self.indicationrView stopAnimating];
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"play failed,error code is", nil),(int)err]];
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTime:) userInfo:nil repeats:YES];
    [self.timer fire];
    [self.mediaPlayer play];
    
    [self.showMessageView addTextString:NSLocalizedString(@"log_start_play", nil)];
    
    self.playButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.pauseButton.enabled = YES;
    self.resumeButton.enabled = NO;
}

- (void)pause{
    AliVcMovieErrorCode err =[self.mediaPlayer pause];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"pause failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"pause failed,error code is", nil),(int)err]];
        return;
    }
    [self.showMessageView addTextString:NSLocalizedString(@"log_pause_play", nil)];
    self.playButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.pauseButton.enabled = NO;
    self.resumeButton.enabled = YES;
}

- (void)resume{
    AliVcMovieErrorCode err = [self.mediaPlayer play];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"resume failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"resume failed,error code is", nil),(int)err]];
        return;
    }
    
    NSString *pauseplay = NSLocalizedString(@"log_resume_play", nil);
    [self.showMessageView addTextString:pauseplay];
    self.playButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.pauseButton.enabled = YES;
    self.resumeButton.enabled = NO;
}

- (void)replay{
    
    AliVcMovieErrorCode err = [self.mediaPlayer stop];
    if(err != ALIVC_SUCCESS) {
        [self.indicationrView stopAnimating];
        NSLog(@"stop failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"stop failed,error code is", nil),(int)err]];
        return;
    }
    [self.showMessageView addTextString:NSLocalizedString(@"log_re_play", nil)];
    
    //本地视频
//    NSURL *fileUrl = [NSURL fileURLWithPath:@""];
    //网络视频
    NSURL * strUrl = nil;
    if (self.tempUrl&&self.tempUrl.length>0) {
        strUrl = [NSURL URLWithString:self.tempUrl];
    }else{
        strUrl = [NSURL URLWithString:URLSTRING];
    }
    
    NSURL *url = strUrl;
    self.mediaPlayer.playSpeed = self.variableSpeedModel.selectedSegmentIndex;
    err = [self.mediaPlayer prepareToPlay:url];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"preprare failed,error code is %d",(int)err);
        
        if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"prepare failed,error code is", nil),(int)err]];
        return;
    }
    self.progressSlider.value = 0.0;
    self.leftTimeLabel.text= @"00:00:00";
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runTime:) userInfo:nil repeats:YES];
    [self.timer fire];
    [self.mediaPlayer play];
    
    self.playButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.pauseButton.enabled = YES;
    self.resumeButton.enabled = NO;
}

- (void)stop{
    AliVcMovieErrorCode err = [self.mediaPlayer stop];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"stop failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"stop failed,error code is", nil),(int)err]];
        return;
    }
    
    err = [self.mediaPlayer reset];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"reset failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"reset failed,error code is", nil),(int)err]];
        return;
    }
    
    [self.showMessageView addTextString:NSLocalizedString(@"log_stop_play", nil)];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.progressSlider.value = 0.0;
    self.leftTimeLabel.text= @"00:00:00";
    
    self.playButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.pauseButton.enabled = NO;
    self.resumeButton.enabled = NO;
}

- (void)runTime:(NSTimer *)timer{
    
    self.bufferLabel.text = [NSString stringWithFormat:@"buffer:%@",[self getMMSSFromSS:[NSString stringWithFormat:@"%f",round(self.mediaPlayer.bufferingPostion/1000)]]];
    
    if (self.isRunTime&&self.mediaPlayer){
        self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",self.mediaPlayer.currentPosition/1000]];
        [self.progressSlider setValue:self.mediaPlayer.currentPosition/1000 animated:YES];
//        NSLog(@"value time-- %f ,currentPosition --- %f",self.progressSlider.value,self.mediaPlayer.currentPosition/1000);
    }
    
}


- (IBAction)progressChanged:(UISlider *)sender {
    self.isRunTime = NO;
    self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%f",sender.value]];
    AliVcMovieErrorCode code = [self.mediaPlayer seekTo:sender.value*1000];
    if (code == ALIVC_SUCCESS) {
        NSLog(@"value slider-- %f ,currentPosition---%f",sender.value,self.mediaPlayer.currentPosition/1000);
    }
}

- (IBAction)muteSwichChanged:(UISwitch *)sender {
    [self.mediaPlayer setMuteMode:sender.isOn];
}
- (IBAction)volumeSliderChanged:(UISlider *)sender {
    [self.mediaPlayer setVolume:sender.value];
}
- (IBAction)bringhtnessSliderChanged:(UISlider *)sender {
    [self.mediaPlayer setBrightness:sender.value];
}
- (IBAction)displayModeSegmentedChanged:(UISegmentedControl *)sender {
    [self.mediaPlayer setScalingMode:sender.selectedSegmentIndex];
}

- (IBAction)changedPlaySpeed:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.mediaPlayer.playSpeed = 0.5;
    }
    else if (sender.selectedSegmentIndex == 1) {
        self.mediaPlayer.playSpeed = 1;
    }
    else if (sender.selectedSegmentIndex == 2) {
        self.mediaPlayer.playSpeed = 1.5;
    }
    else if (sender.selectedSegmentIndex == 3) {
        self.mediaPlayer.playSpeed = 2;
    }
}

- (IBAction)rotationSegment:(UISegmentedControl *)sender {
    [self.mediaPlayer setRenderRotate:sender.selectedSegmentIndex*90];
}

- (IBAction)mirrorSemgent:(UISegmentedControl *)sender {
    [self.mediaPlayer setRenderMirrorMode:sender.selectedSegmentIndex];
}


-(NSString *)getMMSSFromSS:(NSString *)totalTime{
    NSInteger seconds = [totalTime integerValue];
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
