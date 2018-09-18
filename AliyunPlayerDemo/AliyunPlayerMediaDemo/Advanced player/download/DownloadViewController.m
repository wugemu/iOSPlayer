//
//  PlayerViewControllerHaveUI.m
//  ALPlayerDemo
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadListTableViewCell.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import <AliyunVodPlayerViewSDK/AliyunVodPlayerViewSDK.h>
#import "AddDownloadView.h"
#import "UIView+Layout.h"
#import "UINavigationController+autorotate.h"
#import <sys/utsname.h>

#import "Reachability.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})
@interface DownloadViewController ()<UITableViewDelegate, UITableViewDataSource,AliyunVodDownLoadDelegate,downloadViewDelegate,cellClickDelegate,AliyunVodPlayerViewDelegate>
{
    AliyunVodPlayerView* _playerView;
}

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *listDataArray;
@property (nonatomic, strong) NSMutableArray *listAddArray;
@property (nonatomic, strong) AddDownloadView *downloadView;
@property (nonatomic, assign)BOOL isLock;
@property (nonatomic, strong)UIAlertController *alertController;

@property (nonatomic, strong)Reachability * reachability;

@property (nonatomic,assign)BOOL isStatusHidden;

@end

@implementation DownloadViewController
{
    NSString* mDownloadPath;
}

@synthesize listTableView;
@synthesize listDataArray;
@synthesize listAddArray;
@synthesize downloadView;

+ (id)sharedViewController{
    static DownloadViewController *VC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        VC = [[self alloc] init];
    });
    return VC;
}

#pragma mark - naviBar
- (void)naviBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemCliceked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add_video", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemCliceked:)];
}

- (void)leftBarButtonItemCliceked:(UIBarButtonItem*)sender{
    [_playerView stop];
    [_playerView releasePlayer];
    [_playerView removeFromSuperview];
    _playerView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonItemCliceked : (UIBarButtonItem *)sender{
    [downloadView initShow];
    downloadView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self naviBar];
    [self setupSubViews];
    self.listDataArray = [NSMutableArray array];
    self.listAddArray = [NSMutableArray array];
    
    ///下载必须要设置的三个内容：1.下载代理 2.下载路径3.下载加密的秘钥（如果要加密的话）
    //设置下载代理
    [[AliyunVodDownLoadManager shareManager] setDownloadDelegate:self];
    
    //设置下载路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    [[AliyunVodDownLoadManager shareManager] setDownLoadPath:path];
    mDownloadPath = path;
    
    //设置同时下载的个数
    [[AliyunVodDownLoadManager shareManager] setMaxDownloadOperationCount:2];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    //网络状态判定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    for (AliyunDownloadMediaInfo* ainfo in [AliyunVodDownLoadManager shareManager].allMedias) {
        downloadCellModel* dcm = [[downloadCellModel alloc] init];
        AliyunDownloadMediaInfo* info = [[AliyunDownloadMediaInfo alloc] init];
        info.vid = ainfo.vid;
        info.quality = ainfo.quality;
        info.videoDefinition  = ainfo.videoDefinition;
        info.format = ainfo.format;
        info.downloadProgress = ainfo.downloadProgress;
        info.duration = ainfo.duration;
        info.title = ainfo.title;
        info.coverURL = ainfo.coverURL;
        info.size = ainfo.size;
        info.downloadFilePath = ainfo.downloadFilePath;
        info.downloadFileName = ainfo.downloadFileName;
        dcm.mInfo = info;
        
        if (info.downloadProgress == 100) {
            dcm.mCanPlay = YES;
            dcm.mCanStop = YES;
            dcm.mCanStart = NO;
        }
        else {
            dcm.mCanPlay = NO;
            dcm.mCanStop = YES;
            dcm.mCanStart = YES;
        }
        
        AliyunDataSource* source = [[AliyunDataSource alloc] init];
        source.vid = info.vid;
        source.videoDefinition = info.videoDefinition;
        source.format = info.format;
        source.quality = info.quality;
        dcm.mSource = source;
        [self.listDataArray addObject:dcm];
    }
    [listTableView reloadData];
}


- (void)reachabilityChanged{
    [self networkChangePop];
}


//网络状态判定 ,仅判定 4g
-(BOOL) networkChangePop{
    BOOL ret = NO;
    //    NotReachable = 0,
    //    ReachableViaWiFi,
    //    ReachableViaWWAN
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable:

            break;
            
        case ReachableViaWWAN:
            {
                if (self.listAddArray.count<1) {
                    break;
                }
                
                NSArray* arry = [[AliyunVodDownLoadManager shareManager] downloadingdMedias];

                for (int i = 0 ; i<self.listAddArray.count;i++) {
                    DownloadListTableViewCell *cell = (DownloadListTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    if (cell.mInfo.downloadProgress == 100) {
                        
                    }else{
                        [cell stopBtnAction:cell.stopBtn];
                    }
                    
                }
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"For mobile networks, continue to download？", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
                }];
        
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_button1", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    for (int i = 0 ; i<self.listAddArray.count;i++) {
                        DownloadListTableViewCell *cell = (DownloadListTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                        if (cell.mInfo.downloadProgress == 100) {
                            
                        }else{
                             [cell startBtnAction:cell.stopBtn];
                        }
                    }
                }];
                
                if ([arry count] > 0) {
                    [alertController addAction:cancelAction];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                ret = YES;
            }
            break;
        case ReachableViaWiFi:
   
            break;
            
        default:
            break;
    }
    
    return ret;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidUnload {
    [super viewDidUnload];
}

- (void)loadListTableView {
    self.listTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.listTableView registerClass:[DownloadListTableViewCell class] forCellReuseIdentifier:@"listTableViewID"];
    self.listTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.listTableView];
}

-(void)leftBar1Clicked:(NSObject*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupSubViews {
    [self loadListTableView];
    UIButton* createBtn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    createBtn.frame = CGRectMake((self.view.frame.size.width)/2-110, self.view.frame.size.height-100, 100, 40);
    [createBtn addTarget:self action:@selector(downloadAll:) forControlEvents:(UIControlEventTouchUpInside)];
    [createBtn setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
    [createBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [createBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [createBtn setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [createBtn setTitle:NSLocalizedString(@"Download all", nil) forState:UIControlStateNormal];
    createBtn.clipsToBounds = YES;
    createBtn.layer.cornerRadius = 20;
    [createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:createBtn];
    
    UIButton* createBtn1 = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    createBtn1.frame = CGRectMake((self.view.frame.size.width)/2+10, self.view.frame.size.height-100, 100, 40);
    [createBtn1 addTarget:self action:@selector(downloadDel:) forControlEvents:(UIControlEventTouchUpInside)];
    [createBtn1 setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
    [createBtn1 setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [createBtn1.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [createBtn1 setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [createBtn1 setTitle:NSLocalizedString(@"Delete all", nil) forState:UIControlStateNormal];
    createBtn1.clipsToBounds = YES;
    createBtn1.layer.cornerRadius = 20;
    [createBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:createBtn1];
    
    downloadView = [[AddDownloadView alloc] initWithFrame:CGRectMake(10, 64, SCREEN_WIDTH-20, SCREEN_HEIGHT-84)];
    downloadView.hidden = YES;
    [self.view addSubview:downloadView];
    downloadView.delegate = self;
}

#pragma mark - all download
- (void)downloadAll:(UIButton *)sender{
    
    NSMutableArray *ary = [NSMutableArray array];
    for (downloadCellModel* dcm in self.listDataArray) {
        if (dcm.mInfo.downloadProgress < 100) {
            [ary addObject:dcm.mSource];
        }
    }
    [[AliyunVodDownLoadManager shareManager] startDownloadMedias:ary];
    [listTableView reloadData];
}

- (void)downloadDel:(UIButton *)sender{
    [[AliyunVodDownLoadManager shareManager] clearAllMedias];
    [self.listDataArray removeAllObjects];
    [self.listAddArray removeAllObjects];
    [self.listTableView reloadData];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    if (_playerView)
//        [_playerView setNeedsLayout];
//}

//适配iphone x 界面问题，没有在 viewSafeAreaInsetsDidChange 这里做处理 ，主要 旋转监听在 它之后获取。
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NSString *platform =  [self iphoneType];
    NSLog(@"platform -- %@",platform);
    //iphone x
    if (![platform isEqualToString:@"iPhone10,3"] && ![platform isEqualToString:@"iPhone10,6"]) {
        return;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    UIDevice *device = [UIDevice currentDevice] ;
    switch (device.orientation) {//device.orientation
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortraitUpsideDown:{
            if (self.isStatusHidden) {
                CGRect frame = _playerView.frame;
                frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
                frame.size.width = SCREEN_WIDTH-VIEWSAFEAREAINSETS(self.view).left*2;
                frame.size.height = SCREEN_HEIGHT-VIEWSAFEAREAINSETS(self.view).bottom-VIEWSAFEAREAINSETS(self.view).top;
                _playerView.frame = frame;
            }else{
                CGRect frame = _playerView.frame;
                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
                //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
                if (_playerView.isLockPortrait&&self.isStatusHidden) {
                    frame.size.height = SCREEN_HEIGHT- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
                }
                _playerView.frame = frame;
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            //
            CGRect frame = _playerView.frame;
            frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
            frame.size.width = SCREEN_WIDTH-VIEWSAFEAREAINSETS(self.view).left*2;
            frame.size.height = SCREEN_HEIGHT-VIEWSAFEAREAINSETS(self.view).bottom;
            _playerView.frame = frame;
        }
            
            break;
        case UIDeviceOrientationPortrait:
        {
            //
            CGRect frame = _playerView.frame;
            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
            //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
            if (_playerView.isLockPortrait&&self.isStatusHidden) {
                frame.size.height = SCREEN_HEIGHT- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
            }
            _playerView.frame = frame;
            
        }
            
            break;
        default:
            
            break;
    }
    
#else
#endif
    NSLog(@"top----%f",_playerView.frame.origin.y);
    
}

- (NSString*)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    return platform;
}

- (void)dealloc {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listTableViewID" forIndexPath:indexPath];
    cell.delegate = self;
    if (self.listDataArray.count > indexPath.row) {
        downloadCellModel *dcm = self.listDataArray[indexPath.row];
        AliyunDownloadMediaInfo* info = dcm.mInfo;
        cell.mInfo = info;
        cell.mSource = dcm.mSource;
        
        NSString* sizeStr = @"";
        if (info.videoDefinition) {
            sizeStr = [[NSString alloc] initWithFormat:@"%@(%.2fM)",info.videoDefinition,info.size*1.0f/(1024*1024)];
        }else{
            sizeStr = [[NSString alloc] initWithFormat:@"%@(%.2fM)",info.title,info.size*1.0f/(1024*1024)];
        }
        
        cell.nameLabel.text = sizeStr;
        int tempProgress =  info.downloadProgress ;
        
        if (tempProgress <= 0 ) {
            cell.progressLabel.text = NSLocalizedString(@"download_status_unload", nil);
        }else if(tempProgress >= 100){
            cell.progressLabel.text = NSLocalizedString(@"download_status_finish", nil);
        }else if (tempProgress > /* DISABLES CODE */ (0) && tempProgress<100) {
            cell.progressLabel.text = [NSString stringWithFormat:@"%.f%%",info.downloadProgress*1.0f];
        }
        
        if(!dcm.mCanStop){
            cell.progressLabel.text = NSLocalizedString(@"download_status_stop", nil) ;
        }
        
        NSURL* url = [NSURL URLWithString:info.coverURL];
        UIImage* image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
        [cell.headerImageView setImage:image];
        
        cell.playBtn.enabled = dcm.mCanPlay;
        cell.stopBtn.enabled = dcm.mCanStop;
        cell.startBtn.enabled = dcm.mCanStart;
    }
    return cell;
}

-(void)onStartDownload:(AliyunDataSource *)dataSource medianInfo:(AliyunDownloadMediaInfo *)info{
    for (AliyunDataSource* source in self.listAddArray) {

        if (source.requestMethod == AliyunVodRequestMethodPlayAuth||source.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([dataSource.vid isEqualToString:source.vid] && [dataSource.format isEqualToString:source.format] && dataSource.quality == source.quality) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Cannot repeatly add", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
                [alert show];
                return;
            }
        }else if(source.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([dataSource.vid isEqualToString:source.vid] && [dataSource.format isEqualToString:source.format] && [dataSource.videoDefinition isEqualToString:source.videoDefinition]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Cannot repeatly add", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
                [alert show];
                return;
            }
        }else{
            
        }
    }
    
    [self.listAddArray addObject:dataSource];
    downloadCellModel* dcm = [[downloadCellModel alloc] init];
    dcm.mCanStop = YES;
    dcm.mCanPlay =  NO;
    dcm.mCanStart = YES;
    dcm.mInfo = info;
    dcm.mSource = dataSource;
    [self.listDataArray addObject:dcm];
    [listTableView reloadData];
}

/*
 功能：未完成回调，异常中断导致下载未完成，下次启动后会接收到此回调。
 回调数据：AliyunDownloadMediaInfo数组
 */
-(void)onUnFinished:(NSArray<AliyunDataSource *> *)mediaInfos{
    NSLog(@"onUnFinished");
//    if ([mediaInfos count] > 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Unfinished last time", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
//        [alert show];
//
//        for (AliyunDataSource* source in mediaInfos) {
//
//            #warning - to 数据过期，需要重新数据新的数据
//            /**************************/
//            //请根据实际情况获取 播放数据。
//            if (!source.stsData||!source.stsData.securityToken) {
//                source.stsData = [[AliyunStsData alloc] init];
//
//            }
//            /**************************/
//
//            downloadCellModel* dcm = [[downloadCellModel alloc] init];
//            AliyunDownloadMediaInfo* info = [[AliyunDownloadMediaInfo alloc] init];
//            info.vid = source.vid;
//            info.quality = source.quality;
//            info.videoDefinition  = source.videoDefinition;
//            info.format = source.format;
//            dcm.mInfo = info;
//            dcm.mCanPlay = NO;
//            dcm.mCanStop = YES;
//            dcm.mCanStart = NO;
//            dcm.mSource = source;
//            [self.listDataArray addObject:dcm];
//            [self.listAddArray addObject:dcm.mSource];
//        }
//        [listTableView reloadData];
//        [[AliyunVodDownLoadManager shareManager] startDownloadMedias:mediaInfos];
//    }
}

/*
 功能：准备下载回调。
 回调数据：AliyunDownloadMediaInfo数组
 */
-(void) onPrepare:(NSArray<AliyunDownloadMediaInfo*>*)mediaInfos{
    NSLog(@"onPrepare");
    [self.downloadView updateQualityInfo:mediaInfos];
}

/*
 功能：下载开始回调。
 回调数据：AliyunDownloadMediaInfo
 */
-(void) onStart:(AliyunDownloadMediaInfo*)mediaInfo{
    NSLog(@"onStart");
    for (downloadCellModel* dcm in self.listDataArray) {
        AliyunDownloadMediaInfo* info = dcm.mInfo;
        
        if (dcm.mSource.requestMethod == AliyunVodRequestMethodPlayAuth||dcm.mSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if (info.quality == mediaInfo.quality && [info.format isEqualToString:mediaInfo.format] && [info.vid isEqualToString:mediaInfo.vid]) {
                info.title = mediaInfo.title;
                info.coverURL = mediaInfo.coverURL;
                info.size = mediaInfo.size;
                info.duration = mediaInfo.duration;
                info.downloadFilePath = mediaInfo.downloadFilePath;
                info.downloadFileName = mediaInfo.downloadFileName;
                
                dcm.mCanStop = YES;
                dcm.mCanPlay =  NO;
                dcm.mCanStart =  NO;
                [self.listTableView reloadData];
            }
            break;
        }else if(dcm.mSource.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([info.videoDefinition isEqualToString:mediaInfo.videoDefinition]&& [info.format isEqualToString:mediaInfo.format] && [info.vid isEqualToString:mediaInfo.vid]) {
                info.title = mediaInfo.title;
                info.coverURL = mediaInfo.coverURL;
                info.size = mediaInfo.size;
                info.duration = mediaInfo.duration;
                info.downloadFilePath = mediaInfo.downloadFilePath;
                info.downloadFileName = mediaInfo.downloadFileName;
                
                dcm.mCanStop = YES;
                dcm.mCanPlay =  NO;
                dcm.mCanStart =  NO;
                [self.listTableView reloadData];
            }
            break;
        }else{
            
        }
    }
    
    self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Begun", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok_button1", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [self.alertController addAction:cancelAction];
    [self presentViewController:self.alertController animated:YES completion:nil];
    
}

/*
 功能：下载进度回调。
 回调数据：AliyunDownloadMediaInfo
 */
-(void) onProgress:(AliyunDownloadMediaInfo*)mediaInfo{
 
    for (downloadCellModel* dcm in self.listDataArray) {
        AliyunDownloadMediaInfo* info = dcm.mInfo;
        
        if (dcm.mSource.requestMethod == AliyunVodRequestMethodPlayAuth||dcm.mSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([info.vid isEqualToString:mediaInfo.vid] && [info.format isEqualToString:mediaInfo.format] && info.quality == mediaInfo.quality) {
                info.downloadProgress = mediaInfo.downloadProgress;
                NSLog(@"downloadProgress : %d",mediaInfo.downloadProgress);
                [self.listTableView reloadData];
                break;
            }
        }else if(dcm.mSource.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([info.vid isEqualToString:mediaInfo.vid] && [info.format isEqualToString:mediaInfo.format] && [info.videoDefinition isEqualToString:mediaInfo.videoDefinition]) {
                info.downloadProgress = mediaInfo.downloadProgress;
                NSLog(@"downloadProgress : %d",mediaInfo.downloadProgress);
                [self.listTableView reloadData];
                break;
            }
        }else{
            
        }
    }
}

/*
 功能：下载结束回调。
 回调数据：AliyunDownloadMediaInfo
 */
-(void) onStop:(AliyunDownloadMediaInfo*)mediaInfo{
    NSLog(@"onStop");
    for (downloadCellModel* dcm in self.listDataArray) {
        
        if (dcm.mSource.requestMethod == AliyunVodRequestMethodPlayAuth||dcm.mSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([dcm.mInfo.vid isEqualToString:mediaInfo.vid] && dcm.mInfo.quality == mediaInfo.quality && [dcm.mInfo.format isEqualToString:mediaInfo.format]) {
                dcm.mCanStop = NO;
                dcm.mCanPlay =  NO;
                dcm.mCanStart =  YES;
                [self.listTableView reloadData];
                break;
            }
        }else if(dcm.mSource.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([dcm.mInfo.vid isEqualToString:mediaInfo.vid] && [dcm.mInfo.videoDefinition isEqualToString:mediaInfo.videoDefinition] && [dcm.mInfo.format isEqualToString:mediaInfo.format]) {
                dcm.mCanStop = NO;
                dcm.mCanPlay =  NO;
                dcm.mCanStart =  YES;
                [self.listTableView reloadData];
                break;
            }
        }else{
            
        }
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Stopped", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
//    [alert show];
}

/*
 功能：下载开始回调。
 回调数据：AliyunDownloadMediaInfo
 */
-(void) onCompletion:(AliyunDownloadMediaInfo*)mediaInfo{
    NSLog(@"onCompletion");
    for (downloadCellModel* dcm in self.listDataArray) {
        
        if (dcm.mSource.requestMethod == AliyunVodRequestMethodPlayAuth||dcm.mSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([dcm.mInfo.vid isEqualToString:mediaInfo.vid] && dcm.mInfo.quality == mediaInfo.quality && [dcm.mInfo.format isEqualToString:mediaInfo.format]) {
                dcm.mCanStop = YES;
                dcm.mCanPlay =  YES;
                dcm.mCanStart =  YES;
                dcm.mInfo = mediaInfo;
                [self.listTableView reloadData];
                break;
            }
        }else if(dcm.mSource.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([dcm.mInfo.vid isEqualToString:mediaInfo.vid] && [dcm.mInfo.videoDefinition isEqualToString:mediaInfo.videoDefinition] && [dcm.mInfo.format isEqualToString:mediaInfo.format]) {
                dcm.mCanStop = YES;
                dcm.mCanPlay =  YES;
                dcm.mCanStart =  YES;
                dcm.mInfo = mediaInfo;
                [self.listTableView reloadData];
                break;
            }
        }else{
            
        }
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Finished", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
//    [alert show];
}

/*
 功能：下载结束回调。错误码与错误信息见下表
 回调数据：AliyunDownloadMediaInfo， code：错误码 msg：错误信息
 */
-(void)onError:(AliyunDownloadMediaInfo*)mediaInfo code:(int)code msg:(NSString *)msg{
    [self.alertController dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"onError");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
    [alert show];
    
    //提示错误时，都停止下载。
    if (self.listAddArray.count<1) {
        return;
    }
    for (int i = 0 ; i<self.listAddArray.count;i++) {
        DownloadListTableViewCell *cell = (DownloadListTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.mSource.requestMethod == AliyunVodRequestMethodPlayAuth||cell.mSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([cell.mInfo.vid isEqualToString:mediaInfo.vid] && cell.mInfo.quality == mediaInfo.quality && [cell.mInfo.format isEqualToString:mediaInfo.format]){
                
                if (cell.mInfo.downloadProgress ==100) {
                    break;
                }
                
                if (code == 4106) {//ALIVC_ERR_DOWNLOAD_INVALID_INPUTFILE
                    [cell deleteBtnAction:cell.deleteBtn];
                    break;
                }else{
                    [cell stopBtnAction:cell.stopBtn];
                    break;
                }
            }
        }else if (cell.mSource.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([cell.mInfo.vid isEqualToString:mediaInfo.vid] && [cell.mInfo.videoDefinition isEqualToString:mediaInfo.videoDefinition] && [cell.mInfo.format isEqualToString:mediaInfo.format]){
                
                if (cell.mInfo.downloadProgress ==100) {
                    break;
                }
                
                if (code == 4106) {//ALIVC_ERR_DOWNLOAD_INVALID_INPUTFILE
                    [cell deleteBtnAction:cell.deleteBtn];
                    break;
                }else{
                    [cell stopBtnAction:cell.stopBtn];
                    break;
                }
            }
            
        }else{
            
        }
        
        
        
    }
}

//-(NSString*)onGetPlayAuth:(NSString *)vid format:(NSString *)format quality:(AliyunVodPlayerVideoQuality)quality{
//    return PLAY_AUTH;
//}

//- (AliyunStsData *)onGetAliyunStsData:(NSString *)videoID format:(NSString *)format quality:(AliyunVodPlayerVideoQuality)quality{
//    AliyunStsData*data = nil;
//    return data;
//}

- (void)onChangeEncryptFileComplete {
    
}


- (void)onChangeEncryptFileProgress:(int)progress {
    
}


- (void)onGetAliyunMtsData:(AliyunMtsData *)mtsData videoID:(NSString *)videoID format:(NSString *)format quality:(NSString *)quality {
    
}


//- (NSString *)onGetPlayAuth:(NSString *)vid format:(NSString *)format quality:(AliyunVodPlayerVideoQuality)quality {
//    return @"";
//}


-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickStart:(AliyunDataSource *)dataSource{
    
    BOOL downloaded = NO;
    NSArray<AliyunDownloadMediaInfo*>* array = [[AliyunVodDownLoadManager shareManager] allMedias];
    for (AliyunDownloadMediaInfo* info in array) {
        if (dataSource.requestMethod == AliyunVodRequestMethodPlayAuth||dataSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([info.vid isEqualToString:dataSource.vid] && info.quality == dataSource.quality && [info.format isEqualToString:dataSource.format]) {
                if (info.downloadProgress == 100) {
                    downloaded = YES;
                    break;
                }
            }
        }else if (dataSource.requestMethod == AliyunVodRequestMethodMtsToken ){
            if ([info.vid isEqualToString:dataSource.vid] && [info.videoDefinition isEqualToString:dataSource.videoDefinition] && [info.format isEqualToString:dataSource.format]) {
                if (info.downloadProgress == 100) {
                    downloaded = YES;
                    break;
                }
            }
        }else{
            
        }
    }
    
    if (downloaded) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"video has downloaded", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [[AliyunVodDownLoadManager shareManager] startDownloadMedia:dataSource];
}


-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickDelete:(AliyunDownloadMediaInfo*)info{
    [[AliyunVodDownLoadManager shareManager] clearMedia:info];
    for (downloadCellModel* dcm in self.listDataArray) {
        AliyunDownloadMediaInfo* downloadInfo = dcm.mInfo;
        
        if (dcm.mSource.requestMethod == AliyunVodRequestMethodPlayAuth||dcm.mSource.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([downloadInfo.vid isEqualToString:info.vid] && [downloadInfo.format isEqualToString:info.format] && downloadInfo.quality == info.quality) {
                downloadInfo.downloadProgress = 0;
                dcm.mCanPlay = YES;
                dcm.mCanStop = YES;
                dcm.mCanStart = YES;
                [self.listDataArray removeObject:dcm];
                
                [self.listTableView reloadData];
                break;
            }
        }else if(dcm.mSource.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([downloadInfo.vid isEqualToString:info.vid] && [downloadInfo.format isEqualToString:info.format] && [downloadInfo.videoDefinition isEqualToString:info.videoDefinition]) {
                downloadInfo.downloadProgress = 0;
                dcm.mCanPlay = YES;
                dcm.mCanStop = YES;
                dcm.mCanStart = YES;
                [self.listDataArray removeObject:dcm];
                
                [self.listTableView reloadData];
                break;
            }
        }else{
            
        }
        
        
    }
    
    for (AliyunDataSource* source in self.listAddArray) {
        if (source.requestMethod == AliyunVodRequestMethodPlayAuth||source.requestMethod == AliyunVodRequestMethodStsToken) {
            if ([source.vid isEqualToString:info.vid] && [source.format isEqualToString:info.format] && source.quality == info.quality) {
                [self.listAddArray removeObject:source];
                break;
            }
        }else if(source.requestMethod == AliyunVodRequestMethodMtsToken){
            if ([source.vid isEqualToString:info.vid] && [source.format isEqualToString:info.format] && [source.videoDefinition isEqualToString:info.videoDefinition]) {
                [self.listAddArray removeObject:source];
                break;
            }
        }else{
            
        }
        
    }
}

-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickPlay:(AliyunDownloadMediaInfo*)info{
    if (_playerView) {
        [_playerView removeFromSuperview];
        [_playerView stop];
        [_playerView releasePlayer];
        _playerView = nil;
    }
    
    //兼容xcode 8
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    _playerView = [[AliyunVodPlayerView alloc] initWithFrame:CGRectMake(0, VIEWSAFEAREAINSETS(self.view).top==0?64:VIEWSAFEAREAINSETS(self.view).top, SCREEN_WIDTH, SCREEN_WIDTH * 9 / 16.0)];
#else
    _playerView = [[AliyunVodPlayerView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH * 9 / 16.0)];
#endif
    
    _playerView.delegate = self;
    [_playerView setAutoPlay:YES];
    
    //        //保持竖屏全屏，为展示下载列表 禁止此界面旋转。
    _playerView.isLockScreen = 0;
    _playerView.isLockPortrait = 1;
    [self.view addSubview:_playerView];
    NSString* playPath = [NSString stringWithFormat:@"%@/%@",mDownloadPath,info.downloadFileName];
    [_playerView playViewPrepareWithURL:[NSURL fileURLWithPath:playPath]];
}

- (void)onBackViewClickWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    //    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (_playerView) {
        [_playerView removeFromSuperview];
        [_playerView stop];
        [_playerView releasePlayer];
        _playerView = nil;
    }
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView fullScreen:(BOOL)isFullScreen{
    NSLog(@"isfullScreen --%d",isFullScreen);
    
    self.isStatusHidden = isFullScreen  ;
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView lockScreen:(BOOL)isLockScreen {
    
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onPause:(NSTimeInterval)currentPlayTime {
    
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onResume:(NSTimeInterval)currentPlayTime {
    
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onSeekDone:(NSTimeInterval)seekDoneTime {
    
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onStop:(NSTimeInterval)currentPlayTime {
    
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onVideoDefinitionChanged:(NSString *)videoDefinition {
    
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onVideoQualityChanged:(AliyunVodPlayerVideoQuality)quality {
    
}


- (void)onCircleStartWithVodPlayerView:(AliyunVodPlayerView *)playerView {
    
}


- (void)onFinishWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView {
    
}



-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickStop:(AliyunDownloadMediaInfo*)info{
    if (info.downloadProgress>=100) {
        return;
    }
    [[AliyunVodDownLoadManager shareManager] stopDownloadMedia:info];
}

//后台下载部分。
-(void)resignActiveDemo{
    for (AliyunDataSource *temp in self.listAddArray) {
        [[AliyunVodDownLoadManager shareManager] startDownloadMedia:temp];
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


@end
