//
//  AliyunPlaySDKDemoFullScreenScrollViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/16.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlaySDKDemoFullScreenScrollViewController.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayer.h>
#import "AliyunPlaySDKDemoFullScreenScrollCollectionViewCell.h"
#import "UIView+Layout.h"
#import "Until.h"

@interface AliyunPlaySDKDemoFullScreenScrollViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,AliyunVodPlayerDelegate>
@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)AliyunVodPlayer *aliPlayer;
@property (nonatomic, strong)UIView *currentPlayerView;

@property (nonatomic, assign) BOOL isChangedRow;
@property (nonatomic, strong) NSIndexPath *tempIndexPath;

@end
@implementation AliyunPlaySDKDemoFullScreenScrollViewController

-(AliyunVodPlayer *)aliPlayer{
    if (!_aliPlayer) {
        _aliPlayer = [[AliyunVodPlayer alloc] init];
        _aliPlayer.delegate = self;
    }
    return _aliPlayer;
}

- (UIView *)currentPlayerView{
    if(!_currentPlayerView){
        _currentPlayerView = [[UIView alloc] init];
    }
    return _currentPlayerView;
}

#pragma mark - naviBar
- (void)naviBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemCliceked:)];
}

- (void)leftBarButtonItemCliceked:(UIBarButtonItem*)sender{
    sender.enabled = NO;
    //释放播放器
    if (self.aliPlayer) {
        [self.aliPlayer releasePlayer];
        self.aliPlayer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
    sender.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self naviBar];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize =  CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    layout.minimumInteritemSpacing=0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor grayColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:self.collectionView];
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   static NSString *identifier=@"identifier";
    [collectionView registerClass:[AliyunPlaySDKDemoFullScreenScrollCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    AliyunPlaySDKDemoFullScreenScrollCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
                                                               
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.row == 0) {
        [self.aliPlayer reset];
        self.currentPlayerView = self.aliPlayer.playerView;
        self.currentPlayerView.frame = CGRectMake(10, 10, cell.playerView.width-20, cell.playerView.height-20);
        [cell.playerView addSubview:self.currentPlayerView];
        [self.aliPlayer prepareWithURL:[NSURL URLWithString:@"http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"]];
//        [self.aliPlayer setAutoPlay: YES];
//        [self.aliPlayer prepareWithVid:VID
//                           accessKeyId:ACCESS_KEY_ID
//                       accessKeySecret:ACCESS_KEY_SECRET
//                         securityToken:SECURITY_TOKEN];
//        [self.aliPlayer start];
        //             self.tempIndexPath = indexPath;
    }
    
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging");
    if (self.aliPlayer.playerState == AliyunVodPlayerStatePlay) {
        [self.aliPlayer pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidEndDecelerating");
    self.tempIndexPath = [NSIndexPath indexPathForRow:(int)(scrollView.contentOffset.x/self.view.width) inSection:0];
    AliyunPlaySDKDemoFullScreenScrollCollectionViewCell *temp = (AliyunPlaySDKDemoFullScreenScrollCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:self.tempIndexPath] ;
    
    [self.aliPlayer reset];
    self.currentPlayerView = self.aliPlayer.playerView;
    self.currentPlayerView.frame = CGRectMake(0, 0, temp.playerView.width, temp.playerView.height);
    [temp.playerView addSubview:self.currentPlayerView];
    
    
    //注意：prepareWithVid 异步方法，在AliyunVodPlayerEventPrepareDone状态下在开始播放，否则无法播放。
    [self.aliPlayer prepareWithURL:[NSURL URLWithString:@"http://cloud.video.taobao.com/play/u/2712925557/p/1/e/6/t/1/40050769.mp4"]];
    
//    [self.aliPlayer prepareWithVid:VID
//                       accessKeyId:ACCESS_KEY_ID
//                   accessKeySecret:ACCESS_KEY_SECRET
//                     securityToken:SECURITY_TOKEN];
//     [self.aliPlayer setAutoPlay: NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//注意：prepareWithVid 异步方法，在AliyunVodPlayerEventPrepareDone状态下在开始播放，否则无法播放。
-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    if (event == AliyunVodPlayerEventPrepareDone) {
        if (vodPlayer.autoPlay) {
            
        }else{
            [vodPlayer start];
        }
    }
}

- (void)onCircleStartWithVodPlayer:(AliyunVodPlayer *)vodPlayer {
    
}


- (void)onTimeExpiredErrorWithVodPlayer:(AliyunVodPlayer *)vodPlayer {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel {
    
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
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
