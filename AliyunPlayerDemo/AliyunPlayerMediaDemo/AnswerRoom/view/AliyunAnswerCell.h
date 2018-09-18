//
//  AliyunAnswerCell.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/17.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunLiveQuestionItem.h"

@interface AliyunAnswerCell : UITableViewCell
-(void)showQuestionStatus:(AliyunLiveQuestionItem*)item;
-(void)showAnswerStatus:(AliyunLiveQuestionItem*)item totalUserNumber:(int)totalUserNumber;

@end
