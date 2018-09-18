//
//  AppDelegate.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/14.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AppDelegate.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import "DownloadViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    //获取加密文件
    NSString *str =  [[NSBundle mainBundle] pathForResource:@"encryptedApp" ofType:@"dat"];
    [[AliyunVodDownLoadManager shareManager] setEncrptyFile:str];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

UIBackgroundTaskIdentifier taskId;
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //需要后台下载打开
//    taskId = [application beginBackgroundTaskWithExpirationHandler:^{
//        [application endBackgroundTask:taskId];
//    }];
//
//    //下载数据部分。DownloadViewController单例。
//     [[DownloadViewController sharedViewController] resignActiveDemo];
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    
    
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
