//
//  AliyunPlayDataConfig.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/26.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlayDataConfig.h"

@implementation AliyunPlayDataConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.playMethod = AliyunPlayMedthodSTS;
        
        self.videoUrl = [NSURL URLWithString:@"http://player.alicdn.com/video/aliyunmedia.mp4"];
        
        self.videoId = @"";
                       
                       
        self.playAuth = @"";
        
        self.stsAccessKeyId = @"";
        self.stsAccessSecret = @"";
        self.stsSecurityToken = @"";
        
        self.mtsAccessKey = @"";
        self.mtsAccessSecret = @"";
        self.mtsStstoken = @"";
        self.mtsAuthon = @"";
        self.mtsRegion = @"cn-hangzhou";
        
    }
    return self;
}

@end
