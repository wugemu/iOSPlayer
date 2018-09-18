//
//  ViewListTableViewCell.m
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/17.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import "DownloadListTableViewCell.h"
#import "UIView+Layout.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation DownloadListTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    [self.bgView setBackgroundColor:[UIColor colorWithRed:(0xd8)/255.0 green:(0xd8)/255.0 blue:(0xd8)/255.0 alpha:1.0]];
    [self.contentView addSubview:self.bgView];
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    self.headerImageView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:self.headerImageView];
    
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.textColor = [UIColor redColor];
    self.progressLabel.text = NSLocalizedString(@"download_status", nil);
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerImageView addSubview:self.progressLabel];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, [UIScreen mainScreen].bounds.size.width-100, 50)];
    self.nameLabel.frame = CGRectMake(100, 0, self.width-100, 50);
    
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:12.f];
    [self.contentView addSubview:self.nameLabel];
    
    _startBtn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    _startBtn.frame = CGRectMake(105,75, 50, 20);
    _startBtn.frame = CGRectMake(105, 60, 50, 30);
    
    [_startBtn addTarget:self action:@selector(startBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_startBtn setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
    [_startBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [_startBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [_startBtn setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [_startBtn setTitle:NSLocalizedString(@"start_download", nil) forState:UIControlStateNormal];
    _startBtn.clipsToBounds = YES;
    _startBtn.layer.cornerRadius = 10;
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_startBtn];
    
    _stopBtn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    _stopBtn.frame = CGRectMake(165,75, 50, 20);
    _stopBtn.frame = CGRectMake(165, 60, 50, 30);
    
    [_stopBtn addTarget:self action:@selector(stopBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_stopBtn setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
    [_stopBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [_stopBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [_stopBtn setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [_stopBtn setTitle:NSLocalizedString(@"stop_download", nil) forState:UIControlStateNormal];
    _stopBtn.clipsToBounds = YES;
    _stopBtn.layer.cornerRadius = 10;
    [_stopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_stopBtn];
    
    _playBtn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    _playBtn.frame = CGRectMake(225,75, 50, 20);
    _playBtn.frame = CGRectMake(225, 60, 50, 30);
    
    [_playBtn addTarget:self action:@selector(playBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_playBtn setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
    [_playBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [_playBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [_playBtn setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [_playBtn setTitle:NSLocalizedString(@"play_downloaded_video", nil) forState:UIControlStateNormal];
    _playBtn.clipsToBounds = YES;
    _playBtn.layer.cornerRadius = 10;
    [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_playBtn];
    
    _deleteBtn = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    _deleteBtn.frame = CGRectMake(285,75, 50, 20);
    _deleteBtn.frame = CGRectMake(285, 60, 50, 30);
    
    [_deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_deleteBtn setTitleColor:[UIColor colorWithRed:123 / 255.0 green:134 / 255.0 blue:252 / 255.0 alpha:1] forState:(UIControlStateNormal)];
    [_deleteBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateSelected)];
    [_deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [_deleteBtn setBackgroundColor:[UIColor colorWithRed:0x87 / 255.0 green:0x4b / 255.0 blue:0xe0 / 255.0 alpha:1]];
    [_deleteBtn setTitle:NSLocalizedString(@"delete_downloaded_video", nil) forState:UIControlStateNormal];
    _deleteBtn.clipsToBounds = YES;
    _deleteBtn.layer.cornerRadius = 10;
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteBtn];
    
    self.mInfo = nil;
    self.delegate = nil;
}

-(void)playBtnAction:(NSObject*)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:onClickPlay:)]) {
        [self.delegate tableViewCell:self  onClickPlay:self.mInfo];
    }
}

-(void)startBtnAction:(NSObject*)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:onClickStart:)]) {
        [self.delegate tableViewCell:self onClickStart:self.mSource];
    }
}

-(void)stopBtnAction:(NSObject*)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:onClickStop:)]) {
        [self.delegate tableViewCell:self onClickStop:self.mInfo];
    }
}

-(void)deleteBtnAction:(NSObject*)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:onClickDelete:)]) {
        [self.delegate tableViewCell:self onClickDelete:self.mInfo];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

@interface downloadCellModel()
@end
@implementation downloadCellModel
@end
