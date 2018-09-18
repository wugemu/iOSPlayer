//
//  AliyunPlaySDKDemoOneViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlaySDKDemoOneViewController.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AliyunPlayMessageShowView.h"
#import "ALiyunPlaySDKCheckToolViewController.h"
#import "UIView+Layout.h"
#import "UIAliyunSlider.h"

#import "AliyunPlayDataConfig.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define BUTTONTAG  5001

static BOOL s_autoPlay = NO;
@interface AliyunPlaySDKDemoOneViewController ()<AliyunVodPlayerDelegate>{
    //代表进度条是否可以更新
    BOOL  mProgressCanUpdate;
}

/*
 *集成所需配置
 */
@property(nonatomic ,strong)UIView *playerBackgroundView;
@property(nonatomic ,strong)UIView *playerView;
@property(nonatomic ,strong)AliyunVodPlayer *aliPlayer;

//播放数据
@property(nonatomic ,strong) AliyunPlayDataConfig *config;

//计时器，时时获取currentTime
@property (nonatomic, strong) NSTimer *timer;

/*
 *以下属性为 stoaryboard界面元素部署,
 */
@property (weak, nonatomic) IBOutlet UIView *playerContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightTimeLabel;
@property (weak, nonatomic) IBOutlet UIAliyunSlider *timeProgress;
@property (weak, nonatomic) IBOutlet UIButton *qualitysButton;
@property (weak, nonatomic) IBOutlet UIView *scrollviewContentView;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *disPlayModeSegment;
@property (nonatomic, strong)AliyunPlayMessageShowView * showMessageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qualityControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *playSpeedSegment;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;
@property (weak, nonatomic) IBOutlet UIButton *replayBtn;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong)ALPlayerVideoErrorModel *tempErrorModel;
@property (nonatomic, strong)NSMutableArray *qualitysAry;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rotatedSegment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *mirrorSegment;

//记录当前播放地址是否过期
@property (nonatomic, assign) BOOL isPlaybackAddressExpired;
//保存当前播放地址过期时的播放器时间
@property (nonatomic, assign) NSTimeInterval saveCurrentTime;
//保存播放地址过期时的清晰度， 仅对STS播放方式演示。
@property (nonatomic, assign) AliyunVodPlayerVideoQuality saveQuality;


@end

@implementation AliyunPlaySDKDemoOneViewController
#pragma mark - scrollview
- (void)updateViewConstraints{
    [super updateViewConstraints];
    self.viewHeight.constant = CGRectGetHeight([UIScreen mainScreen].bounds)*2;
}

#pragma mark - 播放器初始化
-(AliyunVodPlayer *)aliPlayer{
    if (!_aliPlayer) {
        _aliPlayer = [[AliyunVodPlayer alloc] init];
        _aliPlayer.delegate = self;
        [_aliPlayer setAutoPlay:s_autoPlay];
        _aliPlayer.quality=  0;
//        [_aliPlayer setPrintLog:YES];
        _aliPlayer.circlePlay = YES;
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [pathArray objectAtIndex:0];
        //maxsize MB    maxDuration 秒
        [_aliPlayer setPlayingCache:YES saveDir:docDir maxSize:3000 maxDuration:100000];
    }
    return _aliPlayer;
}

#pragma mark - 懒加载
-(UIView *)playerBackgroundView{
    if (!_playerBackgroundView) {
        _playerBackgroundView = [[UIView alloc] init];
        _playerBackgroundView.backgroundColor = [UIColor clearColor];
    }
    return  _playerBackgroundView;
}

- (UIView *)playerView{
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
    }
    return  _playerView;
}

#pragma  mark - initView
- (void)initView{
    /***********播放器界面搭建**************/
    self.playerView = self.aliPlayer.playerView;
    [self.playerContentView addSubview:self.playerView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.leftTimeLabel.textColor = [UIColor blueColor];
    self.rightTimeLabel.textColor = [UIColor blueColor];
    [self.playerContentView bringSubviewToFront:self.leftTimeLabel];
    [self.playerContentView bringSubviewToFront:self.rightTimeLabel];
    [self.playerContentView bringSubviewToFront:self.progressView];
    [self.playerContentView bringSubviewToFront:self.timeProgress];
    
    
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
}

#pragma mark - naviBar
- (void)InitNaviBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log", nil) style:UIBarButtonItemStylePlain target:self action:@selector(LogButtonItemCliceked:)];
}

#pragma mark - leftBarButtonItem
- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.aliPlayer stop];
    [self.aliPlayer releasePlayer];
    self.aliPlayer = nil;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - rightBarButtonItem
- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}

#pragma  mark - 点击切换清晰度按钮
-(void)qualityChanged:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    if (_qualitysAry.count == 0||Index == -1) {
        return;
    }
    
    if((int)self.aliPlayer.quality == -1) {
        NSString* strQuality = _qualitysAry[Index];
        [self.aliPlayer setVideoDefinition:strQuality];
    }
    else {
        NSString* strQuality = _qualitysAry[Index];
        [self.aliPlayer setQuality:(AliyunVodPlayerVideoQuality)[strQuality intValue]];
    }
}


#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    _qualitysAry = [[NSMutableArray alloc] init];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self InitNaviBar];
    [self.autoSwitch setOn:s_autoPlay];
    [self.disPlayModeSegment setSelectedSegmentIndex:self.aliPlayer.displayMode];
    [self.muteSwitch setOn:self.aliPlayer.muteMode];
    [_qualityControl addTarget:self action:@selector(qualityChanged:) forControlEvents:UIControlEventValueChanged];
    //sdk版本号
    NSString *version =  [self.aliPlayer getSDKVersion];
    NSLog(@"%@",version);
    
    self.config = [[AliyunPlayDataConfig alloc] init];
    
    if (self.videoId.length>0&&self.accessKeyId.length>0&&self.accessKeySecret.length>0&&self.securityToken.length>0) {
        self.config.videoId = self.videoId;
        self.config.stsAccessKeyId = self.accessKeyId;
        self.config.stsAccessSecret = self.accessKeySecret;
        self.config.stsSecurityToken = self.securityToken;
    }
    
    switch (self.config.playMethod) {
        case AliyunPlayMedthodURL:
            {
                [self.aliPlayer prepareWithURL:self.config.videoUrl];
            }
            break;
        case AliyunPlayMedthodSTS:
            {
                //默认的播放方式，其他在config中设置
                [self.aliPlayer prepareWithVid:self.config.videoId accessKeyId:self.config.stsAccessKeyId accessKeySecret:self.config.stsAccessSecret securityToken:self.config.stsSecurityToken];
            }
            break;
        
        case AliyunPlayMedthodMTS:
            {
                [self.aliPlayer prepareWithVid:self.config.videoId
                                         accId:self.config.mtsAccessKey
                                     accSecret:self.config.mtsAccessSecret
                                      stsToken:self.config.mtsStstoken
                                      authInfo:self.config.mtsAuthon
                                        region:self.config.mtsRegion
                                    playDomain:nil mtsHlsUriToken:nil];
            }
            break;
            
        case AliyunPlayMedthodPlayAuth:
            {
                [self.aliPlayer prepareWithVid:self.config.videoId playAuth:self.config.playAuth];
            }
            break;
        default:
            break;
    }
    
    if(self.aliPlayer.autoPlay){
        self.playBtn.enabled = NO;
        self.stopBtn.enabled = YES;
        self.pauseBtn.enabled = YES;
        self.resumeBtn.enabled = NO;
    }else{
        self.playBtn.enabled = YES;
        self.stopBtn.enabled = NO;
        self.pauseBtn.enabled = NO;
        self.resumeBtn.enabled = NO;
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initView];
    mProgressCanUpdate = YES;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //storyboard 刷新布局
    self.playerView.frame= CGRectMake(0, 0, self.playerContentView.bounds.size.width, self.playerContentView.bounds.size.height);
    self.showMessageView.frame = self.view.bounds;
}

#pragma mark - AliyunVodPlayerManagerDelegate
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    //清晰度,beginLoading时 getAliyunMediaInfo 已经获取到当前所选择清晰度视频信息。
    if (event == AliyunVodPlayerEventPrepareDone) {
        
        //播放地址超时时操作
        if (self.isPlaybackAddressExpired) {
            self.isPlaybackAddressExpired = NO;
            [vodPlayer setQuality:self.saveQuality];
            [vodPlayer seekToTime:self.saveCurrentTime];
            [vodPlayer start];
        }
        
        AliyunVodPlayerVideo *videoModel = [self.aliPlayer getAliyunMediaInfo];
        if (videoModel) {
            self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",videoModel.duration]];
        }else{
            self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.aliPlayer.duration]];
        }
        
        [_qualitysAry removeAllObjects];
        [_qualityControl removeAllSegments];
        if((int)videoModel.videoQuality == -1) {
            for (NSString* quality in videoModel.allSupportQualitys) {
                NSString* qualityDescription = quality;
                int index = (int)[_qualityControl numberOfSegments];
                [_qualityControl insertSegmentWithTitle:qualityDescription atIndex:index animated:TRUE];
                if ([qualityDescription isEqualToString:videoModel.videoDefinition]) {
                    [_qualityControl setSelectedSegmentIndex:[_qualityControl numberOfSegments]-1];
                }
                [_qualitysAry addObject:quality];
            }
        }
        else {
            for (NSString* quality in videoModel.allSupportQualitys) {
                NSString* qualityDescription = [self videoQualityToString:quality];
                int index = (int)[_qualityControl numberOfSegments];
                [_qualityControl insertSegmentWithTitle:qualityDescription atIndex:index animated:TRUE];
                if ([quality intValue] == (int)videoModel.videoQuality) {
                    [_qualityControl setSelectedSegmentIndex:[_qualityControl numberOfSegments]-1];
                }
                [_qualitysAry addObject:quality];
            }
        }
        
        NSLog(@"vodplayer --- %d",vodPlayer.quality);
    }
    
    //封装播放器时，按需求考虑添加timer
    if (event == AliyunVodPlayerEventPrepareDone) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    
    //增加log展示内容
    [self.showMessageView addTextString:[self getMessageWithevent:event errorMsg:nil] ];
}

- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel{
    mProgressCanUpdate = YES;
    NSString* errDescription = [self getMessageWithevent:errorModel.errorCode errorMsg:errorModel.errorMsg];
    [self.showMessageView addTextString:errDescription];
    
    self.tempErrorModel = errorModel;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:errDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
    [alert show];

    [vodPlayer stop];
    [self.timer invalidate];
    [self.timeProgress setValue:0];
    self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
    
    self.playBtn.enabled = YES;
    self.stopBtn.enabled = NO;
    self.pauseBtn.enabled = NO;
    self.resumeBtn.enabled = NO;
}

-(void)onTimeExpiredErrorWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    [self.showMessageView addTextString:@"timeExpired"];
 
    [vodPlayer stop];
    [self.timer invalidate];
    [self.timeProgress setValue:0];
    self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
    
    
    self.playBtn.enabled = YES;
    self.stopBtn.enabled = NO;
    self.pauseBtn.enabled = NO;
    self.resumeBtn.enabled = NO;
}

- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition{
    mProgressCanUpdate = NO;
}

- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition{
    self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",vodPlayer.duration]];
    mProgressCanUpdate = YES;
    NSLog(@"vodplayer --- %d",quality);
    
    self.playBtn.enabled = NO;
    self.stopBtn.enabled = YES;
    self.pauseBtn.enabled = YES;
    self.resumeBtn.enabled = NO;
    
    [self.aliPlayer setRenderRotate:self.rotatedSegment.selectedSegmentIndex*90];
    [self.aliPlayer setRenderMirrorMode:self.mirrorSegment.selectedSegmentIndex];
    
}

- (void)vodPlayer:(AliyunVodPlayer*)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition{
}

- (void)onCircleStartWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
}

-(void)vodPlayerPlaybackAddressExpiredWithVideoId:(NSString *)videoId quality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition{
    
    NSTimeInterval nowPlaytime = self.aliPlayer.currentTime;
    if (nowPlaytime<1) {
        return;
    }
    
    self.isPlaybackAddressExpired = YES;
    self.saveQuality = quality;
    self.saveCurrentTime = nowPlaytime;
    
    if (self.aliPlayer) {
        [self.aliPlayer stop];
    }
    
    switch (self.config.playMethod) {
        case AliyunPlayMedthodURL:
        {
            [self.aliPlayer prepareWithURL:self.config.videoUrl];
        }
            break;
        case AliyunPlayMedthodSTS:
        {
            //默认的播放方式，其他在config中设置
            [self.aliPlayer prepareWithVid:videoId
                               accessKeyId:self.config.stsAccessKeyId
                           accessKeySecret:self.config.stsAccessSecret securityToken:self.config.stsSecurityToken];
        }
            break;
            
        case AliyunPlayMedthodMTS:
        {
            [self.aliPlayer prepareWithVid:self.config.videoId
                                     accId:self.config.mtsAccessKey
                                 accSecret:self.config.mtsAccessSecret
                                  stsToken:self.config.mtsStstoken
                                  authInfo:self.config.mtsAuthon
                                    region:self.config.mtsRegion
                                playDomain:nil mtsHlsUriToken:nil];
        }
            break;
            
        case AliyunPlayMedthodPlayAuth:
        {
            [self.aliPlayer prepareWithVid:self.config.videoId playAuth:self.config.playAuth];
        }
            
            break;
        default:
            break;
    }
    
    
   
}


#pragma mark - 控件事件
- (IBAction)switchChanged:(UISwitch *)sender {
    switch (sender.tag) {
        case 301: //自动播放
        {
            [self.aliPlayer setAutoPlay:sender.isOn];
            s_autoPlay = sender.isOn;
        }
            break;
        case 302: //静音
        {
            [self.aliPlayer setMuteMode:sender.isOn];
        }
            break;
        default:
            break;
    }
}

#pragma mark - seek
- (IBAction)timeProgress:(UISlider *)sender {
    if (self.aliPlayer && (self.aliPlayer.playerState == AliyunVodPlayerStateLoading || self.aliPlayer.playerState == AliyunVodPlayerStatePause ||
                           self.aliPlayer.playerState == AliyunVodPlayerStatePlay)) {
        mProgressCanUpdate = NO;
        [ self.aliPlayer seekToTime:sender.value * self.aliPlayer.duration ];
    }
}
#pragma mark - timerRun
- (void)timerRun:(NSTimer *)sender{
    //音柱数据
    [self.aliPlayer getAudioData:^(NSData *data) {
//        NSLog(@"data---%lu",(unsigned long)data.length);
    }];
    
    //缓存文件大小， 路径要与开始设置相同。需要测试时打开
    [self fileSize];
    
    if (self.aliPlayer && mProgressCanUpdate == YES) {
        self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.aliPlayer.currentTime]];
        [self.timeProgress setValue:self.aliPlayer.currentTime/self.aliPlayer.duration animated:YES];
        [self.progressView setProgress:self.aliPlayer.loadedTime/self.aliPlayer.duration];
    
        
    }
}

#pragma mark - 缓存文件大小
-(void)fileSize{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    NSString *filePath = docDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:docDir isDirectory:nil]){
        NSArray *subpaths = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
        for (NSString *subpath in subpaths) {
            
            NSString *fullSubpath = [filePath stringByAppendingPathComponent:subpath];
            if ([subpath hasSuffix:@".mp4"]) {
                long long fileSize =  [fileManager attributesOfItemAtPath:fullSubpath error:nil].fileSize;
                NSLog(@"fileSie ---- %lld",fileSize);
            }
        }
    }
}

#pragma mark - 亮度／音量
- (IBAction)progressChanged:(UISlider *)sender {
    //401 音量。 402 亮度
    switch (sender.tag) {
        case 401:
            [self.aliPlayer setVolume:sender.value];
            break;
        case 402:
            [self.aliPlayer setBrightness:sender.value];
            break;
            
        default:
            break;
    }
}

#pragma mark - 显示模式设置
- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender {
    [self.aliPlayer setDisplayMode:(int)sender.selectedSegmentIndex];
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.aliPlayer setDisplayMode:AliyunVodPlayerDisplayModeFit];
            break;
        case 1:
            [self.aliPlayer setDisplayMode:AliyunVodPlayerDisplayModeFitWithCropping];
            break;
        default:
            break;
    }
}

#pragma mark - play stop pause pause replay
- (IBAction)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 201://播放
        {
            if (self.aliPlayer.playerState == AliyunVodPlayerStateIdle || self.aliPlayer.playerState == AliyunVodPlayerStateStop) {
                self.aliPlayer.autoPlay = YES;
                
                switch (self.config.playMethod) {
                    case AliyunPlayMedthodURL:
                    {
                        [self.aliPlayer prepareWithURL:self.config.videoUrl];
                    }
                        break;
                    case AliyunPlayMedthodSTS:
                    {
                        //默认的播放方式，其他在config中设置
                        [self.aliPlayer prepareWithVid:self.config.videoId accessKeyId:self.config.stsAccessKeyId accessKeySecret:self.config.stsAccessSecret securityToken:self.config.stsSecurityToken];
                    }
                        break;
                        
                    case AliyunPlayMedthodMTS:
                    {
                        [self.aliPlayer prepareWithVid:self.config.videoId
                                                 accId:self.config.mtsAccessKey
                                             accSecret:self.config.mtsAccessSecret
                                              stsToken:self.config.mtsStstoken
                                              authInfo:self.config.mtsAuthon
                                                region:self.config.mtsRegion
                                            playDomain:nil mtsHlsUriToken:nil];
                    }
                        break;
                        
                    case AliyunPlayMedthodPlayAuth:
                    {
                        [self.aliPlayer prepareWithVid:self.config.videoId playAuth:self.config.playAuth];
                    }
                        break;
                    default:
                        break;
                }
            }
            else {
                [self.aliPlayer start];
            }
            self.aliPlayer.playSpeed = [self getPlaySpeedValueWithSelectedSegmentIndex:self.playSpeedSegment.selectedSegmentIndex];
            self.playBtn.enabled = NO;
            self.stopBtn.enabled = YES;
            self.pauseBtn.enabled = YES;
            self.resumeBtn.enabled = NO;
        }
            break;
        case 202://停止
        {
            [self.aliPlayer stop];
            [self.timer invalidate];
            [self.timeProgress setValue:0];
            self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
            
            self.playBtn.enabled = YES;
            self.stopBtn.enabled = NO;
            self.pauseBtn.enabled = NO;
            self.resumeBtn.enabled = NO;
            
            
        }
            break;
        case 203://暂停
        {
            [self.aliPlayer pause];
            self.playBtn.enabled = NO;
            self.stopBtn.enabled = YES;
            self.pauseBtn.enabled = NO;
            self.resumeBtn.enabled = YES;
        }
            break;
        case 204://继续
        {
            [self.aliPlayer resume];
            self.playBtn.enabled = NO;
            self.stopBtn.enabled = YES;
            self.pauseBtn.enabled = YES;
            self.resumeBtn.enabled = NO;
        }
            break;
        case 205://重播
        {
            [self.aliPlayer setDisplayMode:(int)self.disPlayModeSegment.selectedSegmentIndex];
            [self.disPlayModeSegment setSelectedSegmentIndex:self.aliPlayer.displayMode];
            [self.aliPlayer replay];
            
            self.playBtn.enabled = NO;
            self.stopBtn.enabled = YES;
            self.pauseBtn.enabled = YES;
            self.resumeBtn.enabled = NO;
            
            
        }
            break;
        case 206 : //诊断
        {
            ALiyunPlaySDKCheckToolViewController *toolVC = [[ALiyunPlaySDKCheckToolViewController alloc] init];
            toolVC.playUrlPath = self.tempErrorModel.errorUrl;
            [self.navigationController pushViewController:toolVC animated:YES];
        }
            break;
        default:
            break;
    }
}

//截图按钮
- (IBAction)shotImage:(UIButton *)sender {
    //            写入相册
    UIImage *image = [self.aliPlayer snapshot];
    if  (image){
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    }


}



#pragma mark - 倍速播放选择
- (IBAction)playSpeedChanged:(UISegmentedControl *)sender {
    self.aliPlayer.playSpeed = [self getPlaySpeedValueWithSelectedSegmentIndex:sender.selectedSegmentIndex];
}

- (float)getPlaySpeedValueWithSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    float f = 1.0;
    if (selectedSegmentIndex == 0) {
        f = 1.0;
    }
    else if (selectedSegmentIndex == 1) {
        f = 1.25;
    }
    else if (selectedSegmentIndex == 2) {
        f = 1.5;
    }
    else if (selectedSegmentIndex == 3) {
        f = 2;
    }
    return f;
}

- (IBAction)rotationSegment:(UISegmentedControl *)sender {
    [self.aliPlayer setRenderRotate:sender.selectedSegmentIndex*90];
}

- (IBAction)mirrorSegment:(UISegmentedControl *)sender {
    [self.aliPlayer setRenderMirrorMode:sender.selectedSegmentIndex];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            mProgressCanUpdate = YES;
            str = NSLocalizedString(@"load_end", nil);//@"加载视频完成";
            break;
        case AliyunVodPlayerEventPrepareDone :
            str = NSLocalizedString(@"get_loaddata", nil);//@"获取到播放数据";
            break;
        case AliyunVodPlayerEventSeekDone :
            str = NSLocalizedString(@"seek_to", nil);//@"视频跳转seek结束";
            mProgressCanUpdate = YES;
            break;
        case AliyunVodPlayerEventFirstFrame :
            str = NSLocalizedString(@"start_firstFrame", nil);//@"视频首帧开始播放";
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

#pragma mark - 清晰度转换
-(NSString*) videoQualityToString:(NSString*)strQuality{
    int nQuality = [strQuality intValue];
    AliyunVodPlayerVideoQuality quality = (AliyunVodPlayerVideoQuality)nQuality;
    NSString* strQualityDescrp = @"";
    switch (quality) {
        case AliyunVodPlayerVideoFD:
            strQualityDescrp = NSLocalizedString(@"FD", nil);
            break;
        case AliyunVodPlayerVideoLD:
            strQualityDescrp = NSLocalizedString(@"LD", nil);
            break;
        case AliyunVodPlayerVideoSD:
            strQualityDescrp = NSLocalizedString(@"SD", nil);
            break;
        case AliyunVodPlayerVideoHD:
            strQualityDescrp = NSLocalizedString(@"HD", nil);
            break;
        case AliyunVodPlayerVideo2K:
            strQualityDescrp = NSLocalizedString(@"2K", nil);
            break;
        case AliyunVodPlayerVideo4K:
            strQualityDescrp = NSLocalizedString(@"4K", nil);
            break;
        case AliyunVodPlayerVideoOD:
            strQualityDescrp = NSLocalizedString(@"OD", nil);
            break;
        default:
            break;
    }
    return strQualityDescrp;
}
@end
