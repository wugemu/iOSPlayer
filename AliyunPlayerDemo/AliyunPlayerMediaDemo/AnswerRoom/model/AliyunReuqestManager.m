//
//  AliyunReuqestManager.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/18.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunReuqestManager.h"

@implementation AliyunReuqestManager


+ (void)doGetWithUrl:(NSString *)url completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler{
    NSURL *tempUrl = [NSURL URLWithString:url];
    NSURLRequest *request =[NSURLRequest requestWithURL:tempUrl];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [sessionDataTask resume];
    [session finishTasksAndInvalidate];
}

+ (void)doPostWithUrl:(NSString *)url params:(NSDictionary*)params completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler{

    NSURL *tempUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:tempUrl];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10;
    
    // 设置请求头
    NSData *json = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = json;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [sessionDataTask resume];
}

@end
