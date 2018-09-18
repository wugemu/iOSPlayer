//
//  AliyunAnswerPlayerViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunAnswerPlayerViewController.h"
#import "UIView+Layout.h"
#import "AliyunAnswerView.h"
#import "AliyunAnswerLogView.h"
#import <AliyunPlayerSDK/AliyunPlayerSDK.h>
#import "AliyunLiveQuestionManager.h"
#import "AliyunReuqestManager.h"
#import "AliyunResultView.h"
#import "AliyunAnswerViewController.h"
#import "AliyunAnswerHeader.h"


@interface AliyunAnswerPlayerViewController ()<AliyunAnswerViewDelegate,AliyunLiveQuestionDelegate>
{
    int mRetryCount;
}

//播放器部分
@property (nonatomic, strong) AliVcMediaPlayer *mediaPlayer;
@property (nonatomic, strong) UIView *contentView;

//log
@property (nonatomic, strong) AliyunAnswerLogView *showMessageView;

//题目界面
@property (nonatomic, strong) AliyunAnswerView *answerView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong)UIBarButtonItem *button1;

@property (nonatomic, strong) AliyunResultView *resultView;



@end

@implementation AliyunAnswerPlayerViewController

- (AliyunResultView *)resultView{
    if (!_resultView){
        _resultView = [[AliyunResultView alloc] init];
        _resultView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithWhite:0.5 alpha:0.8];
        _resultView.hidden = YES;
        _resultView.layer.masksToBounds = YES;
        _resultView.layer.cornerRadius = 5;
    }
    return _resultView;
}


-(AliyunAnswerLogView *)showMessageView{
    if (!_showMessageView){
        _showMessageView = [[AliyunAnswerLogView alloc] init];
        _showMessageView.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0.5 alpha:0.8];
        _showMessageView.alpha = 1;
    }
    return _showMessageView;
}


- (AliyunAnswerView *)answerView{
    if (!_answerView) {
        _answerView = [[AliyunAnswerView alloc] init];
//        _answerView.layer.borderWidth = 1;
//        _answerView.layer.masksToBounds = YES;
//        _answerView.layer.cornerRadius = 10;
        _answerView.hidden = YES;
        _answerView.delegate = self;
        
    }
    return _answerView;
}

-(AliVcMediaPlayer *)mediaPlayer{
    if (!_mediaPlayer) {
        //1.创建播放器
        _mediaPlayer = [[AliVcMediaPlayer alloc] init];
    }
    return _mediaPlayer;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

-(void)player{
    
    self.contentView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    [self.view addSubview:self.contentView];
    [self.mediaPlayer create:self.contentView];
    self.mediaPlayer.scalingMode = scalingModeAspectFitWithCropping;
    self.mediaPlayer.circlePlay = YES;
    self.mediaPlayer.dropBufferDuration = 3000;
//    self.mediaPlayer.printLog = YES;
    AliVcMovieErrorCode err = [self.mediaPlayer prepareToPlay:[NSURL URLWithString:self.playUrl]];
    //5.判定错误，是否可以播放。
    if (err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
    }else{
        [self.mediaPlayer play];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    mRetryCount = 0;
}

#pragma mark - naviBar
- (void)InitNaviBar{
////    self.title = @"12312";
////   self.navigationController.title = @"年会冲顶";
//    UILabel *label = [[UILabel alloc] init];
//    label.frame = CGRectMake(0, 0, 60, 20);
//    label.text = @"年会冲顶";
//    label.font = [UIFont systemFontOfSize:20];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    self.navigationItem.titleView = label;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:1 target:self action:@selector(returnButtonItemCliceked:)];
    [button setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = button;

    self.button1 = [[UIBarButtonItem alloc] init];
    self.button1.title = @"0";
    [self.button1 setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = self.button1;

}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    
    sender.enabled = NO;
    if (self.answerView){
        [self.answerView clear];
        [self.answerView removeFromSuperview];
        self.answerView = nil;
    }
    if(self.mediaPlayer){
        [self removePlayerObserver];
        [self.mediaPlayer stop];
        [self.mediaPlayer destroy];
        self.mediaPlayer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
    sender.enabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}
- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    self.showMessageView.hidden = NO;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //根据接口判断是否可以答题
    if (!self.isSurvivor) {
        [[AliyunLiveQuestionManager shareManager] setOuted:YES] ;
        [self alertMessage:@"亲，答题已开始，下次早点来哦"];
    }else{
        [[AliyunLiveQuestionManager shareManager] setOuted:NO] ;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBG"]];
    imageView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    [self.view addSubview:imageView];
    
    //navigationbar
    [self InitNaviBar];
    //view
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor redColor];
    
    //播放器
    [self player];
    [self addPlayerObserver];
    
    //题目界面
    self.answerView.frame = CGRectMake(15, 100, self.view.width-30, 300);
    self.answerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.answerView];
    
    self.showMessageView.hidden = YES;
//    [self.view addSubview:self.showMessageView];
    
    [AliyunLiveQuestionManager shareManager].delegate = self;
    [AliyunLiveQuestionManager shareManager].mLiveId = self.liveId;
    [AliyunLiveQuestionManager shareManager].userId = self.userId;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(runtime:) userInfo:nil repeats:YES];
    
    
    self.resultView.frame = CGRectMake(15, 100, self.view.width-30, 250);
    [self.view addSubview:self.resultView];
    
    
}

- (void)runtime:(NSTimer *)timer{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/app/getUserCount",ONLINE_HOST];
    if (self.liveId == nil || self.liveId.length <1) {
        return;
    }
    NSDictionary *params = @{@"liveId":self.liveId};
    [AliyunReuqestManager doPostWithUrl:strUrl params:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            return ;
        }
        
        NSError *dicError ;
        NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dicError];
        if (dicError) {
            return ;
        }else{
            NSString *result = dict[@"result"][@"code"];
            NSString *userCount = [NSString stringWithFormat:@"%ld",[dict[@"data"][@"userCount"] longValue]];
            if ([result isEqualToString:@"Success"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.button1.title = userCount;
                    
                });
            }else{
                
            }
        }
        
        
    }];
    
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.showMessageView.frame = self.view.bounds;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - add NSNotification 播放器通知
-(void)addPlayerObserver
{
    
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
    
    //直播答题接收的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSeiData:)
                                                 name:AliVcMediaPlayerSeiDataNotification object:self.mediaPlayer];
    
    
}
#pragma mark - remove NSNotification
-(void)removePlayerObserver
{

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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerSeiDataNotification object:self.mediaPlayer];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - receive
- (void)OnVideoPrepared:(NSNotification *)notification{
    NSLog(@"OnVideoPrepared");
    [self.showMessageView addTextString:NSLocalizedString(@"onVideoPrepared",nil)];
    mRetryCount = 0;
}

- (void)onVideoFirstFrame :(NSNotification *)notification{
    NSLog(@"onVideoFirstFrame");
    [self.showMessageView addTextString:NSLocalizedString(@"onVideoFirstFrame",nil)];
}


- (void)OnVideoError:(NSNotification *)notification{
    NSLog(@"OnVideoError");
    NSDictionary* userInfo = [notification userInfo];
    NSString* errorMsg = [userInfo objectForKey:@"errorMsg"];
    NSNumber* errorCodeNumber = [userInfo objectForKey:@"error"];
    NSLog(@"%@-%@",errorMsg,errorCodeNumber);
    
    [self.showMessageView addTextString:[NSString stringWithFormat:@"%@-%@",errorCodeNumber,errorMsg]];
    
    if(self.mediaPlayer.errorCode == ALIVC_ERR_LOADING_TIMEOUT && mRetryCount<5){
        [self performSelector:@selector(retryPlayMethod) withObject:nil afterDelay:1.0];
    }
}

#pragma mark - 重连
-(void)retryPlayMethod
{
    if(self.mediaPlayer){
        [self.mediaPlayer stop];
        [self.mediaPlayer prepareToPlay:[NSURL URLWithString:self.playUrl]];
        [self.mediaPlayer play];
        mRetryCount++;
    }
}

- (void)OnVideoFinish:(NSNotification *)notification{
    NSLog(@"OnVideoFinish");
    [self.showMessageView addTextString:NSLocalizedString(@"OnVideoFinish",nil)];
}
- (void)OnSeekDone:(NSNotification *)notification{
    NSLog(@"OnSeekDone");
    [self.showMessageView addTextString:NSLocalizedString(@"OnSeekDone",nil)];
}
- (void)OnStartCache:(NSNotification *)notification{
    NSLog(@"OnStartCache");
    [self.showMessageView addTextString:NSLocalizedString(@"OnStartCache",nil)];
}
- (void)OnEndCache:(NSNotification *)notification{
   NSLog(@"OnEndCache");
    [self.showMessageView addTextString:NSLocalizedString(@"OnEndCache",nil)];
}

- (void)onVideoStop:(NSNotification *)notification{
   NSLog(@"onVideoStop");
    [self.showMessageView addTextString:NSLocalizedString(@"OnVideoStop",nil)];
}

- (void)onCircleStart:(NSNotification *)notification{
    NSLog(@"onCircleStart");
    [self.showMessageView addTextString:NSLocalizedString(@"onCircleStart",nil)];
}

//倒计时结束结束，是否是答案窗口
-(void)popQuestionEnd:(BOOL)answeredWindow
{
    self.answerView.hidden = YES;
    self.answerView.alpha = 1;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    } completion:^(BOOL finished) {
        
    }];
    
    [self.showMessageView addTextString:[NSString stringWithFormat:@"answeredWindow--%d",answeredWindow]];
}

//显示日志
-(void)addLogText:(NSString *)logStr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showMessageView addTextString:logStr];
    });
}

//回调，弹出题目
-(void)popQuestion:(AliyunLiveQuestion *)liveQuestion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.answerView.hidden = NO;
        [self.answerView popQuestion:liveQuestion];
        [self.showMessageView addTextString:NSLocalizedString(@"popQuestion", nil)];

        //切换界面
        if(liveQuestion.remainSeconds > 3){
            [UIView animateWithDuration:1 animations:^{
                CGRect frame = self.contentView.frame;
                frame.size.width = 125;
                frame.size.height = 215;
                frame.origin.x = self.view.width - 145;
                frame.origin.y = self.view.height - 235;
                self.contentView.frame = frame;
            } completion:^(BOOL finished) {
            }];
        }
    });
}
- (void)StartAnimation{
    self.resultView.hidden = YES;
//    [self returnButtonItemCliceked:nil];
}

//回调，弹出结果
-(void)popAnswer:(AliyunLiveQuestion *)liveQuestion
{
    BOOL isBool = [[AliyunLiveQuestionManager shareManager] isOut];
    BOOL isChooseCorrect = [[AliyunLiveQuestionManager shareManager] isChooseCorrect];
    bool result = [liveQuestion.questionId isEqualToString:@"012"] && !isBool && isChooseCorrect ;
    if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.hidden = NO;
            [self performSelector:@selector(StartAnimation) withObject:nil afterDelay:5];
            
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.answerView.hidden = NO;
            [self.answerView popAnswer:liveQuestion];
            [self.showMessageView addTextString:NSLocalizedString(@"popAnswer", nil)];
        });
    }
    
    
}

//答题
- (void)onSeiData:(NSNotification *)notification{
    NSLog(@"onSeiData");
    [self.showMessageView addTextString:@"onSeiData"];
    
    NSDictionary* dict = [notification userInfo];
    if (dict) {
        NSString* seiData = [dict objectForKey:@"seiData"];
        if (seiData) {
            NSLog(@"sei data is %@",seiData);
            
            [self.answerView clear];
            [[AliyunLiveQuestionManager shareManager] parseSEIData:seiData];
        }
    }
}

#pragma mark - 竖屏
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}




- (void)alertMessage:(NSString *)message{
    
    if ([NSThread isMainThread]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    
    
}


@end
