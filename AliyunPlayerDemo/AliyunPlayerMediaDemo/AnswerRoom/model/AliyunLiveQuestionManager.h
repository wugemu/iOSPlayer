
#import <Foundation/Foundation.h>
#import "AliyunLiveQuestion.h"
#import "AliyunLiveQuestionItem.h"

#define ADDR_APPSERVER @"http://101.132.137.92"

@protocol AliyunLiveQuestionDelegate <NSObject>

//弹出题目
- (void) popQuestion:(AliyunLiveQuestion *)liveQuestion;

//弹出结果
- (void) popAnswer:(AliyunLiveQuestion *)liveQuestion;

//日志
-(void) addLogText:(NSString*)logStr;

@end

@interface AliyunLiveQuestionManager : NSObject

+(AliyunLiveQuestionManager*) shareManager;

@property (nonatomic, weak)id<AliyunLiveQuestionDelegate> delegate;


@property (nonatomic, copy)NSMutableString *mLogString; // 日志数据
@property (nonatomic, copy)NSString *mLiveId; // 直播id
@property (nonatomic, copy)NSString *mCurrentQuestionId; // 当前题目ID
@property (nonatomic, copy)NSString *mCurrentAnswerId; // 当前选择ID
@property (nonatomic, strong)NSMutableDictionary *mQuestions; //题目集合
@property (nonatomic, strong)AliyunLiveQuestion *mCurrentQuestion; //当前题目
@property (nonatomic, assign)NSInteger mAnswerShowTime; // 答案显示时间


@property (nonatomic, copy) NSString *userId;

//解析SEI数据
-(void)parseSEIData:(NSString*)seiData;

//回答题目
-(void)AnswerQuestion:(NSString*)answerId;

-(BOOL)isOut;//是否已经淘汰

-(void)setOuted:(BOOL)bOuted; //设置已经淘汰了

-(BOOL)isChooseCorrect;//是否选择正确

@end
