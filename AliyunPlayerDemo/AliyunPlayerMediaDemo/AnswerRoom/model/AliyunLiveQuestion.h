
#import <Foundation/Foundation.h>

@interface AliyunLiveQuestion : NSObject

@property (nonatomic, copy)NSString *liveId; //题目ID
@property (nonatomic, copy)NSString *questionId; //题目ID
@property (nonatomic, copy)NSString *questionTitle; //题干
@property (nonatomic, assign)int totalUserNumber; //答题人数
@property (nonatomic, strong)NSMutableArray *options; //答题分布列表
@property (nonatomic, assign)int remainSeconds; //剩余时间

-(void) parseQuestionData:(NSDictionary*)data;

@end
