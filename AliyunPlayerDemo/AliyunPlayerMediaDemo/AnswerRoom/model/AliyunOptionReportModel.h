//
//  AliyunOptionReportModel.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunOptionReportModel.h"

//options
@interface AliyunOptionReportModel : NSObject

@property (nonatomic, copy) NSString *answerId; //答案ID
@property (nonatomic, copy) NSString *answerDesc; //答案描述
@property (nonatomic, assign) BOOL isCorrect; //是否正确答案
@property (nonatomic, assign) int userNumber; //选择人数

/***记录用户选择数据***/
//做判定记录
@property (nonatomic, copy) NSString *liveId;
@property (nonatomic, copy) NSString *questionId; //题目ID

//上一次答案记录
//@property (nonatomic, assign)BOOL beforeIsCorrect;
@end
