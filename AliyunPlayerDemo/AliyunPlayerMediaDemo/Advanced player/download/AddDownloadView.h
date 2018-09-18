//
//  LoginView.h
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/22.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import <AliyunVodPlayerViewSDK/AliyunVodPlayerViewSDK.h>

@class AddDownloadView;
@protocol downloadViewDelegate <NSObject>
-(void) onStartDownload:(AliyunDataSource*) dataSource medianInfo:(AliyunDownloadMediaInfo*)info;
@end

@interface AddDownloadView: UIView

@property (nonatomic, strong)UILabel * fLabel;
@property (nonatomic, strong)UITextField *fTextField;

@property (nonatomic, strong)UILabel *tLabel;
@property (nonatomic, strong)UITextField *tTextField;

@property (nonatomic, strong)UILabel *thLabel;
@property (nonatomic, strong)UITextField *thTextField;

@property (nonatomic, strong)UILabel *fourthLabel;
@property (nonatomic, strong)UITextView *fourthTextView;

@property (nonatomic, strong)UIButton *getQulalitysButton;

@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, strong)UIButton *addButton;
@property (nonatomic, strong) UISegmentedControl *qualityControl;
@property (nonatomic, strong) NSMutableArray *mArray;
@property (nonatomic, strong) id<downloadViewDelegate> delegate;
-(void) initShow;
-(void) updateQualityInfo:(NSArray<AliyunDownloadMediaInfo*>*)mediaInfos;

@end
