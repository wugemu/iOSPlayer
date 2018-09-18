//
//  AliyunQuestionReportModel.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunOptionReportModel.h"

//答题汇总
@interface AliyunQuestionReportModel : NSObject
@property (nonatomic, copy)NSString *liveId; // 直播id
@property (nonatomic, copy)NSString *questionId; //题目ID
@property (nonatomic, copy)NSString *questionTitle; //题干
@property (nonatomic, assign)int totalUserNumber; //答题人数
@property (nonatomic, strong)NSArray<AliyunOptionReportModel*> *options; //答题分布列表

@end
