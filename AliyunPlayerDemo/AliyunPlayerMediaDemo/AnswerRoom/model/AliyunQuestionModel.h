//
//  AliyunQuestionModel.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunOptionReportModel.h"

//题目
@interface AliyunQuestionModel : NSObject
@property (nonatomic, copy) NSString *liveId;
@property (nonatomic, copy)NSString *questionId; //题目ID
@property (nonatomic, copy)NSString *questionTitle; //题干
@property (nonatomic, strong)NSArray<AliyunOptionReportModel*> *options; //选项列表
@property (nonatomic, assign)int remainSeconds; //答题剩余秒数
@end
