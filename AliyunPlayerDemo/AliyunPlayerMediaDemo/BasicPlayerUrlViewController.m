//
//  BasicPlayerUrlViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/12/11.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "BasicPlayerUrlViewController.h"
#import "UIView+Layout.h"
#import "AliyunPlayerVodPlayViewController.h"
#import "AliyunPlayerLivePlayViewController.h"

@interface BasicPlayerUrlViewController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIControl *control;

@end

@implementation BasicPlayerUrlViewController

-(UIControl *)control{
    if (!_control) {
        _control = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        [_control addTarget:self action:@selector(controlClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _control;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.placeholder = NSLocalizedString(@"input playurl", nil);
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.textAlignment = NSTextAlignmentLeft;
    }
    return _textField;
}

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setTitle:NSLocalizedString(@"input mediaPlayer", nil) forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _button.layer.borderColor = [UIColor blackColor].CGColor;
        _button.layer.masksToBounds = YES;
        _button.layer.borderWidth = 0.5;
        _button.layer.cornerRadius = 15;
        
    }
    return _button;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.control];
    [self.view addSubview:self.textField];
    if (self.playerMethod == AliyunUserPlayMethodVod) {
        self.textField.text = @"http://player.alicdn.com/video/aliyunmedia.mp4";
    }else if (self.playerMethod == AliyunUserPlayMethodLive){
        self.textField.text = @"rtmp://10.42.0.1/videotest";
    }
    [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.textField.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 30);
    self.button.frame = CGRectMake((self.view.width-200)/2.0, self.textField.bottom+20, 200, 30);
}

- (void)controlClicked:(UIControl *)sender{
    [self.textField resignFirstResponder];
}

- (void)buttonClicked:(UIButton *)sender{
    [self.textField resignFirstResponder];
    sender.enabled = NO;
    switch (self.playerMethod) {
        case AliyunUserPlayMethodVod:
        {
            /*********点播播放功能**********/
            AliyunPlayerVodPlayViewController *demoOne = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"AliyunPlayerVodPlayViewController"];
            demoOne.title = NSLocalizedString(@"Basic function demo of Vod", nil);
            demoOne.tempUrl = self.textField.text;
            [self.navigationController pushViewController:demoOne animated:YES];
        }
            break;
        case AliyunUserPlayMethodLive:
        {
            /*********直播播放基本功能**********/
            AliyunPlayerLivePlayViewController *demoTwo = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"AliyunPlayerLivePlayViewController"];
            demoTwo.title = NSLocalizedString(@"Basic function demo of live", nil);
            demoTwo.tempUrl = self.textField.text;
            [self.navigationController pushViewController:demoTwo animated:YES];
        }
            break;
        default:
            {
                NSLog(@"error");
            }
            break;
    }
    sender.enabled = YES;
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
