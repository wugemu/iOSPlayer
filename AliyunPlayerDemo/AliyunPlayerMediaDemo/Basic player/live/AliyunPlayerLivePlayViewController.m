//
//  AliyunPlayerLivePlayerViewController.m
//  AliyunPlayerDemo
//
//  Created by 王凯 on 2017/9/21.
//  Copyright © 2017年 shiping chen. All rights reserved.
//

#import "AliyunPlayerLivePlayViewController.h"
#import "AliyunPlayMessageShowView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>
#import "Reachability.h"

#import <BarrageRenderer/BarrageRenderer.h>
#import "NSSafeObject.h"
#import "UIImage+Barrage.h"
#import "AvatarBarrageView.h"
#import "FlowerBarrageSprite.h"


#define LIVE_URL  @"rtmp://live.hkstv.hk.lxdns.com/live/hks"

@interface AliyunPlayerLivePlayViewController ()<UITextFieldDelegate,UIAlertViewDelegate,BarrageRendererDelegate>{
    BarrageRenderer * _renderer;
    NSTimer * _timer;
    NSInteger _index;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UITextField *dropBufferDurationTextField;
@property (weak, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *danmuSwitch;
@property (weak, nonatomic) IBOutlet UISlider *volmeSlider;
@property (weak, nonatomic) IBOutlet UISlider *brightSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scaleSegmentContrl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong)UIActivityIndicatorView *indicationrView;
@property (nonatomic, assign)BOOL isPause;

@property (nonatomic, strong) AliVcMediaPlayer* mediaPlayer;
@property (nonatomic, strong) AliyunPlayMessageShowView *showMessageView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *rotatedSegment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *mirrorSegment;


@end

@implementation AliyunPlayerLivePlayViewController
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
    NSString *backString = NSLocalizedString(@"Back", nil);
    NSString *logString = NSLocalizedString(@"Log", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logString style:UIBarButtonItemStylePlain target:self action:@selector(LogButtonItemCliceked:)];
}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    sender.enabled = NO;
    [self.mediaPlayer stop];
    [self.mediaPlayer destroy];
    self.mediaPlayer = nil;
    [self.dropBufferDurationTextField resignFirstResponder];
    [self removePlayerObserver];
    [self.navigationController popViewControllerAnimated:YES];
    sender.enabled = YES;
}
- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}

#pragma mark -viewDidLoad
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
    
    self.mediaPlayer.mediaType = MediaType_AUTO;
    self.mediaPlayer.timeout = 10000;//毫秒
    self.mediaPlayer.dropBufferDuration = [self.dropBufferDurationTextField.text intValue];
    /****************************************/
    
    //通知
    [self addPlayerObserver];
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.volmeSlider.value = self.mediaPlayer.volume;
    self.brightSlider.value = self.mediaPlayer.brightness;
    self.mediaPlayer.scalingMode = self.scaleSegmentContrl.selectedSegmentIndex;
    self.dropBufferDurationTextField.delegate = self;
    
    self.showMessageView.hidden = YES;
    [self.view addSubview:self.showMessageView];
    // Do any additional setup after loading the view.
    
    
    
    _index = 0;
    
    
    _renderer = [[BarrageRenderer alloc]init];
    _renderer.smoothness = .2f;
    _renderer.delegate = self;
    [self.contentView addSubview:_renderer.view];
    _renderer.canvasMargin = UIEdgeInsetsMake(10, 10, 10, 10);
    // 若想为弹幕增加点击功能, 请添加此句话, 并在Descriptor中注入行为
//    _renderer.view.userInteractionEnabled = YES;
//    [self.contentView sendSubviewToBack:_renderer.view];
    
    
    
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.indicationrView.center = self.mediaPlayer.view.center;
    self.showMessageView.frame = self.view.bounds;
}


- (void)networkStateChange{
    if(!self.mediaPlayer) return;
    
    NSLog(@"[self.reachability currentReachabilityStatus]--%ld",[self.reachability currentReachabilityStatus]);
//    [self networkChangePop:YES];
}

-(BOOL) networkChangePop:(BOOL)isShow{
    BOOL ret = NO;
    switch ([self.reachability currentReachabilityStatus]) {
        case NotReachable:
        {
            ret = YES;
            [self stop];
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
            [self stop];
            ret = YES;
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
            if(self.mediaPlayer) {
                [self start];
            }
        }
            
            break;
            
        default:
            break;
    }
    
}



- (void)becomeActive{
    
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    if (status == NotReachable) {
        if (self.mediaPlayer){
            if (self.mediaPlayer.isPlaying) {
                [self stop];
            }
        }
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"notreachable", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"clicked_ok", nil), nil];
        [av show];
    }else if (status == ReachableViaWiFi){
        if (self.mediaPlayer){
            if (self.isPause) {
                [self resume];
            }
        }
    }else if (status == ReachableViaWWAN ){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"alert_show_title_cancel",nil) otherButtonTitles:NSLocalizedString(@"clicked_ok",nil), nil];
        
        [av show];
    }else{
        
    }

}

- (void)resignActive{
    
    if (self.mediaPlayer){
        if (self.mediaPlayer.isPlaying) {
            [self pause];
        }
    }
    
}

#pragma mark - add NSNotification
-(void)addPlayerObserver
{
    //add network notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
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
    
}

#pragma mark - receive
- (void)OnVideoPrepared:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"onVideoPrepared", nil)];
}

- (void)onVideoFirstFrame :(NSNotification *)notification{
    [self.indicationrView stopAnimating];
    [self.showMessageView addTextString:NSLocalizedString(@"onVideoFirstFrame", nil)];
    
}
- (void)OnVideoError:(NSNotification *)notification{
    NSDictionary* userInfo = [notification userInfo];
    NSString* errorMsg = [userInfo objectForKey:@"errorMsg"];
    NSNumber* errorCodeNumber = [userInfo objectForKey:@"error"];
    NSLog(@"errorMsg-%@-%@",errorMsg,errorCodeNumber);
    [self.showMessageView addTextString:[NSString stringWithFormat:@"%@-%@",errorMsg,errorCodeNumber]];
}
- (void)OnVideoFinish:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnVideoFinish", nil)];
}
- (void)OnSeekDone:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnSeekDone", nil)];
}
- (void)OnStartCache:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnStartCache", nil)];
}
- (void)OnEndCache:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnEndCache", nil)];
}

- (void)onVideoStop:(NSNotification *)notification{
    [self.showMessageView addTextString:NSLocalizedString(@"OnVideoStop", nil)];
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
                                                    name:AliVcMediaPlayerPlaybackStopNotification object:self.mediaPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 201://start
        {
            [self.indicationrView startAnimating];
            
            if ([self networkChangePop:YES]) {
                return;
            }
            
            [self start];
            
            
        }
            break;
        case 202://stop
        {
            [self stop];
        }
            break;
        default:
            break;
    }
}

- (void)start{
    
    NSString *tempS = nil;
    if (self.tempUrl&&self.tempUrl.length>0) {
        tempS = self.tempUrl;
    }else{
        tempS = LIVE_URL;
    }
    AliVcMovieErrorCode err = [self.mediaPlayer prepareToPlay:[NSURL URLWithString:tempS]];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
        [self.indicationrView stopAnimating];
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"play failed,error code is", nil),(int)err]];
        return;
    }
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    [self.mediaPlayer play];
    [self.showMessageView addTextString:NSLocalizedString(@"log_start_play", nil)];
    
    [self.mediaPlayer setRenderRotate:self.rotatedSegment.selectedSegmentIndex*90];
    [self.mediaPlayer setRenderMirrorMode:self.mirrorSegment.selectedSegmentIndex];
    
}

- (void)pause{
    self.isPause = YES;
    AliVcMovieErrorCode err =[self.mediaPlayer pause];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"pause failed,error code is %d",(int)err);
        [self.showMessageView addTextString:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"pause failed,error code is", nil),(int)err]];
        return;
    }
    [self.showMessageView addTextString:NSLocalizedString(@"log_pause_play", nil)];
    
    
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
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    
}


- (IBAction)volumeChanged:(UISlider *)sender {
    self.mediaPlayer.volume = sender.value;
}
- (IBAction)brightChanged:(UISlider *)sender {
    self.mediaPlayer.brightness = sender.value;
}
- (IBAction)muteChanged:(UISwitch *)sender {
    self.mediaPlayer.muteMode = sender.isOn;
}

- (IBAction)danmuChanged:(UISwitch *)sender {
    
    if (sender.isOn) {
        [_renderer start];
        [_timer invalidate];
        NSSafeObject * safeObj = [[NSSafeObject alloc]initWithObject:self withSelector:@selector(autoSendBarrage)];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:safeObj selector:@selector(excute) userInfo:nil repeats:YES];
        
    } else {
        [_renderer stop];
        [_timer invalidate];
    }
    
    self.mediaPlayer.muteMode = sender.isOn;
}

- (void)dealloc
{
    [_renderer stop];
}


- (IBAction)displayModeChanged:(UISegmentedControl *)sender {
    self.mediaPlayer.scalingMode = sender.selectedSegmentIndex;
}
- (IBAction)dropBufferDurationTextField:(UITextField *)sender {
    
    
}
- (IBAction)viewTouchControl:(UIControl *)sender {
    
    [self.dropBufferDurationTextField resignFirstResponder];
}

- (IBAction)rotationSegment:(UISegmentedControl *)sender {
    [self.mediaPlayer setRenderRotate:sender.selectedSegmentIndex*90];
}

- (IBAction)mirrorSemgent:(UISegmentedControl *)sender {
    [self.mediaPlayer setRenderMirrorMode:sender.selectedSegmentIndex];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.scrollView setContentOffset:CGPointMake(0, self.volmeSlider.frame.origin.y) animated:YES];
    self.scrollView.bouncesZoom = NO;//scroll is no
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.mediaPlayer.dropBufferDuration = [self.dropBufferDurationTextField.text intValue];
}



- (void)autoSendBarrage
{
    NSInteger spriteNumber = [_renderer spritesNumberWithName:nil];
//    self.infoLabel.text = [NSString stringWithFormat:@"当前屏幕弹幕数量: %ld",(long)spriteNumber];
    if (spriteNumber <= 500) { // 用来演示如何限制屏幕上的弹幕量
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideLeft]];
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideDefault]];
        [_renderer receive:[self avatarBarrageViewSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideDefault]];

        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionB2T side:BarrageWalkSideLeft]];
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionB2T side:BarrageWalkSideRight]];
        [_renderer receive:[self flowerImageSpriteDescriptor]];
        [_renderer receive:[self avatarBarrageViewSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideDefault]];

        [_renderer receive:[self floatTextSpriteDescriptorWithDirection:BarrageFloatDirectionB2T side:BarrageFloatSideCenter]];
        [_renderer receive:[self floatTextSpriteDescriptorWithDirection:BarrageFloatDirectionT2B side:BarrageFloatSideLeft]];
        [_renderer receive:[self floatTextSpriteDescriptorWithDirection:BarrageFloatDirectionT2B side:BarrageFloatSideRight]];

        [_renderer receive:[self walkImageSpriteDescriptorWithDirection:BarrageWalkDirectionL2R]];
        [_renderer receive:[self walkImageSpriteDescriptorWithDirection:BarrageWalkDirectionL2R]];
        [_renderer receive:[self floatImageSpriteDescriptorWithDirection:BarrageFloatDirectionT2B]];
    }
}

#pragma mark - 弹幕描述符生产方法

/// 生成精灵描述 - 过场文字弹幕
- (BarrageDescriptor *)walkTextSpriteDescriptorWithDirection:(BarrageWalkDirection)direction
{
    return [self walkTextSpriteDescriptorWithDirection:direction side:BarrageWalkSideDefault];
}

/// 生成精灵描述 - 过场文字弹幕
- (BarrageDescriptor *)walkTextSpriteDescriptorWithDirection:(BarrageWalkDirection)direction side:(BarrageWalkSide)side
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
    descriptor.params[@"bizMsgId"] = [NSString stringWithFormat:@"%ld",(long)_index];
    descriptor.params[@"text"] = [NSString stringWithFormat:@"过场文字弹幕:%ld",(long)_index++];
    descriptor.params[@"textColor"] = [UIColor blueColor];
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"side"] = @(side);
    descriptor.params[@"clickAction"] = ^(NSDictionary *params){
        NSString *msg = [NSString stringWithFormat:@"弹幕 %@ 被点击",params[@"bizMsgId"]];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alertView show];
    };
    return descriptor;
}

/// 演示自定义弹幕样式
- (BarrageDescriptor *)avatarBarrageViewSpriteDescriptorWithDirection:(BarrageWalkDirection)direction side:(BarrageWalkSide)side
{
    NSArray *titles1 = @[@"♪└|°з°|┐♪",@"♪└|°ε°|┘♪",@"♪┌|°з°|┘♪",@"♪┌|°ε°|┐♪"];
    NSArray *titles2 = @[@"ʕ•̫͡•ʔ",@"ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•ʔ ʕ•̫͡•ʔ",
                         @"ʕ•̫͡•ʔ ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•ʔ",@"ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•ʔ"];
    
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkSprite class]);
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"side"] = @(side);
    descriptor.params[@"viewClassName"] = NSStringFromClass([AvatarBarrageView class]);
    descriptor.params[@"titles"] = (_index%2) ? titles1: titles2;
    
    __weak BarrageRenderer *render = _renderer;
    descriptor.params[@"clickAction"] = ^(NSDictionary *params){
        [render removeSpriteWithIdentifier:params[@"identifier"]];
    };
    
    return descriptor;
}

- (NSString *)randomString
{
    NSInteger count = ceil(10*(double)random()/RAND_MAX);
    NSMutableString *string = [[NSMutableString alloc]initWithCapacity:10];
    for (NSInteger i = 0; i < count; i++) {
        [string appendString:@"Br"];
    }
    return [string copy];
}

- (BarrageDescriptor *)flowerImageSpriteDescriptor
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([FlowerBarrageSprite class]);
    descriptor.params[@"image"] = [[UIImage imageNamed:@"avatar"]barrageImageScaleToSize:CGSizeMake(40.0f, 40.0f)];
    descriptor.params[@"duration"] = @(10);
    descriptor.params[@"viewClassName"] = NSStringFromClass([UILabel class]);
    descriptor.params[@"text"] = @"^*-*^";
    descriptor.params[@"borderWidth"] = @(1);
    descriptor.params[@"borderColor"] = [UIColor grayColor];
    descriptor.params[@"scaleRatio"] = @(4);
    descriptor.params[@"rotateRatio"] = @(100);
    return descriptor;
}

/// 生成精灵描述 - 浮动文字弹幕
- (BarrageDescriptor *)floatTextSpriteDescriptorWithDirection:(NSInteger)direction
{
    return [self floatTextSpriteDescriptorWithDirection:direction side:BarrageFloatSideCenter];
}

/// 生成精灵描述 - 浮动文字弹幕
- (BarrageDescriptor *)floatTextSpriteDescriptorWithDirection:(NSInteger)direction side:(BarrageFloatSide)side
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageFloatTextSprite class]);
    descriptor.params[@"text"] = [NSString stringWithFormat:@"AA-图文混排/::B过场弹幕:%ld",(long)_index++];
    descriptor.params[@"viewClassName"] = @"MLEmojiLabel";
    descriptor.params[@"textColor"] = [UIColor purpleColor];
    descriptor.params[@"duration"] = @(3);
    descriptor.params[@"fadeInTime"] = @(1);
    descriptor.params[@"fadeOutTime"] = @(1);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"side"] = @(side);
    return descriptor;
}

/// 生成精灵描述 - 过场图片弹幕
- (BarrageDescriptor *)walkImageSpriteDescriptorWithDirection:(NSInteger)direction
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkImageSprite class]);
    descriptor.params[@"image"] = [[UIImage imageNamed:@"avatar"]barrageImageScaleToSize:CGSizeMake(20.0f, 20.0f)];
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"trackNumber"] = @5; // 轨道数量
    return descriptor;
}

/// 生成精灵描述 - 浮动图片弹幕
- (BarrageDescriptor *)floatImageSpriteDescriptorWithDirection:(NSInteger)direction
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageFloatImageSprite class]);
    descriptor.params[@"image"] = [[UIImage imageNamed:@"avatar"]barrageImageScaleToSize:CGSizeMake(40.0f, 15.0f)];
    descriptor.params[@"duration"] = @(3);
    descriptor.params[@"direction"] = @(direction);
    return descriptor;
}

#pragma mark - BarrageRendererDelegate

/// 演示如何拿到弹幕的生命周期
- (void)barrageRenderer:(BarrageRenderer *)renderer spriteStage:(BarrageSpriteStage)stage spriteParams:(NSDictionary *)params
{
    NSString *subid = [params[@"identifier"] substringToIndex:8];
    if (stage == BarrageSpriteStageBegin) {
        NSLog(@"id:%@,bizMsgId:%@ =>进入",subid,params[@"bizMsgId"]);
    } else if (stage == BarrageSpriteStageEnd) {
        NSLog(@"id:%@,bizMsgId:%@ =>离开",subid,params[@"bizMsgId"]);
        /* 注释代码演示了如何复制一条弹幕
         BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
         descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
         [descriptor.params addEntriesFromDictionary:params];
         descriptor.params[@"delay"] = @(0);
         [renderer receive:descriptor];
         */
    }
}

#pragma mark - rotate
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_renderer removePresentSpritesWithName:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_renderer removePresentSpritesWithName:nil];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_renderer removePresentSpritesWithName:nil];
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
