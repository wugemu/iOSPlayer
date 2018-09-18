//
//  ViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "AddPlayView.h"

#import "BasicPlayerViewController.h"
#import "AdvancedPlayerViewController.h"
#import "AliyunPlayerMediaUIDemoViewController.h"
#import "ALiyunPlaySDKCheckToolViewController.h"
#import "AliyunPlayerVodPlayCopyrightViewController.h"

//答题直播间
#import "AliyunAnswerViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,addPlayDelegate>

@property(nonatomic, strong )UITableView *tableView;
@property(nonatomic, strong)NSArray *titlesAry;
@property(nonatomic, strong)AddPlayView *mAddView;
@property (nonatomic, strong)UILabel *versionLabel;

@property (nonatomic, assign) BOOL isChangedRow;

@end

@implementation ViewController

- (UILabel *)versionLabel
{
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.text = NSLocalizedString(@"version", nil);
        _versionLabel.textColor = [UIColor blackColor];
        _versionLabel.font = [UIFont systemFontOfSize:12.0f];
        _versionLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _versionLabel;
    
}

-(NSArray *)titlesAry{
    if (!_titlesAry) {
        _titlesAry = @[NSLocalizedString(@"answer room", nil),
                       NSLocalizedString(@"Basic player", nil),
                       NSLocalizedString(@"Advanced player", nil),
                       NSLocalizedString(@"UI player", nil),
                       NSLocalizedString(@"Debug tools demo", nil),
                       NSLocalizedString(@"Copyright information", nil),
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
    [self.view addSubview:self.versionLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =  NSLocalizedString(@"Player Demo", nil);
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
    self.versionLabel.frame = CGRectMake(0, self.view.bounds.size.height-60, self.view.bounds.size.width, 40);
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
        // 在下面实现点击cell需要实现的逻辑就可以了
        switch (indexPath.row) {
            case 0:
            {
                /*********答题直播间**********/
                AliyunAnswerViewController *demoTwo = [[AliyunAnswerViewController alloc]     init];
                demoTwo.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:demoTwo animated:YES];
            }
                break;
            case 1:
            {
                /*********基础播放器**********/
                BasicPlayerViewController *demoTwo = [[BasicPlayerViewController alloc]     init];
                demoTwo.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:demoTwo animated:YES];
            }
                break;
            case 2:
            {
                /*********高级播放器**********/
                AdvancedPlayerViewController *demoTwo = [[AdvancedPlayerViewController alloc]     init];
                demoTwo.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:demoTwo animated:YES];
                
            }
                break;
            case 3:
            {
                /*********完整UI播放器基本功能演示***************/
                self.mAddView.hidden = NO;
            }
                break;
            case 4:
            {
                /*********播放器诊断工具演示*********************/
                ALiyunPlaySDKCheckToolViewController *toolVC = [[ALiyunPlaySDKCheckToolViewController alloc] init];
                [self.navigationController pushViewController:toolVC animated:YES];
            }
                break;
            case 5:
            {
                /*********版权信息*********************/
                AliyunPlayerVodPlayCopyrightViewController * vc = [[AliyunPlayerVodPlayCopyrightViewController alloc] init];
                vc.title = self.titlesAry[indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
                
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
    AliyunPlayerMediaUIDemoViewController *demoFive = [[AliyunPlayerMediaUIDemoViewController alloc] init];
    demoFive.videoId = vid;
    demoFive.accessKeyId = accessKeyId;
    demoFive.accessKeySecret = accessKeySecret;
    demoFive.securityToken = securityToken;
    [self presentViewController:demoFive animated:YES completion:nil];
}

- (void)onClickAddPlay:(int)clickType vid:(NSString *)vid playAuth:(NSString *)playAuth {
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
