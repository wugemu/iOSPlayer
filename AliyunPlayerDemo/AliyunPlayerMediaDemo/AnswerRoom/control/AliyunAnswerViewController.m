//
//  AliyunAnswerViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunAnswerViewController.h"
#import "AliyunAnswerPlayerViewController.h"
#import "UIView+Layout.h"
#import "AliyunReuqestManager.h"
#import <sys/utsname.h>
#import "AliyunAnswerHeader.h"



@interface AliyunAnswerViewController ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *liveIdTextLabel;
@property (nonatomic, strong) UITextField *liveIdTextField;

@property (nonatomic, strong) UIButton *button ;
@property (nonatomic, strong) UIControl *scrollviewControl;

@property (nonatomic, assign) BOOL isChangedRow;
@property (nonatomic, copy) NSString *playUrl;

@end

@implementation AliyunAnswerViewController


- (UILabel *)textLabel{
    if(!_textLabel){
        _textLabel = [[UILabel alloc] init];
        _textLabel.text  = NSLocalizedString(@"URL", nil);
        _textLabel.font = [UIFont systemFontOfSize:10.0f];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

- (UILabel *)liveIdTextLabel{
    if(!_liveIdTextLabel){
        _liveIdTextLabel = [[UILabel alloc] init];
        _liveIdTextLabel.text  = NSLocalizedString(@"Live Id", nil);
        _liveIdTextLabel.font = [UIFont systemFontOfSize:10.0f];
        _liveIdTextLabel.textColor = [UIColor blackColor];
        _liveIdTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _liveIdTextLabel;
}


-(UIButton *)button{
    if(!_button){
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setTitle:NSLocalizedString(@"start answer", nil) forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor blueColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    return _button;
}

-(UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.font = [UIFont systemFontOfSize:10.0f];
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.text = LIVE_URL;
//        _textField.keyboardType = UIKeyboardTypeNumberPad;
//        _textField.delegate = self;
//        [_textField addTarget:self action:@selector(bufferPercentageTextFieldClicked:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _textField;
}


-(UITextField *)liveIdTextField{
    if (!_liveIdTextField) {
        _liveIdTextField = [[UITextField alloc] init];
        _liveIdTextField.borderStyle = UITextBorderStyleRoundedRect;
        _liveIdTextField.font = [UIFont systemFontOfSize:10.0f];
        _liveIdTextField.textAlignment = NSTextAlignmentLeft;
        _liveIdTextField.text = @"";
        //        _textField.keyboardType = UIKeyboardTypeNumberPad;
        //        _textField.delegate = self;
//        [_liveIdTextField addTarget:self action:@selector(bufferPercentageTextFieldClicked:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _liveIdTextField;
}

-(UIControl *)scrollviewControl{
    if (!_scrollviewControl) {
        _scrollviewControl = [[UIControl alloc] init];
        [_scrollviewControl addTarget:self action:@selector(controlChanged:) forControlEvents:UIControlEventTouchDown];
    }
    return _scrollviewControl;
}
- (void)controlChanged:(UIControl *)sender{
    [self.textField resignFirstResponder];
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
    [self.textField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    sender.enabled = YES;
}
- (void)LogButtonItemCliceked:(UIBarButtonItem*)sender{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitNaviBar];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
//    self.title = NSLocalizedString(@"Playback settings", nil);
    
    self.textLabel.frame = CGRectMake(20, 40, self.view.width-40, 30);
    [self.view addSubview: self.textLabel];
    
    self.textField.frame = CGRectMake(20, self.textLabel.bottom+20, self.view.width-40, 30);
    [self.view addSubview:self.textField];
    
    self.liveIdTextLabel.frame = CGRectMake(20, self.textField.bottom+20, self.view.width-40, 30);
//    [self.view addSubview:self.liveIdTextLabel];
    
    self.liveIdTextField.frame = CGRectMake(20, self.liveIdTextLabel.bottom+20, self.view.width-40, 30);
//    [self.view addSubview:self.liveIdTextField];
    
    
    self.button.frame = CGRectMake((self.view.width-80)/2, self.liveIdTextField.bottom+20, 80, 30);
    [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)repeatDelay{
    self.isChangedRow = false;
}

- (void)buttonClicked:(UIButton *)sender{
    [self.textField resignFirstResponder];
    [self.liveIdTextField resignFirstResponder];
    
    self.playUrl = self.textField.text;
    if (!self.playUrl||self.playUrl.length<1) {
     return;
    }
    
    if (self.isChangedRow == false) {
        self.isChangedRow = true;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatDelay) object:nil];
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5];
        
        // uuid
        NSString * userId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];;
        NSString *strUrl = ONLINE_HOST;
        NSString *requestUrl = [NSString stringWithFormat:@"%@/app/enter",strUrl];
        if (![self.textField.text containsString:@"//"]) {
            return;
        }
        
        NSString *str = [self.textField.text componentsSeparatedByString:@"//"][1];
        NSString *liveId = strUrl;
        if ([str hasSuffix:@".flv"]) {
            liveId = [str substringToIndex: str.length-4];
        }
        else
        {
            liveId =  str;
        }
        NSDictionary *params = @{@"liveId" : liveId,
                                 @"userId" : userId,
                                 };
        [AliyunReuqestManager doPostWithUrl:requestUrl params:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [self alertMessage:error.localizedDescription];
                return ;
            }
            NSError *dicError ;
            NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dicError];
            if (dicError) {
                [self alertMessage:dicError.localizedDescription];
                return ;
            }else{
                NSString *result = dict[@"result"][@"code"];
                if ([result isEqualToString:@"Success"]) {
                    NSString *userStatus = [NSString stringWithFormat:@"%@/app/getUserStatus",ONLINE_HOST];
                    [AliyunReuqestManager doPostWithUrl:userStatus params:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (error) {
                            [self alertMessage:error.localizedDescription];
                            return ;
                        }
                        NSError *dicError ;
                        NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&dicError];
                        if (dicError) {
                            [self alertMessage:dicError.localizedDescription];
                            return ;
                        }
                        BOOL isBool =  [dict[@"data"][@"isSurvivor"] boolValue];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            AliyunAnswerPlayerViewController *pc =[[AliyunAnswerPlayerViewController alloc] init];
                            CATransition *animation = [CATransition animation];
                            animation.duration = 1.0;
                            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];;
                            animation.type = @"pageCurl";
                            animation.subtype = kCATransitionFromRight;
                            [self.view.window.layer addAnimation:animation forKey:nil];
                            pc.playUrl = self.playUrl;
                            pc.liveId = liveId;
                            pc.userId = userId;
                            pc.isSurvivor = isBool;
                            [self.navigationController pushViewController:pc animated:NO];
                        });
                    }];
                }else{
                    [self alertMessage:result];
                }
            }
        }];
    }else{
        return;
    }
}

- (void)alertMessage:(NSString *)message{
    if ([NSThread isMainThread]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
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
