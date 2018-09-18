//
//  AliyunPlaySDKDemoFullScreenScrollCollectionViewCell.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/16.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlaySDKDemoFullScreenScrollCollectionViewCell.h"
#import "Until.h"
#import "UIView+Layout.h"

@interface AliyunPlaySDKDemoFullScreenScrollCollectionViewCell()

@end
@implementation AliyunPlaySDKDemoFullScreenScrollCollectionViewCell
- (UIView *)playerView{
    if(!_playerView){
        _playerView = [[UIView alloc] init];
    }
    return _playerView;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
        self.playerView.frame= CGRectMake(10, 10, SCREEN_WIDTH-20, SCREEN_HEIGHT-20);
        self.playerView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.playerView];
    }
    return self;
}
-(void)layoutSubviews{
    
}


@end
