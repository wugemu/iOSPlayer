//
//  AliyunPlaySDKListsAutoViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/16.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlaySDKListsAutoViewController.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import "AliyunPlaySDKListsCollectionViewCell.h"
#import "UIView+Layout.h"
#import "Until.h"

#import <AliyunVodPlayerSDK/AliyunVodPlayer.h>
@interface AliyunPlaySDKListsAutoViewController ()<UITableViewDelegate,UITableViewDataSource,AliyunVodPlayerDelegate,AliyunPlaySDKListsCollectionViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titlesAry;
@property (nonatomic, strong)AliyunVodPlayer *aliPlayer;
@property (nonatomic, strong)UIView *currentPlayerView;

@property (nonatomic, strong) NSIndexPath *tempIndexPath;

@end

@implementation AliyunPlaySDKListsAutoViewController
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

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *footview = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = footview;
        
    }
    return  _tableView;
}

#pragma mark - naviBar
- (void)naviBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemCliceked:)];
}

- (void)leftBarButtonItemCliceked:(UIBarButtonItem*)sender{
    //释放播放器
    if(self.aliPlayer){
        [self.aliPlayer releasePlayer];
        self.aliPlayer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self naviBar];
    
    //iphone x
    if ([[Until iphoneType] isEqualToString:@"iPhone10,3"] || [[Until iphoneType] isEqualToString:@"iPhone10,6"]) {
        self.tableView.frame = CGRectMake(0, VIEWSAFEAREAINSETS(self.view).top, self.view.bounds.size.width, self.view.bottom-VIEWSAFEAREAINSETS(self.view).bottom-64);
    }else{
        self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height-64);
    }
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - tableDelegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  20;//self.titlesAry.count>0?self.titlesAry.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.width*9/16;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"democell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    NSUInteger nodeCount = self.titlesAry.count;
    if (nodeCount == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor grayColor];
        
        return cell;
    }
    else
    {
        AliyunPlaySDKListsCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nodeCount > 0)
        {
            if (!cell) {
                cell = [[AliyunPlaySDKListsCollectionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }else{
                while ([cell.contentView.subviews lastObject] != nil) {
                    [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
                }
            }
        }
        cell.cellDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor grayColor];
        
        return cell;
    }
    return nil;
}

// 即将显示tableviewcell时调用
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[AliyunPlaySDKListsCollectionViewCell class]] ){
        AliyunPlaySDKListsCollectionViewCell*tempCell = (AliyunPlaySDKListsCollectionViewCell*)cell;
        if (tempCell.clickedButton.hidden) {
            tempCell.clickedButton.hidden = NO;
        }
    }
}

// 在删除cell之后调用，停止显示cell的时候调用,界面不显示cell时
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.aliPlayer&&self.tempIndexPath == indexPath){
        
        //stop会卡线程
        [self.aliPlayer pause];
        
        //清理界面
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[AliyunPlaySDKListsCollectionViewCell class]]){
            AliyunPlaySDKListsCollectionViewCell*tempCell = (AliyunPlaySDKListsCollectionViewCell*)cell;
            while ([tempCell.playerView.subviews lastObject] != nil) {
                [(UIView *)[tempCell.playerView.subviews lastObject] removeFromSuperview];
            }
        }
    }
    
}

-(void)aliyunPlaySDKListsCollectionViewCell:(AliyunPlaySDKListsCollectionViewCell *)cell clickedButton:(UIButton *)button{

    //上一个播放界面播放按钮。
    AliyunPlaySDKListsCollectionViewCell*fistCell =  [self.tableView cellForRowAtIndexPath:self.tempIndexPath];
    fistCell.clickedButton.hidden = NO;
    
    if (self.aliPlayer) {
        [self.aliPlayer reset];
    }
    
    //当前
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.aliPlayer prepareWithURL:[NSURL URLWithString:self.titlesAry[indexPath.row%5]]];
    self.currentPlayerView = self.aliPlayer.playerView;
    self.currentPlayerView.frame = CGRectMake(0, 0, cell.playerView.width, cell.playerView.height);
    [cell.playerView addSubview:self.currentPlayerView];
    [self.aliPlayer start];
    
    button.hidden = YES;
    
    self.tempIndexPath = indexPath;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //如果实现点击cell方式，打开此处
    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatDelay) object:nil];
//    [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5];
//
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//
//    if(self.aliPlayer.playerState == AliyunVodPlayerStatePlay||self.aliPlayer.playerState == AliyunVodPlayerStateIdle||self.aliPlayer.playerState == AliyunVodPlayerStatePause){
//        [self.aliPlayer reset];
//    }
//
//    if([cell isKindOfClass:[AliyunPlaySDKListsCollectionViewCell class]]){
//        AliyunPlaySDKListsCollectionViewCell*tempCell = (AliyunPlaySDKListsCollectionViewCell*)cell;
//        [self.aliPlayer prepareWithURL:[NSURL URLWithString:self.titlesAry[indexPath.row]]];
//        self.currentPlayerView = self.aliPlayer.playerView;
//        self.currentPlayerView.frame = CGRectMake(0, 0, tempCell.playerView.width, tempCell.playerView.height);
//        [tempCell.playerView addSubview:self.currentPlayerView];
//        [self.aliPlayer start];
//        self.tempIndexPath = indexPath;
//
//        NSLog(@"self.titlesAry ---%ld- %@",(long)indexPath.row,self.titlesAry[indexPath.row]);
//    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AliyunVodPlayerDelegate  播放错误提示
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel{
    NSLog(@"errorModel-- errorCode:%d,errorMsg-%@,errorRequestId:%@",errorModel.errorCode,errorModel.errorMsg,errorModel.errorRequestId);
}

-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    if (event == AliyunVodPlayerEventFirstFrame) {
        
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


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    
}


- (UIImage *)imagePlay {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", @"AliyunImageSource.bundle", @"al_play_start"]];
}
- (UIImage *)imagePause {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", @"AliyunImageSource.bundle", @"al_play_stop"]];
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
