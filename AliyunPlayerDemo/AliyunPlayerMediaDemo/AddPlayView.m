//
//  LoginView.m
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/22.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import "AddPlayView.h"
#import "UIView+Layout.h"
#import <sys/utsname.h>

@interface AddPlayView(){
    int mPlayType;
}
@end
@implementation AddPlayView


-(UILabel *)fLabel{
    if (!_fLabel) {
        _fLabel = [[UILabel alloc] init];
        _fLabel.font = [UIFont systemFontOfSize:12.0f];
        [_fLabel setText:[NSString stringWithFormat:@"%@: ",NSLocalizedString(@"vid", nil)]];
        [_fLabel setTextColor:[UIColor whiteColor]];
    }
    return _fLabel;
}

-(UITextField *)fTextField{
    if (!_fTextField) {
        _fTextField = [[UITextField alloc] init];
        
#ifdef DEBUG
       [_fTextField setText:@""];
#else
       [_fTextField setText:@"6e783360c811449d8692b2117acc9212"];
#endif
        _fTextField.placeholder = NSLocalizedString(@"the vid fill in the text field by user or default setting", nil);
        _fTextField.font = [UIFont systemFontOfSize:12.0f];
        [_fTextField setTextColor:[UIColor blackColor]];
        [_fTextField setBorderStyle:UITextBorderStyleRoundedRect];
    }
    return _fTextField;
}

-(UILabel *)tLabel{
    if (!_tLabel) {
        _tLabel = [[UILabel alloc] init];
        _tLabel.font = [UIFont systemFontOfSize:12.0f];
        [_tLabel setText:[NSString stringWithFormat:@"%@: ",NSLocalizedString(@"accessKeyId", nil)]];
        [_tLabel setTextColor:[UIColor whiteColor]];
    }
    return _tLabel;
}

-(UITextField *)tTextField{
    if (!_tTextField) {
        _tTextField = [[UITextField alloc] init];
        [_tTextField setText:@""];
        _tTextField.placeholder = NSLocalizedString(@"the accessKeyId fill in the text field by user or default setting", nil);
        _tTextField.font = [UIFont systemFontOfSize:12.0f];
        [_tTextField setTextColor:[UIColor blackColor]];
        [_tTextField setBorderStyle:UITextBorderStyleRoundedRect];
    }
    return _tTextField;
}
-(UILabel *)thLabel{
    if (!_thLabel) {
        _thLabel = [[UILabel alloc] init];
        _thLabel.font = [UIFont systemFontOfSize:12.0f];
        [_thLabel setText:[NSString stringWithFormat:@"%@: ",NSLocalizedString(@"accessKeySecret", nil)]];
        [_thLabel setTextColor:[UIColor whiteColor]];
    }
    return _thLabel;
}

-(UITextField *)thTextField{
    if (!_thTextField) {
        _thTextField = [[UITextField alloc] init];
        [_thTextField setText:@""];
        _thTextField.placeholder = NSLocalizedString(@"the accessKeySecret fill in the text field by user or default setting", nil);
        _thTextField.font = [UIFont systemFontOfSize:12.0f];
        [_thTextField setTextColor:[UIColor blackColor]];
        [_thTextField setBorderStyle:UITextBorderStyleRoundedRect];
    }
    return _thTextField;
}


-(UILabel *)fourthLabel{
    if (!_fourthLabel) {
        _fourthLabel = [[UILabel alloc] init];
        _fourthLabel.font = [UIFont systemFontOfSize:12.0f];
        [_fourthLabel setText:[NSString stringWithFormat:@"%@: ",NSLocalizedString(@"securityToken", nil)]];
        [_fourthLabel setTextColor:[UIColor whiteColor]];
    }
    return _fourthLabel;
}

-(UITextView *)fourthTextView{
    if (!_fourthTextView) {
        _fourthTextView = [[UITextView alloc] init];
        _fourthTextView.textColor = [UIColor blackColor];
        _fourthTextView.backgroundColor = [UIColor whiteColor];
        _fourthTextView.font = [UIFont systemFontOfSize:12.0f];
        _fourthTextView.textAlignment = NSTextAlignmentLeft;
        _fourthTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _fourthTextView.layer.cornerRadius = 5;
        _fourthTextView.layer.masksToBounds = YES;
        _fourthTextView.text = @"";
    }
    return _fourthTextView;
}


-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
        [_cancelButton addTarget:self action:@selector(cancelBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_cancelButton setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
        [_cancelButton setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_cancelButton setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        _cancelButton.clipsToBounds = YES;
        _cancelButton.layer.cornerRadius = 20;
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

-(UIButton *)addButton{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
        [_addButton addTarget:self action:@selector(okBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_addButton setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
        [_addButton setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
        [_addButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_addButton setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
        [_addButton setTitle:NSLocalizedString(@"ok_button1", nil) forState:UIControlStateNormal];
        _addButton.clipsToBounds = YES;
        _addButton.layer.cornerRadius = 20;
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _addButton;
}


#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.6];
        
        UIControl *control = [[UIControl alloc]initWithFrame:self.bounds];
        [control addTarget:self action:@selector(hidekeybroad:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:control];
        
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
    
    }
    return self;
}

-(void)layoutSubviews{
    self.fLabel.frame = CGRectMake(10,20,120, 30);
    [self addSubview:self.fLabel];
    
    self.fTextField.frame = CGRectMake(self.fLabel.right+10, 20, self.width-120-20-10, 30);
    [self addSubview:self.fTextField];
    
    self.tLabel.frame = CGRectMake(10, self.fLabel.bottom+10,120, 30);
    [self addSubview:self.tLabel];
    
    self.tTextField.frame = CGRectMake(self.fLabel.right+10, self.fLabel.bottom+10, self.width-120-20-10, 30);
    [self addSubview:self.tTextField];
    
    self.thLabel.frame = CGRectMake(10, self.tLabel.bottom+10,120, 30);
    [self addSubview:self.thLabel];
    
    self.thTextField.frame = CGRectMake(self.fLabel.right+10, self.tLabel.bottom+10, self.width-120-20-10, 30);
    [self addSubview:self.thTextField];
    
    self.fourthLabel.frame = CGRectMake(10, self.thLabel.bottom+10,self.width-20, 30);
    [self addSubview:self.fourthLabel];
    
    self.fourthTextView.frame = CGRectMake(10, self.fourthLabel.bottom+10, self.width-20, 120);
    [self addSubview:self.fourthTextView];
    
    self.cancelButton.frame = CGRectMake(self.width/2-100-20, self.height-60, 100, 40);
    [self addSubview:self.cancelButton];
    
    self.addButton.frame = CGRectMake(self.width/2+20, self.height-60, 100, 40);
    [self addSubview:self.addButton];
    
#ifdef DEBUG
    
#else
    self.tLabel.hidden = YES;
    self.tTextField.hidden = YES;
    self.thLabel.hidden=  YES;
    self.thTextField.hidden = YES;
    self.fourthLabel.hidden = YES;
    self.fourthTextView.hidden = YES;
#endif
    
}


-(void)hidekeybroad:(UIControl *)control{
    [self.fTextField resignFirstResponder];
    [self.tTextField resignFirstResponder];
    [self.thTextField resignFirstResponder];
    [self.fourthTextView resignFirstResponder];
}


- (void)cancelBtnAction:(UIButton *)sender {
    self.hidden = YES;
    
}

-(NSString*)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return deviceString;
}

- (void)okBtnAction:(UIButton *)sender {
    
#ifdef DEBUG
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickAddPlay:vid:accessKeyId:accessKeySecret:securityToken:)]) {
        [self.delegate onClickAddPlay:mPlayType
                                  vid:self.fTextField.text
                          accessKeyId:self.tTextField.text
                      accessKeySecret:self.thTextField.text
                        securityToken:self.fourthTextView.text];
    }
    
#else
   
    NSLog(@"release");
    
    sender.enabled = NO;
    
    NSString *deviceModel = [self getDeviceModel];
    NSString *vid = @"6e783360c811449d8692b2117acc9212";
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *urlstring = [NSString stringWithFormat:@"https://demo-vod.cn-shanghai.aliyuncs.com/voddemo/CreateSecurityToken?BusinessType=vodai&TerminalType=iphone&DeviceModel=%@&UUID=%@&VideoId=%@&AppVersion=1.0.0,",deviceModel,uuid,vid];
    
    NSURL *urlAddr = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:urlAddr cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    NSURLResponse *myResponse=nil;
    NSError *myErro=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&myResponse error:&myErro];
    
    if (data == nil) {
        sender.enabled = YES;
    }
    else {
        if (myErro != nil) {
            sender.enabled = YES;
        }
        
        NSError *dictError;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&dictError];
        if (dict[@"SecurityTokenInfo"]) {
            NSDictionary *result = dict[@"SecurityTokenInfo"];
            NSString *keyid = result[@"AccessKeyId"];
            NSString *secret = result[@"AccessKeySecret"];
            NSString *sts = result[@"SecurityToken"];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickAddPlay:vid:accessKeyId:accessKeySecret:securityToken:)]) {
                [self.delegate onClickAddPlay:mPlayType
                                          vid:vid
                                  accessKeyId:keyid
                              accessKeySecret:secret
                                securityToken:sts];
                sender.enabled = YES;
            }
            
        }
        
        sender.enabled = YES;
    }
    
#endif
    
self.hidden = YES;
    
}



-(void)setAddPlayType:(int)Type{
    mPlayType = Type;
}

@end
