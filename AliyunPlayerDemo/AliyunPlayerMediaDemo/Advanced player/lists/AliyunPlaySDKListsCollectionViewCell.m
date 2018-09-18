//
//  AliyunPlaySDKListsCollectionViewCell.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/16.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlaySDKListsCollectionViewCell.h"
#import "Until.h"
#import "UIView+Layout.h"
@interface AliyunPlaySDKListsCollectionViewCell()


@end
@implementation AliyunPlaySDKListsCollectionViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


- (UIView *)playerView{
    if(!_playerView){
        _playerView = [[UIView alloc] init];
    }
    return _playerView;
}

-(UIButton *)clickedButton{
    if(!_clickedButton){
        _clickedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_clickedButton setImage:[self imagePlay] forState:UIControlStateNormal];
    }
    return _clickedButton;
}


-(void)layoutSubviews{
    
    self.playerView.frame= CGRectMake(10, 10, self.contentView.width-20, self.contentView.height-20);
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.playerView];
    
    self.clickedButton.frame = CGRectMake((self.width-50)/2, (self.height-50)/2, 50, 50);
    self.clickedButton.layer.masksToBounds = YES;
    self.clickedButton.layer.cornerRadius = 25;
    self.clickedButton.layer.borderWidth = 1;
    self.clickedButton.backgroundColor = [UIColor grayColor];
    [self.clickedButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.clickedButton];
    
}

- (void)buttonClicked:(UIButton*)sender{
    
    if (self.cellDelegate) {
        [self.cellDelegate aliyunPlaySDKListsCollectionViewCell:self clickedButton:sender];
    }
}

- (UIImage *)imagePlay {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", @"AliyunImageSource.bundle", @"al_play_start"]];
}
- (UIImage *)imagePause {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", @"AliyunImageSource.bundle", @"al_play_stop"]];
}
@end
