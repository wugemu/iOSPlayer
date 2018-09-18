//
//  AliyunContinuousViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/12/21.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunContinuousViewController.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AliyunPlayMessageShowView.h"
#import "UIView+Layout.h"
#import "Until.h"
#import "ALiyunPlaySDKCheckToolViewController.h"

#define BUTTON_TAT_PLAY 8000
#define BUTTON_TAT_STOP BUTTON_TAT_PLAY+1
#define BUTTON_TAT_PAUSE BUTTON_TAT_STOP+1
#define BUTTON_TAT_RESUME BUTTON_TAT_PAUSE+1
#define BUTTON_TAT_REPLAY BUTTON_TAT_RESUME+1
#define BUTTON_TAT_TOOL BUTTON_TAT_REPLAY+1
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

@interface AliyunContinuousViewController ()<AliyunVodPlayerDelegate,UITableViewDelegate,UITableViewDataSource>

//播放器sdk
@property (nonatomic, strong) AliyunVodPlayer *vodPlayer;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *vodContentView;

//UI
@property (nonatomic, strong) AliyunPlayMessageShowView *showMessageView;
@property (nonatomic, strong) UILabel *bufferLabel;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UIButton *toolButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isChangedRow;

@property (nonatomic, strong) NSArray *titlesAry;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL mProgressCanUpdate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation AliyunContinuousViewController
#pragma mark - data
-(NSArray *)titlesAry{
    if (!_titlesAry) {
        _titlesAry = @[@"http://player.alicdn.com/video/aliyunmedia.mp4",
                       @"http://saas-video-qp.qupaicloud.com/e1fdf4512fee41cdafa1f8b382bbceae/9b8fb2077b5a4ca4a3cb31b41b955a09-S00000001-200000.mp4",
                       @"http://saas-video-qp.qupaicloud.com/fa621b163def4baeb9b12ee5ec051efd/f1eb3904128d4613b41b66bd7f975ba6-5287d2089db37e62345123a1be272f8b.mp4",
                       @"http://saas-video-qp.qupaicloud.com/299B3F9B-15BE76DF272-1767-9096-266-17559/8b8c03c80c2f43bf903a76621a6008d8.m3u8",
                       @"http://saas-video-qp.qupaicloud.com/4b5561fcda2d4825b2285a48e3b25389/1071bc468d85488bb98eef1867a98fca-699a80a29a15c59c9d0868389f86cc3f.mp4",
                       ];
    }
    return _titlesAry;
}
static BOOL s_autoPlay = YES;
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

#pragma  mark - 懒加载 UI部分
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        UIView *footview = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = footview;
        _tableView.layer.borderColor = [UIColor grayColor].CGColor;
        _tableView.layer.cornerRadius = 1.0f;
        _tableView.layer.borderWidth = 2;
        _tableView.layer.masksToBounds = YES;
    }
    return  _tableView;
}
- (UILabel *)bufferLabel{
    if(!_bufferLabel){
        _bufferLabel = [[UILabel alloc] init];
        _bufferLabel.text  = NSLocalizedString(@"buffer", nil);
        _bufferLabel.font = [UIFont systemFontOfSize:10.0f];
        _bufferLabel.textColor = [UIColor whiteColor];
        
    }
    return _bufferLabel;
}

- (UILabel *)leftTimeLabel{
    if(!_leftTimeLabel){
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.text  = NSLocalizedString(@"00:00", nil);
        _leftTimeLabel.font = [UIFont systemFontOfSize:10.0f];
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel{
    if(!_rightTimeLabel){
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.text  = NSLocalizedString(@"00:00", nil);
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
-(UIButton *)replayButton{
    if(!_replayButton){
        _replayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_replayButton setTitle:NSLocalizedString(@"con_replay", nil) forState:UIControlStateNormal];
        _replayButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _replayButton;
}

-(UIButton *)toolButton{
    if(!_toolButton){
        _toolButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_toolButton setTitle:NSLocalizedString(@"check_tools", nil) forState:UIControlStateNormal];
        _toolButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _toolButton;
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
        _slider.continuous = YES;// 设置可连续变化
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    }
    return _slider;
}

- (void)sliderValueChanged:(UISlider*)sender{
    if (self.vodPlayer && (self.vodPlayer.playerState == AliyunVodPlayerStateLoading || self.vodPlayer.playerState == AliyunVodPlayerStatePause ||
                           self.vodPlayer.playerState == AliyunVodPlayerStatePlay)) {
        self.mProgressCanUpdate = NO;
        [ self.vodPlayer seekToTime:sender.value * self.vodPlayer.duration ];
    }else{
        sender.value = 0.0;
    }
}

-(NSIndexPath *)indexPath {
    if(!_indexPath){
        _indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return _indexPath;
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
    
    [self.view addSubview:self.tableView];
    
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
    
    self.replayButton.frame = CGRectMake(self.resumeButton.right+10, self.pauseButton.top, 50, 30);
    [self.replayButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.replayButton.tag = BUTTON_TAT_REPLAY;
    [self.view addSubview:self.replayButton];
    
    self.toolButton.frame = CGRectMake(self.playButton.left, self.playButton.bottom+10, 200, 30);
    [self.toolButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.toolButton.tag = BUTTON_TAT_TOOL;
    [self.view addSubview:self.toolButton];
    
    self.showMessageView.frame = self.view.bounds;
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self InitNaviBar];
    [self initView];
    
    [self.vodPlayer prepareWithURL:[NSURL URLWithString:self.titlesAry[0]]];
    
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

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mProgressCanUpdate = YES;
    
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    //iphone x
    if ([[Until iphoneType] isEqualToString:@"iPhone10,3"] || [[Until iphoneType] isEqualToString:@"iPhone10,6"]) {
        self.tableView.frame = CGRectMake(0, self.view.bottom-VIEWSAFEAREAINSETS(self.view).bottom-150, self.view.bounds.size.width, 150);
    }else{
        self.tableView.frame = CGRectMake(0, self.view.bottom-150, self.view.bounds.size.width, 150);
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:self.indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
#pragma mark - tableDelegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titlesAry.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"democell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.row) {
            case 0:
            cell.textLabel.text = @"阿里视频云介绍";
            break;
            case 1:
            cell.textLabel.text = @"SCARYPRANKS";
            break;
            case 2:
            cell.textLabel.text = @"趣拍云MV功能介绍";
            break;
            case 3:
            cell.textLabel.text = @"MV素材演示";
            break;
            case 4:
            cell.textLabel.text = @"MV效果演示";
            break;
        
        default:
            break;
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:10.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (self.isChangedRow == false) {
        self.isChangedRow = true;
        self.indexPath = indexPath;
        NSLog(@"---indexpath--- %@",self.indexPath);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatDelay) object:nil];
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5];
        // 在下面实现点击cell需要实现的逻辑就可以了
    
        [self.slider setValue:0.0f animated:YES];
        self.leftTimeLabel.text= NSLocalizedString(@"00:00", nil);
        self.rightTimeLabel.text = NSLocalizedString(@"00:00", nil);
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
        self.playButton.enabled = NO;
        self.stopButton.enabled = YES;
        self.pauseButton.enabled = YES;
        self.resumeButton.enabled = NO;
        [self scollPlay:indexPath];
        
        
    }else{
        return;
    }
}

- (void)scollPlay:(NSIndexPath *)indexPath{
    [self.vodPlayer stop];
    if (self.vodPlayer.playerState == AliyunVodPlayerStateIdle || self.vodPlayer.playerState == AliyunVodPlayerStateStop) {
        self.vodPlayer.autoPlay = YES;
        [self.vodPlayer prepareWithURL:[NSURL URLWithString:self.titlesAry[indexPath.row]]];
        
    }else{
        [self.vodPlayer start];
    }
}

- (void)repeatDelay{
    self.isChangedRow = false;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0f;
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
            NSLog(@"indexPath -- %@",self.indexPath);
            if (self.vodPlayer.playerState == AliyunVodPlayerStateIdle || self.vodPlayer.playerState == AliyunVodPlayerStateStop) {
                self.vodPlayer.autoPlay = YES;
                [self.vodPlayer prepareWithURL:[NSURL URLWithString:self.titlesAry[self.indexPath.row]]];
            }
            else {
                [self.vodPlayer start];
            }
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
            [self.timer invalidate];
            [self.slider setValue:0];
            self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",0.0]];
            
            self.playButton.enabled = YES;
            self.stopButton.enabled = NO;
            self.pauseButton.enabled = NO;
            self.resumeButton.enabled = NO;
        }
            break;
            
            case BUTTON_TAT_REPLAY:
        {
            [self.vodPlayer replay];
            self.mProgressCanUpdate = YES;
            
            self.playButton.enabled = NO;
            self.stopButton.enabled = YES;
            self.pauseButton.enabled = YES;
            self.resumeButton.enabled = NO;
        }
            break;
            case BUTTON_TAT_TOOL : //诊断
        {
            ALiyunPlaySDKCheckToolViewController *toolVC = [[ALiyunPlaySDKCheckToolViewController alloc] init];
            toolVC.playUrlPath = self.titlesAry[self.indexPath.row];
            [self.navigationController pushViewController:toolVC animated:YES];
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
#pragma mark - AliyunVodPlayerDelegate
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    
    //封装播放器时，按需求考虑添加timer
    if (event == AliyunVodPlayerEventPrepareDone) {
        AliyunVodPlayerVideo *videoModel = [self.vodPlayer getAliyunMediaInfo];
        
        if (videoModel) {
            self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",videoModel.duration]];
        }else{
            self.rightTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.vodPlayer.duration]];
        }
        
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
    }
    
    if (event == AliyunVodPlayerEventFinish){
        [self.tableView deselectRowAtIndexPath:self.indexPath animated:YES];
        NSIndexPath *tempIndexPath = self.indexPath;
        if(tempIndexPath.row>=4){
            tempIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }else{
            tempIndexPath = [NSIndexPath indexPathForRow:self.indexPath.row+1 inSection:0];
        }
        
        [self.tableView selectRowAtIndexPath:tempIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:tempIndexPath];
    }
    
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
    self.mProgressCanUpdate = NO;
}

#pragma mark - timerRun
- (void)timerRun:(NSTimer *)sender{
    
    self.bufferLabel.text = [NSString stringWithFormat:@"buffer:%@",[self getMMSSFromSS:[NSString stringWithFormat:@"%f",round(self.vodPlayer.bufferPercentage/1000)]]];
    
    if (self.vodPlayer && self.mProgressCanUpdate == YES) {
        self.leftTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%.f",self.vodPlayer.currentTime]];
        [self.slider setValue:self.vodPlayer.currentTime/self.vodPlayer.duration animated:YES];
        [self.progressView setProgress:self.vodPlayer.loadedTime/self.vodPlayer.duration];
        
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
            str = NSLocalizedString(@"seek_to", nil);//@"视频跳转seek结束";
            self.mProgressCanUpdate = YES;
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
    NSString* strQualityDescrp = nil;//NSLocalizedString(@"OD", nil);
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
