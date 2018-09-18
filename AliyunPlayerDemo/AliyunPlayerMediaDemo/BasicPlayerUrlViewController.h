//
//  BasicPlayerUrlViewController.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/12/11.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AliyunUserPlayMethod) {
    AliyunUserPlayMethodVod = 0,
    AliyunUserPlayMethodLive,
};

@interface BasicPlayerUrlViewController : UIViewController
@property (nonatomic, assign)AliyunUserPlayMethod playerMethod;//0,点播 ；1，直播
@end
