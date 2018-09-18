//
//  AliyunTimeShiftLiveViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/12/28.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunTimeShiftLiveViewController.h"

#import <AliyunVodPlayerSDK/AliyunVodPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AliyunPlayMessageShowView.h"
#import "UIView+Layout.h"
#import "Until.h"
#import "Reachability.h"


#define BUTTON_TAT_PLAY 8000
#define BUTTON_TAT_STOP BUTTON_TAT_PLAY+1
#define BUTTON_TAT_PAUSE BUTTON_TAT_STOP+1
#define BUTTON_TAT_RESUME BUTTON_TAT_PAUSE+1
#define BUTTON_TAT_REPLAY BUTTON_TAT_RESUME+1
#define BUTTON_TAT_TOOL BUTTON_TAT_REPLAY+1
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

#define LIVE_URL  @"http://qt1.alivecdn.com/timeline/cctv5td.m3u8?auth_key=1523725203-0-0-11caa0a4ead86d9f1a8eb700be7aafe2"


@interface AliyunTimeShiftLiveViewController ()<AliyunVodPlayerDelegate,UIAlertViewDelegate>

//播放器sdk
@property (nonatomic, strong) AliyunVodPlayer *vodPlayer;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *vodContentView;

//UI
@property (nonatomic, strong) UILabel *bufferLabel;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) AliyunPlayMessageShowView *showMessageView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *muteLabel;
@property (nonatomic, strong) UISwitch *muteSwitch;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UILabel *brightnessLabel;
@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UILabel *displayModeLabel;
@property (nonatomic, strong) UISegmentedControl *displaySegmentedControl;
@property (nonatomic, strong) UIView *hView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL mProgressCanUpdate;
@property (nonatomic, assign) double tempTotalTime;

@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, assign) BOOL isSeek;

@end

@implementation AliyunTimeShiftLiveViewController

static BOOL s_autoPlay = NO;
#pragma  mark - 懒加载 播放器部分
-(AliyunVodPlayer *)vodPlayer{
    if (!_vodPlayer) {
        _vodPlayer = [[AliyunVodPlayer alloc] init];
        _vodPlayer.delegate = self;
        [_vodPlayer setAutoPlay:s_autoPlay];
        _vodPlayer.quality=  0;
        _vodPlayer.circlePlay = NO;
    }
    return _vodPlayer;
}

- (UIView *)playerView{
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
    }
    return  _playerView;
}

- (UIView *)vodContentView{
    if(!_vodContentView){
        _vodContentView = [[UIView alloc] init];
    }
    return _vodContentView;
}


- (UILabel *)bufferLabel{
    if(!_bufferLabel){
        _bufferLabel = [[UILabel alloc] init];
        _bufferLabel.text  = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"live", nil),NSLocalizedString(@"00:00:00", nil)];
        _bufferLabel.font = [UIFont systemFontOfSize:10.0f];
        _bufferLabel.textColor = [UIColor whiteColor];
        
    }
    return _bufferLabel;
}

- (UILabel *)leftTimeLabel{
    if(!_leftTimeLabel){
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.text  = NSLocalizedString(@"00:00:00", nil);
        _leftTimeLabel.font = [UIFont systemFontOfSize:10.0f];
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel{
    if(!_rightTimeLabel){
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.text  = NSLocalizedString(@"00:00:00", nil);
        _rightTimeLabel.font = [UIFont systemFontOfSize:10.0f];
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightTimeLabel;
}


-(UIButton *)playButton{
    if(!_playButton){
        _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_playButton setTitle:NSLocalizedString(@"con_play", nil) forState:UIControlStateNormal];
        _playButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _playButton;
}

-(UIButton *)pauseButton{
    if(!_pauseButton){
        _pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_pauseButton setTitle:NSLocalizedString(@"con_pause", nil) forState:UIControlStateNormal];
        _pauseButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _pauseButton;
}

-(UIButton *)resumeButton{
    if(!_resumeButton){
        _resumeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_resumeButton setTitle:NSLocalizedString(@"con_resume", nil) forState:UIControlStateNormal];
        _resumeButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _resumeButton;
}
-(UIButton *)stopButton{
    if(!_stopButton){
        _stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_stopButton setTitle:NSLocalizedString(@"con_stop", nil) forState:UIControlStateNormal];
        _stopButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _stopButton;
}

-(UIView *)hView{
    if (!_hView) {
        _hView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 2, 30)];
        _hView.backgroundColor = [UIColor redColor];
    }
    return _hView;
}

- (UIProgressView *)progressView{
    if(!_progressView){
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = 0.0f;
        //设置轨道颜色
        _progressView.trackTintColor = [UIColor blackColor];
        //设置进度颜色
        _progressView.progressTintColor = [UIColor redColor];
    }
    return _progressView;
}

-(UISlider *)slider{
    if(!_slider){
        _slider = [[UISlider alloc] init];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.value = 0.0f;
        _slider.continuous = NO;// 设置可连续变化
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
       
        [_slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
        
        [_slider addTarget:self action:@selector(sliderTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _slider;
}
- (void)sliderTouchDown:(UISlider*)sender{
    if (self.vodPlayer&&self.vodPlayer.playerState == AliyunVodPlayerStatePause) {
        self.isSeek = YES;
    }
//    self.mProgressCanUpdate = NO;
}
- (void)sliderTouchUpInSide:(UISlider*)sender{
    
//    self.mProgressCanUpdate = YES;
}

- (void)sliderTouchUpOutSide:(UISlider*)sender{
    
//    self.mProgressCanUpdate = YES;
}

- (void)sliderValueChanged:(UISlider*)sender{
    if (self.vodPlayer) {
        if ([self networkChangePop:NO]) {
            return;
        }
        double s = self.vodPlayer.timeShiftModel.startTime;
        double m = self.tempTotalTime;
        double n = m - s;
        [self.vodPlayer seekToLiveTime:(int)(n*sender.value+s)];
        
        
    }else{
        sender.value = 0.0;
    }
}


-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [_scrollView flashScrollIndicators];
    }
    return _scrollView;
}

- (UILabel *)muteLabel{
    if (!_muteLabel) {
        _muteLabel = [[UILabel alloc] init];
        _muteLabel.text  = NSLocalizedString(@"Mute", nil);
        _muteLabel.font = [UIFont systemFontOfSize:10.0f];
        _muteLabel.textColor = [UIColor blackColor];
        _muteLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _muteLabel;
}
-(UISwitch *)muteSwitch{
    if (!_muteSwitch) {
        _muteSwitch = [[UISwitch alloc] init];
        [_muteSwitch setOn:NO];
        [_muteSwitch addTarget:self action:@selector(muteSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _muteSwitch;
}

-(void)muteSwitchChanged:(UISwitch*)sender{
    if (self.vodPlayer) {
        [self.vodPlayer setMuteMode:sender.isOn];
    }
}

-(UILabel *)volumeLabel{
    if (!_volumeLabel) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.text  = NSLocalizedString(@"Volume", nil);
        _volumeLabel.font = [UIFont systemFontOfSize:10.0f];
        _volumeLabel.textColor = [UIColor blackColor];
        _volumeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _volumeLabel;
}

-(UISlider *)volumeSlider{
    if (!_volumeSlider) {
        _volumeSlider = [[UISlider alloc] init];
        _volumeSlider.minimumTrackTintColor = [UIColor blueColor];
        _volumeSlider.maximumTrackTintColor = [UIColor grayColor];
        _volumeSlider.value = 0.0f;
        [_volumeSlider addTarget:self action:@selector(volumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _volumeSlider;
}

-(void)volumeSliderChanged:(UISlider*)sender{
    self.vodPlayer.volume = sender.value;
}

-(UILabel *)brightnessLabel{
    if (!_brightnessLabel) {
        _brightnessLabel = [[UILabel alloc] init];
        _brightnessLabel.text  = NSLocalizedString(@"Brightness", nil);
        _brightnessLabel.font = [UIFont systemFontOfSize:10.0f];
        _brightnessLabel.textColor = [UIColor blackColor];
        _brightnessLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _brightnessLabel;
}

-(UISlider *)brightnessSlider{
    if (!_brightnessSlider) {
        _brightnessSlider = [[UISlider alloc] init];
        _brightnessSlider.minimumTrackTintColor = [UIColor blueColor];
        _brightnessSlider.maximumTrackTintColor = [UIColor grayColor];
        _brightnessSlider.value = 0.0f;
        [_brightnessSlider addTarget:self action:@selector(brightnessSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _brightnessSlider;
}

-(void)brightnessSliderChanged:(UISlider*)sender{
    self.vodPlayer.brightness = sender.value;
}

-(UILabel *)displayModeLabel{
    if (!_displayModeLabel) {
        _displayModeLabel = [[UILabel alloc] init];
        _displayModeLabel.text  = NSLocalizedString(@"DisplayMode", nil);
        _displayModeLabel.font = [UIFont systemFontOfSize:10.0f];
        _displayModeLabel.textColor = [UIColor blackColor];
        _displayModeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _displayModeLabel;
}

-(UISegmentedControl *)displaySegmentedControl{
    if (!_displaySegmentedControl) {
        _displaySegmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Aspect fit", nil),NSLocalizedString(@"Aspect fill", nil)]];
        [_displaySegmentedControl setSelectedSegmentIndex:0];
        [_displaySegmentedControl addTarget:self action:@selector(displaySegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _displaySegmentedControl;
}

- (void)displaySegmentedControlChanged:(UISegmentedControl*)sender{
    self.vodPlayer.displayMode = (int)sender.selectedSegmentIndex;
}

#pragma mark - 展示log界面
-(AliyunPlayMessageShowView *)showMessageView{
    if (!_showMessageView){
        _showMessageView = [[AliyunPlayMessageShowView alloc] init];
        _showMessageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
        _showMessageView.alpha = 1;
    }
    return _showMessageView;
}

#pragma mark - NavigationBar
- (void)InitNaviBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log", nil) style:UIBarButtonItemStylePlain target:self action:@selector(LogButtonItemCliceked:)];
}

#pragma mark - leftBarButtonItem
- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.vodPlayer stop];
    [self.vodPlayer releasePlayer];
    self.vodPlayer = nil;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - rightBarButtonItem
- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}


#pragma  mark - initView
- (void)initView{
    /***********播放器界面搭建**************/
    self.vodContentView.frame = CGRectMake(0, 0, self.view.width, self.view.width*9/16);
    self.playerView = self.vodPlayer.playerView;
    self.playerView.frame = self.vodContentView.frame;
    [self.vodContentView addSubview:self.playerView];
    self.vodContentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.vodContentView];
    
    self.bufferLabel.frame = CGRectMake(10, self.vodContentView.height-60, self.vodContentView.width-20, 20);
    [self.vodContentView addSubview:self.bufferLabel];
    
    self.leftTimeLabel.frame = CGRectMake(10, self.vodContentView.height-30, 50, 20);
    [self.vodContentView addSubview:self.leftTimeLabel];
    
    self.rightTimeLabel.frame = CGRectMake(self.vodContentView.width-60, self.vodContentView.height-30, 50, 20);
    [self.vodContentView addSubview:self.rightTimeLabel];
    
    self.progressView.frame = CGRectMake(self.leftTimeLabel.right+15+2, self.vodContentView.height-16, self.vodContentView.width-154, 2);
    [self.vodContentView addSubview:self.progressView];
    self.slider.frame = CGRectMake(self.leftTimeLabel.right+15, self.vodContentView.height-40, self.vodContentView.width-150, 40);
    [self.vodContentView addSubview:self.slider];
    self.progressView.center = self.slider.center;
    
    [self.slider addSubview:self.hView];
    
    
    self.pauseButton.frame = CGRectMake((self.view.width-50)/2.0, self.vodContentView.bottom+10, 50, 30);
    [self.pauseButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.pauseButton.tag = BUTTON_TAT_PAUSE;
    [self.view addSubview:self.pauseButton];
    
    self.stopButton.frame = CGRectMake(self.pauseButton.left-60, self.pauseButton.top, 50, 30);
    [self.stopButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.stopButton.tag = BUTTON_TAT_STOP;
    [self.view addSubview:self.stopButton];
    
    self.playButton.frame = CGRectMake(self.stopButton.left-60, self.pauseButton.top, 50, 30);
    [self.playButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.tag = BUTTON_TAT_PLAY;
    [self.view addSubview:self.playButton];
    
    self.resumeButton.frame = CGRectMake(self.pauseButton.right+10, self.pauseButton.top, 50, 30);
    [self.resumeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.resumeButton.tag = BUTTON_TAT_RESUME;
    [self.view addSubview:self.resumeButton];
    
    //scrollview
    self.scrollView.frame = CGRectMake(0, self.playButton.bottom+10, self.view.width, self.view.height-self.playButton.bottom-10);
    [self.view addSubview:self.scrollView];

    self.muteLabel.frame = CGRectMake(10, 10, 30, 30);
    [self.scrollView addSubview:self.muteLabel];
    
    self.muteSwitch.frame = CGRectMake(self.muteLabel.right+10, 10, 50, 30);
    [self.muteSwitch setOn:self.vodPlayer.autoPlay];
    [self.scrollView addSubview:self.muteSwitch];
    
    self.volumeLabel.frame = CGRectMake(10, self.muteLabel.bottom+10, 30, 30);
    [self.scrollView addSubview:self.volumeLabel];
    
    self.volumeSlider.frame = CGRectMake(self.volumeLabel.right+10, self.muteLabel.bottom+10, self.scrollView.width-self.muteLabel.right-10-10, 30);
    self.volumeSlider.value = self.vodPlayer.volume;
    [self.scrollView addSubview:self.volumeSlider];
    
    self.brightnessLabel.frame = CGRectMake(10, self.volumeLabel.bottom+10, 30, 30);
    [self.scrollView addSubview:self.brightnessLabel];
    
    self.brightnessSlider.frame = CGRectMake(self.brightnessLabel.right+10, self.volumeLabel.bottom+10, self.scrollView.width-self.brightnessLabel.right-10-10,30);
    self.brightnessSlider.value = self.vodPlayer.brightness;
    [self.scrollView addSubview:self.brightnessSlider];
    
    self.displayModeLabel.frame = CGRectMake(10, self.brightnessLabel.bottom+10, self.scrollView.width-20, 30);
    [self.scrollView addSubview:self.displayModeLabel];
    
    self.displaySegmentedControl.frame = CGRectMake(10, self.displayModeLabel.bottom+10, self.scrollView.width-20, 30);
    [self.displaySegmentedControl setSelectedSegmentIndex:self.vodPlayer.displayMode];
    [self.scrollView addSubview:self.displaySegmentedControl];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.width, self.displaySegmentedControl.bottom+200)];
    self.showMessageView.frame = self.view.bounds;
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
    
}

- (NSString *)returndate:(NSTimeInterval)num{
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:num];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"HH:mm:ss"];
    return [dateformatter stringFromDate:date1];
}

#pragma  mark - viewDidload
- (void)viewDidLoad {
    [super viewDidLoad];
    NSTimeInterval currentSeconds = [[NSDate date] timeIntervalSince1970]; //秒
    NSString *currentLive = [NSString stringWithFormat:@"http://qt1.alivecdn.com/openapi/timeline/query?auth_key=1523728062-0-0-4cd58ce2b99aa4a9fcb0c3bef4b8b93a&lhs_start=1&app=timeline&stream=cctv5td&format=ts&lhs_start_unix_s_0=%.0f&lhs_end_unix_s_0=%.0f",(currentSeconds - 5 * 60), (currentSeconds + 5 * 60)];
//    currentLive = @"http://qt1.alivecdn.com/openapi/timeline/query?auth_key=1523728062-0-0-4cd58ce2b99aa4a9fcb0c3bef4b8b93a&lhs_start=1&app=timeline&stream=cctv5td&format=ts&lhs_start_unix_s_0=1517983704&lhs_end_unix_s_0=1517984304";
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self InitNaviBar];
    [self initView];
    
    //    self.countTime = 0;
    
    //直播时移
    [self.vodPlayer prepareWithLiveTimeUrl:[NSURL URLWithString:LIVE_URL]];
    
    [self.vodPlayer setLiveTimeShiftUrl:currentLive];
   
    
    
    if(self.vodPlayer.autoPlay){
        self.playButton.enabled = NO;
        self.stopButton.enabled = YES;
        self.pauseButton.enabled = YES;
        self.resumeButton.enabled = NO;
    }else{
        self.playButton.enabled = YES;
        self.stopButton.enabled = NO;
        self.pauseButton.enabled = NO;
        self.resumeButton.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mProgressCanUpdate = YES;
    
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttonClicked
- (void)buttonClicked:(UIButton *)sender{
    switch (sender.tag) {
        case BUTTON_TAT_PLAY:
        {
            if (self.vodPlayer.playerState == AliyunVodPlayerStateIdle || self.vodPlayer.playerState == AliyunVodPlayerStateStop) {
                self.vodPlayer.autoPlay = YES;
                [self.vodPlayer prepareWithLiveTimeUrl:[NSURL URLWithString:LIVE_URL]];
                
            }
            else {
                [self.vodPlayer start];
            }
            
            [self.timer fireDate];
            
            self.mProgressCanUpdate = YES;
            self.playButton.enabled = NO;
            self.stopButton.enabled = YES;
            self.pauseButton.enabled = YES;
            self.resumeButton.enabled = NO;
        }
            break;
            
        case BUTTON_TAT_PAUSE:
        {
            self.mProgressCanUpdate = NO;
            [self.vodPlayer pause];
            self.playButton.enabled = NO;
            self.stopButton.enabled = YES;
            self.pauseButton.enabled = NO;
            self.resumeButton.enabled = YES;
        }
            break;
            
        case BUTTON_TAT_RESUME:
        {
            [self.vodPlayer resume];
            self.mProgressCanUpdate = YES;
            self.playButton.enabled = NO;
            self.stopButton.enabled = YES;
            self.pauseButton.enabled = YES;
            self.resumeButton.enabled = NO;
        }
            break;
            
        case BUTTON_TAT_STOP:
        {
            [self.vodPlayer stop];
            self.mProgressCanUpdate = YES;
            
            [self.slider setValue:0];
            self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
            
            //            self.countTime = 0;
            
            self.playButton.enabled = YES;
            self.stopButton.enabled = NO;
            self.pauseButton.enabled = NO;
            self.resumeButton.enabled = NO;
            
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
        }
            break;
            
            
        default:
            break;
    }
    
}

#pragma mark - 禁止旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

#pragma mark - AliyunVodPlayerDelegate
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    //增加log展示内容
    [self.showMessageView addTextString:[self getMessageWithevent:event errorMsg:nil] ];
}

- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel{
    self.mProgressCanUpdate = YES;
    NSString* errDescription = [self getMessageWithevent:errorModel.errorCode errorMsg:errorModel.errorMsg];
    [self.showMessageView addTextString:errDescription];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:errDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
    [alert show];
}

- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    
}

#pragma mark - timerRun
- (void)timerRun:(NSTimer *)sender{

    NSLog(@"timerRun - mProgressCanUpdate--%d",self.mProgressCanUpdate);
    if (self.vodPlayer) {
    
        //开始时间
        double s = self.vodPlayer.timeShiftModel.startTime;
        
        //记录总的结束时间， getmodel 直播时间 - 播放时间<2分钟， getmodel直播时间+5分钟
        if (self.tempTotalTime ==0) {
            self.tempTotalTime = self.vodPlayer.timeShiftModel.endTime;
        }
        
        //可时移时间
        double shiftTime = (self.vodPlayer.timeShiftModel.endTime - self.vodPlayer.timeShiftModel.startTime)*0.1;
        
//        //直播结束时间
//        double liveEnd = self.vodPlayer.currentPlayTime + shiftTime;
        
        if ((self.tempTotalTime-self.vodPlayer.liveTime)<0.5*shiftTime) {
            self.tempTotalTime = self.vodPlayer.liveTime+shiftTime;
        }
        
        //进度条总长度
        double n = self.tempTotalTime - s;
        
        //播放进度百分比，小球位置
        double t = (self.vodPlayer.currentPlayTime-s)/n;
        NSLog(@"self -- %f--%f---%f---%f",self.vodPlayer.currentPlayTime,t,s,n);
        if (isnan(t)|isinf(t)) {
            t = 0;
        }
        
        [self.slider setValue:t animated:YES];
        
        //直播进度百分比，红色区域
        double p = (self.vodPlayer.liveTime-s)/n;
        
        //红色竖线位置
        if (isnan(p)|isinf(p)) {
            p = 0;
        }
        
        [self.progressView setProgress:p];
        
        if (p >= 1) {
            [self.hView setOrigin:CGPointMake(self.slider.width, 5)];
        }else{
            [self.hView setOrigin:CGPointMake(p*self.slider.width, 5)];
        }
    
        if (self.mProgressCanUpdate) {
            self.leftTimeLabel.text = [self returndate: self.vodPlayer.currentPlayTime];
            self.rightTimeLabel.text = [self returndate:self.tempTotalTime];
             NSLog(@"rightTimeLabel -- timerun:%@",self.rightTimeLabel.text);
        }else{

        }
           self.bufferLabel.text = [self returndate: self.vodPlayer.liveTime];
    }
    
    
}

- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    
}

- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
}

- (void)onCircleStartWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
}

- (void)onTimeExpiredErrorWithVodPlayer:(AliyunVodPlayer *)vodPlayer {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
}


#pragma mark - 展示内容，不需要关注
- (NSString *)getMessageWithevent:(AliyunVodPlayerEvent)event errorMsg : (NSString *)errorMsg{
    NSString *str = @"";
    switch (event) {
        case AliyunVodPlayerEventPlay:
            str = NSLocalizedString(@"start_play", nil);//@"开始播放";
            break;
        case AliyunVodPlayerEventPause:
            str = NSLocalizedString(@"pause_play", nil);//@"播放器暂停";
            break;
        case AliyunVodPlayerEventStop:
            str = NSLocalizedString(@"stop_play", nil);//@"播放器停止";
            break;
        case AliyunVodPlayerEventFinish:
            str = NSLocalizedString(@"finish_play", nil);//@"播放视频完成";
            break;
        case AliyunVodPlayerEventBeginLoading:
            str = NSLocalizedString(@"load_start", nil);//@"开始加载视频";
            break;
        case AliyunVodPlayerEventEndLoading:
            str = NSLocalizedString(@"load_end", nil);//@"加载视频完成";
            break;
        case AliyunVodPlayerEventPrepareDone :
            str = NSLocalizedString(@"get_loaddata", nil);//@"获取到播放数据";
            break;
        case AliyunVodPlayerEventSeekDone :
            {
                str = NSLocalizedString(@"seek_to", nil);//@"视频跳转seek结束";
                //            self.mProgressCanUpdate = YES;
                
            }
            break;
        case AliyunVodPlayerEventFirstFrame :
            {
                str = NSLocalizedString(@"start_firstFrame", nil);//@"视频首帧开始播放";
                if (self.isSeek) {
                    self.mProgressCanUpdate = NO;
                    [self.vodPlayer pause];
                    self.playButton.enabled = NO;
                    self.stopButton.enabled = YES;
                    self.pauseButton.enabled = NO;
                    self.resumeButton.enabled = YES;
                    self.isSeek = NO;
                }
            }
            break;
        default:
            str = [NSString stringWithFormat:@"%@: %d , %@:%@",NSLocalizedString(@"Error code", nil),event,NSLocalizedString(@"Error message", nil),errorMsg];;
            break;
    }
    return str;
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

- (void)networkStateChange{
    if(!self.vodPlayer) return;
    [self networkChangePop:NO];
}

-(BOOL) networkChangePop:(BOOL)isShow{
    BOOL ret = NO;
    
    switch ([self.reachability currentReachabilityStatus]) {
        case NotReachable:
        {
            ret = YES;
            
            
        }
            break;
        case ReachableViaWiFi:
            
            break;
        case ReachableViaWWAN:
            
            break;
        default:
            break;
    }
    
    return ret;
}



@end
