//
//  LoginView.m
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/22.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import "AddDownloadView.h"
#import "UIView+Layout.h"
#import <sys/utsname.h>
#import "AliyunPlayDataConfig.h"

#import "AliyunPlayDataConfig.h"

@interface AddDownloadView()
@property (nonatomic, strong) AliyunPlayDataConfig *config;

@end

@implementation AddDownloadView

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

-(UIButton *)getQulalitysButton{
    if (!_getQulalitysButton) {
        _getQulalitysButton = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
        [_getQulalitysButton addTarget:self action:@selector(qualityRequest:) forControlEvents:(UIControlEventTouchUpInside)];
        [_getQulalitysButton setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
        [_getQulalitysButton setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
        [_getQulalitysButton.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_getQulalitysButton setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
        [_getQulalitysButton setTitle:NSLocalizedString(@"Get all definition", nil) forState:UIControlStateNormal];
        _getQulalitysButton.clipsToBounds = YES;
        _getQulalitysButton.layer.cornerRadius = 10;
        [_getQulalitysButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _getQulalitysButton;
    
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
        [_addButton setTitle:NSLocalizedString(@"ok_button", nil) forState:UIControlStateNormal];
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
        
        _qualityControl = nil;
        _mArray = [[NSMutableArray alloc] init];
        _delegate = nil;
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
    
    self.getQulalitysButton.frame = CGRectMake(10, self.fourthTextView.bottom+10, 120, 30);
    [self addSubview:self.getQulalitysButton];
    
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

-(NSString*)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

- (void)qualityRequest:(UIButton *)sender {
    [self.fTextField resignFirstResponder];
    [self.tTextField resignFirstResponder];
    [self.thTextField resignFirstResponder];
    [self.fourthTextView resignFirstResponder];
    
#ifdef DEBUG
    AliyunDataSource* source = [[AliyunDataSource alloc] init];
    
    self.config = [[AliyunPlayDataConfig alloc] init];
    if (self.fTextField.text.length>0&&self.tTextField.text.length>0&&self.thTextField.text.length>0) {
        self.config.videoId = self.fTextField.text;
        self.config.stsAccessKeyId = self.tTextField.text;
        self.config.stsAccessSecret = self.thTextField.text;
        self.config.stsSecurityToken = self.fourthTextView.text;
    }
    source.requestMethod= (int)self.config.playMethod;
    switch (source.requestMethod) {
        case AliyunVodRequestMethodPlayAuth:
            {
                source.vid = self.config.videoId;
                source.playAuth = self.config.playAuth;
            }
            break;
        case AliyunVodRequestMethodStsToken:
            {
                
                source.vid = self.config.videoId;
                source.stsData = [[AliyunStsData alloc] init];
                source.stsData.accessKeyId = self.config.stsAccessKeyId;
                source.stsData.accessKeySecret = self.config.stsAccessSecret;
                source.stsData.securityToken = self.config.stsSecurityToken;
            }
            break;
        case AliyunVodRequestMethodMtsToken:
            {
                source.vid = self.config.videoId;
                source.mtsData = [[AliyunMtsData alloc] init];
                source.mtsData.accessKeyId = self.config.mtsAccessKey;
                source.mtsData.accessKeySecret = self.config.mtsAccessSecret;
                source.mtsData.securityToken = self.config.mtsStstoken;
                source.mtsData.authInfo = self.config.mtsAuthon;
                source.mtsData.region = self.config.mtsRegion;
                source.mtsData.mtsHlsUriToken = @"";
            }
            break;
        default:
            break;
    }
    [[AliyunVodDownLoadManager shareManager] prepareDownloadMedia:source];
    
#else
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
            
            AliyunDataSource* source = [[AliyunDataSource alloc] init];
            source.vid = vid;
            source.requestMethod= 1;
            source.stsData = [[AliyunStsData alloc] init];
            source.stsData.accessKeyId = keyid;
            source.stsData.accessKeySecret = secret;
            source.stsData.securityToken = sts;
            
            self.tTextField.text = keyid;
            self.thTextField.text = secret;
            self.fourthTextView.text = sts;
            [[AliyunVodDownLoadManager shareManager] prepareDownloadMedia:source];
            
        }
        
        sender.enabled = YES;
    }
    
#endif
    
    
    
    
}

- (void)cancelBtnAction:(UIButton *)sender {
    self.hidden = YES;
}

- (void)okBtnAction:(UIButton *)sender {
    if (_qualityControl.enabled == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Please request definition list first", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button1", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
#ifdef DEBUG
    AliyunDownloadMediaInfo* info = [_mArray objectAtIndex:_qualityControl.selectedSegmentIndex];
    AliyunDataSource* source = [[AliyunDataSource alloc] init];
    
    source.requestMethod= (int)self.config.playMethod;
    
    source.format = info.format;
    source.quality = info.quality;
    source.videoDefinition = info.videoDefinition;
    
    switch (source.requestMethod) {
        case AliyunVodRequestMethodPlayAuth:
        {
            source.vid = self.config.videoId;
            source.playAuth = self.config.playAuth;
        }
            break;
        case AliyunVodRequestMethodStsToken:
        {
            source.vid = self.config.videoId;
            source.stsData = [[AliyunStsData alloc] init];
            source.stsData.accessKeyId = self.config.stsAccessKeyId;
            source.stsData.accessKeySecret = self.config.stsAccessSecret;
            source.stsData.securityToken = self.config.stsSecurityToken;
        }
            break;
        case AliyunVodRequestMethodMtsToken:
        {
            source.vid = self.config.videoId;
            source.mtsData = [[AliyunMtsData alloc] init];
            source.mtsData.accessKeyId = self.config.mtsAccessKey;
            source.mtsData.accessKeySecret = self.config.mtsAccessSecret;
            source.mtsData.securityToken = self.config.mtsStstoken;
            source.mtsData.authInfo = self.config.mtsAuthon;
            source.mtsData.region = self.config.mtsRegion;
            source.mtsData.mtsHlsUriToken = @"";
        }
            break;
        default:
            break;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(onStartDownload:medianInfo:)]) {
        [_delegate onStartDownload:source medianInfo:info];
    }

#else
    AliyunDownloadMediaInfo* info = [_mArray objectAtIndex:_qualityControl.selectedSegmentIndex];
    AliyunDataSource* source = [[AliyunDataSource alloc] init];
    source.requestMethod= AliyunVodRequestMethodStsToken;
    source.format = info.format;
    source.quality = info.quality;
    source.videoDefinition = info.videoDefinition;
    
    source.vid = info.vid;
    source.stsData = [[AliyunStsData alloc] init];
    source.stsData.accessKeyId = self.tTextField.text;
    source.stsData.accessKeySecret = self.thTextField.text ;
    source.stsData.securityToken = self.fourthTextView.text;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onStartDownload:medianInfo:)]) {
        [_delegate onStartDownload:source medianInfo:info];
    }
    
#endif

    self.hidden = YES;
    
}

-(void) initShow{
    if (_qualityControl) {
        [_qualityControl removeFromSuperview];
        _qualityControl = nil;
    }
    [_mArray removeAllObjects];
}

-(void) updateQualityInfo:(NSArray<AliyunDownloadMediaInfo*>*)mediaInfos{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([mediaInfos count]==0) {
            return;
        }
        if (_qualityControl) {
            [_qualityControl removeFromSuperview];
            _qualityControl = nil;
        }
        [_mArray removeAllObjects];
        NSMutableArray* array = [[NSMutableArray alloc] init];
        NSArray *segmentedArray = [[NSArray alloc] initWithObjects:
                                   NSLocalizedString(@"FD", nil),
                                   NSLocalizedString(@"LD", nil),
                                   NSLocalizedString(@"SD", nil),
                                   NSLocalizedString(@"HD", nil),
                                   NSLocalizedString(@"2K", nil),
                                   NSLocalizedString(@"4K", nil),
                                   NSLocalizedString(@"OD", nil),nil];
        
        for (AliyunDownloadMediaInfo* info  in mediaInfos) {
            NSString* text = @"";
            if (info.videoDefinition != nil) {
                text = info.videoDefinition;
            }else{
                text = [segmentedArray objectAtIndex:info.quality];
            }
            
            NSString* sizeStr = [[NSString alloc] initWithFormat:@"%@(%.2fM)",text,info.size*1.0f/(1024*1024)];
            [array addObject:sizeStr];
            [_mArray addObject:info];
        }
        
        if ([array count]>0) {
            _qualityControl = [[UISegmentedControl alloc]initWithItems:array];
            _qualityControl.frame = CGRectMake(20,self.getQulalitysButton.bottom+10,self.width
                                               -40,35);
            _qualityControl.selectedSegmentIndex = 0;
            _qualityControl.tintColor = [UIColor whiteColor];
            [self addSubview:_qualityControl];
        }
    });
}

@end
