//
//  AliyunPlayDataConfig.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/26.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 参数： AliyunPlayMedthod 播放方式
 * 说明：
 */
typedef NS_ENUM(NSInteger,AliyunPlayMedthod){
    AliyunPlayMedthodPlayAuth = 0,  //vid+playauth
    AliyunPlayMedthodSTS,           //vid+sts
    AliyunPlayMedthodMTS,           //vid+mts
    AliyunPlayMedthodURL,           //url
};

@interface AliyunPlayDataConfig : NSObject

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, assign) AliyunPlayMedthod playMethod;

@property (nonatomic, copy) NSString * stsAccessKeyId;
@property (nonatomic, copy) NSString * stsAccessSecret;
@property (nonatomic, copy) NSString * stsSecurityToken;

@property (nonatomic, copy) NSString * playAuth;

@property (nonatomic, copy) NSString * mtsAccessKey;
@property (nonatomic, copy) NSString * mtsAccessSecret;
@property (nonatomic, copy) NSString * mtsStstoken;
@property (nonatomic, copy) NSString * mtsAuthon;
@property (nonatomic, copy) NSString * mtsRegion;


@end
