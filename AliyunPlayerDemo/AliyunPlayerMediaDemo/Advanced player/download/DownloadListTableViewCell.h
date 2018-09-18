//
//  ViewListTableViewCell.h
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/17.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import <AliyunVodPlayerViewSDK/AliyunVodPlayerViewSDK.h>

@class DownloadListTableViewCell;

@protocol cellClickDelegate <NSObject>
-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickDelete:(AliyunDownloadMediaInfo*)info;
-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickPlay:(AliyunDownloadMediaInfo*)info;
-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickStart:(AliyunDataSource*)dataSource;
-(void) tableViewCell:(DownloadListTableViewCell *)tableViewCell onClickStop:(AliyunDownloadMediaInfo*)info;
@end

@interface downloadCellModel : NSObject
@property (nonatomic, strong) AliyunDownloadMediaInfo *mInfo;
@property (nonatomic, strong) AliyunDataSource *mSource;
@property (nonatomic, assign) BOOL mCanStop;
@property (nonatomic, assign) BOOL mCanPlay;
@property (nonatomic, assign) BOOL mCanStart;
@property (nonatomic, assign) NSInteger modelTag;

@end

@interface DownloadListTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *progressLabel;
//@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *stopBtn;

@property (nonatomic, strong) id<cellClickDelegate> delegate;
@property (nonatomic, strong) AliyunDownloadMediaInfo *mInfo;
@property (nonatomic, strong) AliyunDataSource *mSource;

@property (nonatomic, assign) NSInteger cellTag;

-(void)startBtnAction:(NSObject*)sender;
-(void)stopBtnAction:(NSObject*)sender;
-(void)deleteBtnAction:(NSObject*)sender;

@end
