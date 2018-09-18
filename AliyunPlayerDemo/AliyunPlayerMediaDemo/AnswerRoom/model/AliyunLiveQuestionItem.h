
#import <Foundation/Foundation.h>

@interface AliyunLiveQuestionItem : NSObject

@property (nonatomic, copy) NSString *answerId; //答案ID
@property (nonatomic, copy) NSString *answerDesc; //答案描述
@property (nonatomic, assign) BOOL isCorrect; //是否正确答案
@property (nonatomic, assign) int userNumber; //选择人数
@property (nonatomic, assign) BOOL bChoosed; //是否选择了

-(void) parseQuestionData:(NSDictionary*)data;

@end
