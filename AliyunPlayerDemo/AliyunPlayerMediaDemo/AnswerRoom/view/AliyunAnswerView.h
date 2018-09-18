//
//  AliyunAnswerView.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunOptionReportModel.h"
#import "AliyunQuestionModel.h"
#import "AliyunQuestionReportModel.h"
#include "AliyunLiveQuestionManager.h"

@class AliyunAnswerView;

@protocol AliyunAnswerViewDelegate <NSObject>

//结束显示窗口
- (void)popQuestionEnd:(BOOL)answeredWindow;

@end

@interface AliyunAnswerView : UIView

@property (nonatomic, weak)id<AliyunAnswerViewDelegate>delegate;

-(void)popQuestion:(AliyunLiveQuestion*)liveQuestion;

-(void)popAnswer:(AliyunLiveQuestion*)liveQuestion;

-(void)clear;

@end
