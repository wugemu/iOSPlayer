//
//  ALiyunPlaySDKCheckToolViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/26.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "ALiyunPlaySDKCheckToolViewController.h"
#import <WebKit/WKWebView.h>

#define CHECTTOOLURL @"https://player.alicdn.com/detection.html?from=iOS"



@interface ALiyunPlaySDKCheckToolViewController ()
@property(nonatomic,strong)WKWebView *webView;
@end

@implementation ALiyunPlaySDKCheckToolViewController

#pragma mark - naviBar
- (void)naviBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemCliceked:)];
}

- (void)leftBarButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = NSLocalizedString(@"Debug tools demo", nil);
    [self naviBar];
    [self initWebView];
    
    
    // Do any additional setup after loading the view.
}

- (void)initWebView{

    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    
    NSString *playStr = @"";
    
    playStr = [NSString stringWithFormat:@"%@&source=%@",CHECTTOOLURL,self.playUrlPath];

    NSURL *url = [NSURL URLWithString:playStr];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
