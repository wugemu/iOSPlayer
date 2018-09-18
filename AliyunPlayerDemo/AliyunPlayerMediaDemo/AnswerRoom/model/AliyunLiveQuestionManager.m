
#import "AliyunLiveQuestionManager.h"
#import "AliyunReuqestManager.h"
#import "AliyunLiveQuestion.h"
#import <UIKit/UIKit.h>

@interface AliyunLiveQuestionManager()
{
    BOOL mOuted;
}
@end

@implementation AliyunLiveQuestionManager

-(id)init
{
    self = [super init];
    if (self) {
        _mLogString = [[NSMutableString alloc] init];
        _mQuestions = [[NSMutableDictionary alloc] init];
        _mCurrentQuestionId = nil;
        _mLiveId = nil;
        _mCurrentQuestion = nil;
        mOuted = NO;
        _mCurrentAnswerId = nil;
        _delegate = nil;
        _mAnswerShowTime = 5;
    }
    return self;
}

-(BOOL)isOut
{
    return mOuted;
}

+(AliyunLiveQuestionManager*) shareManager
{
    static AliyunLiveQuestionManager* manger;
    static dispatch_once_t p;
    dispatch_once(&p, ^{
        manger = [[self alloc] init];
    });
    return manger;
}

-(void)appendLogString:(NSString*)strLog
{
    NSString* logStr = [NSString stringWithFormat:@"%@/r/n",strLog];
    [_mLogString appendString:logStr];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addLogText:)]) {
        [self.delegate addLogText:strLog];
    }
}

/*
 {
 "questionId": "001”,
 "type": "startAnswer"
 }  这个是开始答题
 
 {
 "questionId": "001”,
 "type": "showResult",
 "showTime": "5"
 }  这个是显示答题结果
 
 */
-(void) parseSEIData:(NSString*)seiData
{
    if(seiData == nil)
        return;
    
    @try{
        [self appendLogString:seiData];
        NSData *stringData = [seiData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:stringData options:0 error:&error];
        if(error || json==nil){
            if (error) {
                NSLog(@"seiDataJson error---%@",error.localizedDescription);
                [self appendLogString:error.localizedDescription];
            }
            return;
        }
        
        NSString *type =  [json objectForKey:@"type"];
        NSString *questionId = [json objectForKey:@"questionId"];
        if(type == nil || questionId == nil){
            NSLog(@"type - questionId,is nil");
            [self appendLogString:@"type - questionId,is nil"];
            return;
        }
        
        self.mCurrentQuestionId = questionId;
        
        //开始答题
        if ([type isEqualToString:@"startAnswer"]) {
            [self setQuestionSEIData:questionId];
        }
        else if ([type isEqualToString:@"showResult"]) {
            NSString* showTime= [json objectForKey:@"showTime"];
            if ([showTime intValue] <= 2) {
                showTime = @"2";
            }
            [self setAnswerSEIData:questionId showTime:showTime];
        }
    } @catch (NSException *exception) {
        NSLog(@"exception is %@",exception.reason);
        [self appendLogString:exception.reason];
    }
}

//题目sei信号
-(void) setQuestionSEIData:(NSString*)questionId
{
    if (_mLiveId == nil) {
        NSLog(@"you must set liveid first");
        [self appendLogString:@"you must set liveid first"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@/app/getQuestion",ADDR_APPSERVER];
        NSDictionary *params = @{@"liveId" : _mLiveId,
                                 @"questionId" : questionId
                                 };
        
        [AliyunReuqestManager doPostWithUrl:urlString params:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error || data==nil) {
                if (error) {
                    NSLog(@"setQuestionSEIData error---%@",error.localizedDescription);
                    [self appendLogString:error.localizedDescription];
                }
                return ;
            }
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dict == nil || dict.allKeys.count<1) {
                NSLog(@"data is %@",data);
                [self appendLogString:@"setQuestionSEIData get data error"];
                return ;
            }
            
            [self appendLogString:[NSString stringWithFormat:@"/app/getQuestion--ditc--%@",dict]];
            NSLog(@"/app/getQuestion--ditc -- %@",dict);
            
            NSDictionary* dictData = [dict objectForKey:@"data"];
            if (dictData) {
                AliyunLiveQuestion* question = [[AliyunLiveQuestion alloc] init];
                [question parseQuestionData:dictData];
                
                [self.mQuestions setObject:question forKey:questionId];
                self.mCurrentQuestion = question;
                self.mCurrentAnswerId = nil;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(popQuestion:)]) {
                    [self.delegate popQuestion:question];
                }
            }
        }];
    });
}

//答题
-(void)AnswerQuestion:(NSString*)answerId
{
    if (_mLiveId == nil || _mCurrentQuestionId == nil) {
        NSLog(@"you must set liveid first");
        [self appendLogString:@"you must set liveid first"];
        return;
    }
    
    _mCurrentAnswerId = answerId;
    NSLog(@"selectCode -- %@",answerId);
    [self appendLogString:[NSString stringWithFormat:@"selectCode -- %@",answerId]];
   
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@/app/answer",ADDR_APPSERVER];
        NSDictionary *params = @{@"liveId": _mLiveId,
                                 @"questionId" : _mCurrentQuestionId,
                                 @"answerId" : answerId,
                                 @"userId" : _userId,
                                 };
        
        [AliyunReuqestManager doPostWithUrl:urlString params:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error||data==nil) {
                if (error) {
                    NSLog(@"setQuestionSEIData error---%@",error.localizedDescription);
                    [self appendLogString:error.localizedDescription];
                }
                return;
            }
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dict==nil||dict.allKeys.count<1) {
                NSLog(@"data is %@",data);
                [self appendLogString:@"setQuestionSEIData get data error"];
                return ;
            }
            
            [self appendLogString:[NSString stringWithFormat:@"/app/answer -- %@",dict]];
            if ([[dict allKeys] containsObject:@"data"]) {
                NSDictionary* dictCorrect = [dict objectForKey:@"data"];
                if(dictCorrect) {
                    if ([[dictCorrect allKeys] containsObject:@"isCorrect"]) {
                        BOOL isCorrect = [[dictCorrect objectForKey:@"isCorrect"] boolValue];
                        [self appendLogString:[NSString stringWithFormat:@"isCorrect -- %d",isCorrect]];
                        if (isCorrect == NO) {
//                            mOuted = YES;
                        }
                    }
                }
            }
            
            if ([[dict allKeys] containsObject:@"result"]) {
                NSDictionary* dictResult = [dict objectForKey:@"result"];
                if(dictResult) {
                    if ([[dictResult allKeys] containsObject:@"code"]) {
                        NSString* code = [dictResult objectForKey:@"code"];
                        if ([code isEqualToString:@"Expired"]){
                            NSLog(@"超时了-----Expired");
                            [self appendLogString:[NSString stringWithFormat:@"超时了-----Expired"]];
                            mOuted = YES;
                        }
                    }
                }
            }
        }];
    });
}

//答题汇总信号
-(void) setAnswerSEIData:(NSString*)questionId showTime:(NSString*)showTime
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@/mgr/getQuestionReport",ADDR_APPSERVER];
        NSDictionary *params = @{@"liveId" : _mLiveId,
                                 @"questionId" : questionId
                                 };
        
        [AliyunReuqestManager doPostWithUrl:urlString params:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error||data==nil) {
                if (error) {
                    NSLog(@"setQuestionSEIData error---%@",error.localizedDescription);
                    [self appendLogString:error.localizedDescription];
                }
                return ;
            }
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dict==nil||dict.allKeys.count<1) {
                [self appendLogString:@"setAnswerSEIData get data error"];
                return ;
            }
            NSLog(@"/mgr/getQuestionReport---dict -- %@",dict);
            
            [self appendLogString:[NSString stringWithFormat:@"/mgr/getQuestionReport-dict--%@",dict]];
            
            NSDictionary* dictData = [dict objectForKey:@"data"];
            if (dictData) {
                if (self.mCurrentQuestion == nil) {
                    self.mCurrentQuestion = [[AliyunLiveQuestion alloc] init];
                }

                self.mAnswerShowTime = [showTime integerValue];
                [self.mCurrentQuestion parseQuestionData:dictData];
                
                for (AliyunLiveQuestionItem* item in self.mCurrentQuestion.options) {
                    if (self.mCurrentAnswerId && [item.answerId isEqualToString:self.mCurrentAnswerId]) {
                        item.bChoosed = YES;
                        break;
                    }
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(popAnswer:)]) {
                    [self.delegate popAnswer:self.mCurrentQuestion];
                }
            }
        }];
    });
}

-(BOOL)isChooseCorrect
{
    if (self.mCurrentQuestion == nil) {
        return NO;
    }
    
    for (AliyunLiveQuestionItem* item in self.mCurrentQuestion.options) {
        if(item.isCorrect && self.mCurrentAnswerId && [self.mCurrentAnswerId isEqualToString:item.answerId]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)setOuted:(BOOL)bOuted
{
    mOuted = bOuted;
}

@end

