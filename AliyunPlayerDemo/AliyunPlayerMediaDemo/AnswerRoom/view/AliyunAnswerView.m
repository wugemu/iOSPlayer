//
//  AliyunAnswerView.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/16.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunAnswerView.h"
#import "AliyunAnswerCell.h"
#import "UIView+Layout.h"
#import "AliyunLiveQuestionManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AliyunAnswerHeader.h"
#import "CATCurveProgressView.h"

typedef NS_ENUM(NSInteger,AnswerState){
    AnswerStateQuestion = 0,
    AnswerStateTap,
    AnswerStateRight,
    AnswerStateWrong,
    AnswerStateResult
};

@interface AliyunAnswerView()<UITableViewDelegate,UITableViewDataSource>
{
    AliyunLiveQuestion* mLiveQuestionModel;
    BOOL    mIsAnswering;
}

//@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) UILabel *subjectLabel;
@property (nonatomic,assign) float totalHeight;
@property (nonatomic, assign) int answerStatus;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, copy) NSString * statusMessage;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer1;

@property (nonatomic, strong) CATCurveProgressView *progressView;
@property (nonatomic, strong) UIImageView *timeImageView;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *topImageView;

@end
@implementation AliyunAnswerView


- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
//        _contentView.layer.borderWidth = 1;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 10;
    }
    return _contentView;
}

-(UIImageView *)topImageView{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top"]];
//        _topImageView.hidden = YES;
        _topImageView.layer.masksToBounds = YES;
        //        _timeImageView.layer.cornerRadius = 35;
        //        _timeImageView.layer.borderWidth = 5;
        //        _timeImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    }
    return _topImageView;
}

- (UILabel *)timeLabel{
    if(!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text  = @"";
        _timeLabel.font = [UIFont systemFontOfSize:15.0f];
        _timeLabel.textColor = [UIColor redColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.layer.cornerRadius = 25;
//        _timeLabel.layer.borderWidth = 5;
//        _timeLabel.layer.borderColor = [UIColor yellowColor].CGColor;
        
    }
    return _timeLabel;
}

-(UIImageView *)timeImageView{
    if (!_timeImageView) {
        _timeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock"]];
        _timeImageView.hidden = YES;
        _timeImageView.layer.masksToBounds = YES;
//        _timeImageView.layer.cornerRadius = 35;
//        _timeImageView.layer.borderWidth = 5;
//        _timeImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    }
    return _timeImageView;
}

- (CATCurveProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CATCurveProgressView alloc] init];
        _progressView.curveBgColor = [UIColor whiteColor];
        _progressView.progressColor = [UIColor colorWithRed:244.0/255.0 green:197.0/255.0 blue:37.0/255.0 alpha:1];//[UIColor yellowColor];
        _progressView.progressLineWidth = 5;
        
        _progressView.startAngle = -90;
        _progressView.endAngle = 270;
        
        _progressView.layer.masksToBounds = YES;
        _progressView.layer.cornerRadius = 35;
        
    }
    return _progressView;
}


-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
        
    }
    return  _tableView;
}

//- (UILabel *)statusLabel{
//    if(!_statusLabel){
//        _statusLabel = [[UILabel alloc] init];
//        _statusLabel.text  = @"";
//        _statusLabel.font = [UIFont systemFontOfSize:24.0f];
//        _statusLabel.textColor = [UIColor blackColor];
//        _statusLabel.textAlignment = NSTextAlignmentCenter;
//
//
//    }
//    return _statusLabel;
//}
- (UILabel *)subjectLabel{
    if(!_subjectLabel){
        _subjectLabel = [[UILabel alloc] init];
        _subjectLabel.text  = @"";
        _subjectLabel.font = [UIFont systemFontOfSize:18];
        _subjectLabel.textColor = [UIColor blackColor];
        _subjectLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _subjectLabel;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.statusLabel.frame = CGRectMake(0, 15, frame.size.width, 30);
//        [self addSubview:self.statusLabel];
        
        self.contentView.frame = CGRectMake(0, 35, frame.size.width, frame.size.height);
        [self addSubview:self.contentView];
        
        self.topImageView.frame = CGRectMake((frame.size.width-105)/2, 5, 105, 30);
        [self addSubview:self.topImageView];
        
        
        self.timeLabel.frame = CGRectMake(frame.size.width/2-30, 5, 60, 60);
        [self addSubview:self.timeLabel];
        
        self.timeImageView.frame = CGRectMake(frame.size.width/2-20, 15, 40, 40);
        [self addSubview:self.timeImageView];
        
        self.progressView.frame = CGRectMake(frame.size.width/2-35, 0, 70, 70);
        [self addSubview: self.progressView];
        
        self.subjectLabel.frame = CGRectMake(15, self.progressView.bottom, frame.size.width-30, 50);
        [self addSubview:self.subjectLabel];
        
        self.tableView.frame = CGRectMake(15, self.subjectLabel.bottom+10, frame.size.width-30, 53*3);
        [self addSubview:self.tableView];
        
        mIsAnswering = NO;
    }
    return self;
}

-(void)popAnswer:(AliyunLiveQuestion*)liveQuestion
{
    self.topImageView.frame = CGRectMake((self.width-105)/2, 5, 105, 30);
    self.timeLabel.frame = CGRectMake(self.width/2-30, 5, 60, 60);
    self.timeImageView.frame = CGRectMake(self.width/2-20, 15, 40, 40);
    self.progressView.frame = CGRectMake(self.width/2-35, 0, 70, 70);
    
    NSLog(@"popAnswer");
    if (liveQuestion==nil || liveQuestion.options.count<1) {
        NSLog(@"liveQuestion is nil");
        if (self.delegate && [self.delegate respondsToSelector:@selector(popQuestionEnd:)]) {
            [self.delegate popQuestionEnd:YES];
        }
        return;
    }
    
    mLiveQuestionModel = liveQuestion;
//    self.statusLabel.frame = CGRectMake(0, 15, self.width, 30);
    
    //计算题目高度
    NSString *str = liveQuestion.questionTitle;
    self.subjectLabel.text = str;
    self.subjectLabel.numberOfLines = 999;
    CGSize size = [str boundingRectWithSize:CGSizeMake(self.width-30, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18.0f ]} context:nil].size;
    self.subjectLabel.frame = CGRectMake(15, self.progressView.bottom+10, self.width-30, size.height+10);
    self.totalHeight = self.subjectLabel.bottom;
    
    //选项
    self.tableView.frame = CGRectMake(15, self.subjectLabel.bottom+10, self.width-30, 53*liveQuestion.options.count);
    self.totalHeight += 53*liveQuestion.options.count+10;
    
    //考虑高度问题,界面越界问题
    if (self.height+10<self.totalHeight) {
        self.height = self.totalHeight;
    }
    
    self.contentView.frame = CGRectMake(0, 35, self.width, self.height);
    
    mIsAnswering = NO;
    __block int count = 5;//(int)[AliyunLiveQuestionManager shareManager].mAnswerShowTime;
    NSLog(@"answer showTime -- %d",count);
    if(count<=3) {
        count = 3;
    }

    //更新答题状态
    dispatch_async(dispatch_get_main_queue(), ^{
        //更新cell
        [self tableViewReloadData:NO];
        
        if([[AliyunLiveQuestionManager shareManager] isOut]) {
            
            [self playAudio:AnswerStateResult isCircle:NO];
            
//            self.statusLabel.text = @"观战";
//            self.statusLabel.textColor = [UIColor orangeColor];
             NSLog(@"progressView---5-%f",self.progressView.progress);
            self.timeLabel.backgroundColor = [UIColor grayColor];
            self.timeLabel.textColor = [UIColor whiteColor];
            self.timeLabel.text = @"观战";
            self.timeImageView.hidden = YES;
//            self.progressView.progress = 1.0f;
            [self.progressView setProgress:1.0f animated:NO];
            NSLog(@"progressView---55-%f",self.progressView.progress);
            
        }
        else if([[AliyunLiveQuestionManager shareManager] isChooseCorrect]) {
             [self playAudio:AnswerStateRight isCircle:NO];
//            self.statusLabel.text = @"正确";
//            self.statusLabel.textColor = [UIColor yellowColor];
            
            self.timeLabel.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:197.0/255.0 blue:37.0/255.0 alpha:1];//[UIColor yellowColor];
            self.timeLabel.textColor = [UIColor whiteColor];
            self.timeLabel.text = @"正确";
            self.timeImageView.hidden = YES;
//            self.progressView.progress = 1.0f;
            [self.progressView setProgress:1.0f animated:NO];
        }
        else {
             [self playAudio:AnswerStateWrong isCircle:NO];
//            self.statusLabel.text = @"答错了";
//            self.statusLabel.textColor = [UIColor redColor];
            
            
            self.timeLabel.backgroundColor = [UIColor redColor];
            self.timeLabel.textColor = [UIColor whiteColor];
            self.timeLabel.text = @"错误";
            self.timeImageView.hidden = YES;
//            self.progressView.progress = 1.0f;
            [self.progressView setProgress:1.0f animated:NO];
            [[AliyunLiveQuestionManager shareManager] setOuted:YES];
        }
    });

    
    //倒计时
    [self stopTimer];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if (count <=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"count--dispatch_get_main_queue -- %d",count);
                //倒计时结束，通知隐藏窗口
                if (self.delegate && [self.delegate respondsToSelector:@selector(popQuestionEnd:)]) {
                    [self.delegate popQuestionEnd:YES];
                }
                self.progressView.progress = 0;
            });
            NSLog(@"count--dispatch_get_main_queue1111 -- %d",count);
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
        count  = count - 1;
        NSLog(@"count -- %d",count);
    });
    dispatch_resume(self.timer);
}

-(void)popQuestion:(AliyunLiveQuestion*)liveQuestion
{
    self.topImageView.frame = CGRectMake((self.width-105)/2, 5, 105, 30);
    self.timeLabel.frame = CGRectMake(self.width/2-30, 5, 60, 60);
    self.timeImageView.frame = CGRectMake(self.width/2-20, 15, 40, 40);
    self.progressView.frame = CGRectMake(self.width/2-35, 0, 70, 70);
    NSLog(@"popQuestion");
    
    
    if([[AliyunLiveQuestionManager shareManager] isOut]) {
        //        self.statusLabel.text = @"观战";
        //        self.statusLabel.textColor = [UIColor orangeColor];
        NSLog(@"progressView---6-%f",self.progressView.progress);
        self.timeLabel.backgroundColor = [UIColor grayColor];
        self.timeLabel.text = @"观战";
        self.timeImageView.hidden = YES;
        self.progressView.progress = 1.0f;
//        [self.progressView setProgress:1.0f animated:NO];
        NSLog(@"progressView---66-%f",self.progressView.progress);
    }else{
        self.progressView.progress = 0;
    }
    
    
    
    [self playAudio:AnswerStateQuestion isCircle:YES];
    
    if (liveQuestion==nil || liveQuestion.options.count<1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popQuestionEnd:)]) {
            [self.delegate popQuestionEnd:NO];
        }
        return;
    }
    
    mLiveQuestionModel = liveQuestion;
//    self.statusLabel.frame = CGRectMake(0, 15, self.width, 30);
    
    //计算题目高度
    NSString *str = liveQuestion.questionTitle;
    self.subjectLabel.text = str;
    self.subjectLabel.numberOfLines = 999;
    CGSize size = [str boundingRectWithSize:CGSizeMake(self.width-30, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18.0f ]} context:nil].size;
    self.subjectLabel.frame = CGRectMake(15, self.progressView.bottom+10, self.width-30, size.height+10);
    self.totalHeight = self.subjectLabel.bottom;
    
    //选项
    self.tableView.frame = CGRectMake(15, self.subjectLabel.bottom+10, self.width-30, 53*liveQuestion.options.count);
    self.totalHeight += 53*liveQuestion.options.count+10;
    
    //考虑高度问题,界面越界问题
    if (self.height+10<self.totalHeight) {
        self.height = self.totalHeight;
    }
    
    self.contentView.frame = CGRectMake(0, 35, self.width, self.height);
    
//    self.statusLabel.textColor = [UIColor blackColor];
    __block int count = 11;//liveQuestion.remainSeconds;
    if (count>10)
        count = 10;
    else if(count<=0)
        count = 5;
    NSLog(@"remainSeconds -- %d",count);
//    self.statusLabel.text = [NSString stringWithFormat:@"%d",count];
    NSLog(@"remainSeconds -- | %d |-- |%d|",count,liveQuestion.remainSeconds);
    
    //更新cell
    mIsAnswering = YES;
    BOOL bCanSelect = YES;
    if ([[AliyunLiveQuestionManager shareManager] isOut]) {
        bCanSelect = NO;
    }
    [self tableViewReloadData:bCanSelect];
    
    
    
    //倒计时
    [self stopTimer];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if (count <=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"count--dispatch_get_main_queue");
                if(![[AliyunLiveQuestionManager shareManager] isOut]) {
//                    self.statusLabel.text = @"0";
                     NSLog(@"progressView---7-%f",self.progressView.progress);
                    self.timeLabel.textColor = [UIColor whiteColor];
                    self.timeLabel.backgroundColor = [UIColor grayColor];
                    self.timeLabel.text = @"观战";
                    self.timeImageView.hidden = YES;
//                    self.progressView.progress = 1.0f;
                     NSLog(@"progressView---77-%f",self.progressView.progress);
                }else{
                    
                }
                //倒计时结束，通知隐藏窗口
                if (self.delegate && [self.delegate respondsToSelector:@selector(popQuestionEnd:)]) {
                    [self.delegate popQuestionEnd:NO];
                }
                
                //播放结束
                [self playStop];
                NSLog(@"playStop----");
                
            });
            dispatch_cancel(self.timer);
            self.timer = nil;
        }else{
            
            if(![[AliyunLiveQuestionManager shareManager] isOut]) {
                if (count>4) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"progressView-1-%f",self.progressView.progress );
                        self.timeLabel.backgroundColor = [UIColor whiteColor];
                        self.timeLabel.text = @"";
                        self.timeImageView.hidden = NO;
//                        self.progressView.progress = (11-count*1.0)/11.0f;
                        [self.progressView setProgress:(11-count*1.0)/11.0f animated:YES];
                        NSLog(@"progressView-11-%f",self.progressView.progress );
                    });
                    
                    //                        [self.progressView setProgress:count*1.0/11.0f];
                }else if (count<=4 && count>1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"progressView-2-%f",self.progressView.progress );
                        self.timeLabel.textColor = [UIColor redColor];
                        self.timeLabel.backgroundColor = [UIColor whiteColor];
                        self.timeLabel.text = [NSString stringWithFormat:@"%d",count];;
                        self.timeImageView.hidden = YES;
//                        self.progressView.progress = (11-count*1.0)/11.0f;
                        [self.progressView setProgress:(11-count*1.0)/11.0f animated:YES];
                        NSLog(@"progressView-22-%f",self.progressView.progress );
                    });
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"progressView-3-%f",self.progressView.progress );
                        self.timeLabel.backgroundColor = [UIColor whiteColor];
                        self.timeLabel.text = @"";
                        self.timeImageView.hidden = NO;
//                        self.progressView.progress = (11-count*1.0)/11.0f;
                        [self.progressView setProgress:(11-count*1.0)/11.0f animated:YES];
                        NSLog(@"progressView-33-%f",self.progressView.progress );
                    });
                   
                }
                
                
            }
            
            
        }
        
        count  = count - 1;
        NSLog(@"count -- %d",count);
        
        
    });
    dispatch_resume(self.timer);
}

-(void)stopTimer{
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

#pragma mark - tableDelegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (mLiveQuestionModel) {
        return mLiveQuestionModel.options.count;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"democell";
    AliyunAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AliyunAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    //选中的颜色
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.width, cell.height)];
    cell.selectedBackgroundView.layer.masksToBounds = YES;
    cell.selectedBackgroundView.layer.cornerRadius = 20;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:197.0/255.0 blue:37.0/255.0 alpha:1];//[UIColor yellowColor];//[UIColor colorWithRed:60/255.0 green:150/255.0 blue:180/255.0 alpha:1];
    
    //正在答题 244 195 37
    if (mIsAnswering && mLiveQuestionModel) {
        AliyunLiveQuestionItem* item = mLiveQuestionModel.options[indexPath.section];
        [cell showQuestionStatus:item];
        NSLog(@"cell -- showQuestionStatus");
    }
    else if(mLiveQuestionModel) {
        AliyunLiveQuestionItem* item = mLiveQuestionModel.options[indexPath.section];
        [cell showAnswerStatus:item totalUserNumber:mLiveQuestionModel.totalUserNumber];
        NSLog(@"cell -- showAnswerStatus:item totalUserNumber:");
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [self playAudio1:AnswerStateTap isCircle:NO];
    
    tableView.allowsSelection = NO;
    if (mLiveQuestionModel) {
        AliyunLiveQuestionItem *item = mLiveQuestionModel.options[indexPath.section];
        if(item) {
            item.bChoosed = YES;
            [[AliyunLiveQuestionManager shareManager] AnswerQuestion:item.answerId];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 4)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 4;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 4)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 4;
}

- (void)tableViewReloadData:(BOOL)allowsSelection{
    if (self.tableView) {
        [self.tableView reloadData];
        self.tableView.allowsSelection = allowsSelection;
    }
}

-(void)clear
{
    [self stopTimer];
}


- (void)playAudio:(AnswerState)state isCircle:(BOOL)isCircle{
    NSString *str = @"";
    switch (state) {
        case AnswerStateQuestion:
            str = @"question";
            break;
        case AnswerStateTap:
            str = @"tap";
            break;
        case AnswerStateRight:
            str = @"right";
            break;
        case AnswerStateWrong:
            str = @"wrong";
            break;
        case AnswerStateResult:
            str = @"results";
            break;
            
        default:
            break;
    }
    
    if (str==nil||str.length <1) {
        return;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:str ofType:@"m4a"];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:path] error:&error];
    if (error) {
        NSLog(@"error-%@",error.localizedDescription);
    }
    if (isCircle) {
        self.audioPlayer.numberOfLoops = 10;
    }else{
        self.audioPlayer.numberOfLoops = 0;
    }
    
    self.audioPlayer.volume = 0.25;
    [self.audioPlayer play];
}

- (void)playStop{
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

- (void)playAudio1:(AnswerState)state isCircle:(BOOL)isCircle{
    NSString *str = @"";
    switch (state) {
        case AnswerStateQuestion:
            str = @"question";
            break;
        case AnswerStateTap:
            str = @"tap";
            break;
        case AnswerStateRight:
            str = @"right";
            break;
        case AnswerStateWrong:
            str = @"wrong";
            break;
        case AnswerStateResult:
            str = @"results";
            break;
            
        default:
            break;
    }
    
    if (str==nil||str.length <1) {
        return;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:str ofType:@"m4a"];
    
    NSError *error;
    self.audioPlayer1 = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:path] error:&error];
    if (error) {
        NSLog(@"error-%@",error.localizedDescription);
    }
    if (isCircle) {
        self.audioPlayer1.numberOfLoops = 10;
    }else{
        self.audioPlayer1.numberOfLoops = 0;
    }
    
    self.audioPlayer1.volume = 0.25;
    [self.audioPlayer1 play];
}

- (void)playStop1{
    if (self.audioPlayer1) {
        [self.audioPlayer1 stop];
    }
}



-(void)dealloc{
    [self playStop];
    [self playStop1];
}

@end
