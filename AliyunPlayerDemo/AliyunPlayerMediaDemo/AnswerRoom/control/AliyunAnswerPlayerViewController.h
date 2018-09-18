//
//  AliyunAnswerPlayerViewController.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunAnswerPlayerViewController : UIViewController
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, copy) NSString *liveId;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) BOOL isSurvivor;
@end
