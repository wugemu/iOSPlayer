//
//  AdvancedPlayerViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/11/7.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AdvancedPlayerViewController.h"
#import "AddPlayView.h"

#import "AliyunPlaySDKDemoOneViewController.h"
#import "AliyunTimeShiftLiveViewController.h"
#import "AliyunPlaySDKListsAutoViewController.h"
#import "AliyunPlaySDKDemoFullScreenScrollViewController.h"
#import "DownloadViewController.h"
#import "AliyunContinuousViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface AdvancedPlayerViewController ()<UITableViewDelegate,UITableViewDataSource,addPlayDelegate>
@property(nonatomic, strong )UITableView *tableView;
@property(nonatomic, strong)NSArray *titlesAry;
@property(nonatomic, strong)AddPlayView *mAddView;

@property (nonatomic, assign) BOOL isChangedRow;

@end

@implementation AdvancedPlayerViewController

-(NSArray *)titlesAry{
    if (!_titlesAry) {
        _titlesAry = @[NSLocalizedString(@"Basic function demo of Vod by using vid and sts", nil),
                       NSLocalizedString(@"Time-shift of live player Demo", nil),
                       NSLocalizedString(@"Autoplay demo of multi-video by using url", nil),
                       NSLocalizedString(@"Full screen slide play demo by using url", nil),
                       NSLocalizedString(@"Continuous play demo", nil),
                       NSLocalizedString(@"Breakpoints download demo", nil),
                       
                       ];
    }
    return _titlesAry;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        UIView *footview = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = footview;
    }
    return  _tableView;
}

-(AddPlayView *)mAddView{
    if (!_mAddView) {
        _mAddView = [[AddPlayView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, 44, 300, 400)];
        _mAddView.hidden = YES;
        _mAddView.delegate = self;
    }
    return _mAddView;
}

- (void)initView{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.mAddView];
}

- (void)InitNaviBar{
    NSString *backString = NSLocalizedString(@"Back",nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitNaviBar];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden  = NO;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mAddView.frame = CGRectMake((SCREEN_WIDTH-300)/2, 44, 300, 400);
}

#pragma mark - tableDelegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.titlesAry.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"democell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];\
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.titlesAry[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)repeatDelay{
    self.isChangedRow = false;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    if (self.isChangedRow == false) {
        self.isChangedRow = true;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatDelay) object:nil];
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5];
        
        switch (indexPath.row) {
            case 0:
            {
                /*********点播播放功能(vid+playAuth方式演示)**********/
                self.mAddView.hidden = NO;
            }
                break;
            case 1:
            {
                /*********直播时移**********/
                AliyunTimeShiftLiveViewController *vc = [[AliyunTimeShiftLiveViewController alloc] init];
                vc.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                /*********多视频列表自动播放(url方式演示)**********/
                AliyunPlaySDKListsAutoViewController *demoTwo = [[AliyunPlaySDKListsAutoViewController alloc] init];
                demoTwo.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:demoTwo animated:YES];
                
            }
                break;
            case 3:
            {
                /*********全屏滑动切换播放(url方式演示)***********/
                AliyunPlaySDKDemoFullScreenScrollViewController *demoThree = [[AliyunPlaySDKDemoFullScreenScrollViewController alloc] init];
                demoThree.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:demoThree animated:YES];
            }
                break;
                
            case 4:
            {
                AliyunContinuousViewController *vc = [[AliyunContinuousViewController alloc] init];
                vc.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 5 :
            {
                /*********多视频断点下载演示*********************/
                DownloadViewController *demoFour =  [DownloadViewController sharedViewController];
                demoFour.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:demoFour animated:YES];
            }
                break;
            default:
                break;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else{
        return;
    }
    
    
}


-(void)onClickAddPlay:(int)clickType vid:(NSString *)vid accessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken{
    
    AliyunPlaySDKDemoOneViewController *demoOne = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"AliyunPlaySDKDemoOneViewController"];
    demoOne.title = NSLocalizedString(@"Basic function demo of Vod by using vid and sts", nil);
    demoOne.videoId = vid;
    demoOne.accessKeyId = accessKeyId;
    demoOne.accessKeySecret = accessKeySecret;
    demoOne.securityToken = securityToken;
    [self.navigationController pushViewController:demoOne animated:YES];
    
}

- (void)onClickAddPlay:(int)clickType vid:(NSString *)vid playAuth:(NSString *)playAuth {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
