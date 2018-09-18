//
//  Until.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/12/21.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

@interface Until : NSObject
+ (NSString*)iphoneType;
+ (NSString *)getMMSSFromSS:(NSString *)totalTime;
@end
