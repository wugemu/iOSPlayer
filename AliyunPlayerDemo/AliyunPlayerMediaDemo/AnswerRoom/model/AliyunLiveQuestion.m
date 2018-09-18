
#import "AliyunLiveQuestion.h"
#import "AliyunLiveQuestionItem.h"

@interface AliyunLiveQuestion()

@end

@implementation AliyunLiveQuestion

-(id)init
{
    self = [super init];
    if (self) {
        _questionTitle = nil;
        _questionId = nil;
        _totalUserNumber = 0;
        _options = [[NSMutableArray alloc] init];
        _remainSeconds = 0;
        _liveId = nil;
    }
    return self;
}

-(void) parseQuestionData:(NSDictionary*)data
{
    if (data == nil) {
        return;
    }
    
    [self.options removeAllObjects];
    
    NSString* liveId = [data objectForKey:@"liveId"];
    self.liveId = liveId;
    NSString* questionId = [data objectForKey:@"questionId"];
    self.questionId = questionId;
    NSString* questionTitle = [data objectForKey:@"questionTitle"];
    self.questionTitle = questionTitle;
    
    if ([[data allKeys] containsObject:@"remainSeconds"]) {
        NSString* remainSeconds = [data objectForKey:@"remainSeconds"];
        self.remainSeconds = [remainSeconds intValue];
        if (self.remainSeconds < 0) {
            self.remainSeconds = 0;
        }
    }
    
    if ([[data allKeys] containsObject:@"totalUserNumber"]) {
        NSString* totalUserNumber = [data objectForKey:@"totalUserNumber"];
        self.totalUserNumber = [totalUserNumber intValue];
        if (self.totalUserNumber < 0) {
            self.totalUserNumber = 0;
        }
    }
    
    NSArray* array = [data objectForKey:@"options"];
    for (NSDictionary* option in array) {
        AliyunLiveQuestionItem* item = [[AliyunLiveQuestionItem alloc] init];
        [item parseQuestionData:option];
        [self.options addObject:item];
    }
}

@end

