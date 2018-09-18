
#import "AliyunLiveQuestionItem.h"

@interface AliyunLiveQuestionItem()
@end

@implementation AliyunLiveQuestionItem

-(id)init
{
    self = [super init];
    if (self) {
        _answerId = nil;
        _isCorrect = NO;
        _answerDesc = nil;
        _userNumber = 0;
        _bChoosed = NO;
    }
    return self;
}

-(void) parseQuestionData:(NSDictionary*)data
{
    if (data == nil) {
        return;
    }
    NSString* answerId = [data objectForKey:@"answerId"];
    self.answerId = answerId;
    NSString* answerDesc = [data objectForKey:@"answerDesc"];
    self.answerDesc = answerDesc;

    if ([[data allKeys] containsObject:@"isCorrect"]) {
        NSString* isCorrect = [data objectForKey:@"isCorrect"];
        self.isCorrect = [isCorrect boolValue];
    }
    
    if ([[data allKeys] containsObject:@"userNumber"]) {
        NSString* userNumber = [data objectForKey:@"userNumber"];
        self.userNumber = [userNumber intValue];
    }
}

@end
