//
//  AliyunPlaySDKListsCollectionViewCell.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/16.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AliyunPlaySDKListsCollectionViewCell;
@protocol AliyunPlaySDKListsCollectionViewCellDelegate

- (void)aliyunPlaySDKListsCollectionViewCell:(AliyunPlaySDKListsCollectionViewCell*)cell clickedButton:(UIButton*)button;

@end

@interface AliyunPlaySDKListsCollectionViewCell : UITableViewCell
@property (nonatomic, strong)UIView *playerView;
@property (nonatomic, strong) UIButton *clickedButton;
@property (nonatomic, weak)id<AliyunPlaySDKListsCollectionViewCellDelegate>cellDelegate;

@end
