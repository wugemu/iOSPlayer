//
//  AliyunAnswerCell.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/17.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunAnswerCell.h"
#import "UIView+Layout.h"
#import "AliyunLiveQuestionManager.h"

@interface AliyunAnswerCell()
@property(nonatomic, strong) UILabel *selectLabel;
@property(nonatomic, strong) UILabel *numLabel;
@property(nonatomic, strong) UILabel *progressLabel;

@end

@implementation AliyunAnswerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f].CGColor;
        self.layer.cornerRadius = 22.5;
        self.contentView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
        
//        self.progressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.progressLabel];
        
//        self.numLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.numLabel];
        
//        self.selectLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.selectLabel];
        
        
    }
    return self;
}

- (UILabel *)selectLabel{
    if(!_selectLabel){
        _selectLabel = [[UILabel alloc] init];
        _selectLabel.text  = @"";
        _selectLabel.font = [UIFont systemFontOfSize:21.0f];
        _selectLabel.textColor = [UIColor blackColor];
        _selectLabel.textAlignment = NSTextAlignmentLeft;
        _selectLabel.layer.masksToBounds = YES;
        _selectLabel.layer.cornerRadius = 20;
        
    }
    return _selectLabel;
}

- (UILabel *)progressLabel{
    if(!_progressLabel){
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text  = @"";
        _progressLabel.font = [UIFont systemFontOfSize:15.0f];
        _progressLabel.textColor = [UIColor blackColor];
        _progressLabel.textAlignment = NSTextAlignmentLeft;
        _progressLabel.layer.masksToBounds = YES;
        _progressLabel.layer.cornerRadius = 20;
        
    }
    return _progressLabel;
}

- (UILabel *)numLabel{
    if(!_numLabel){
        _numLabel = [[UILabel alloc] init];
        _numLabel.text  = @"";
        _numLabel.font = [UIFont systemFontOfSize:15.0f];
        _numLabel.textColor = [UIColor blackColor];
        _numLabel.textAlignment = NSTextAlignmentRight;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 20;
    }
    return _numLabel;
}

-(void)layoutSubviews{
//    self.progressLabel.frame = CGRectMake(0, 0, self.width, self.height);
//    self.numLabel.frame = CGRectMake(0, 0, self.width-15, self.height);
//    self.selectLabel.frame = CGRectMake(0, 0, self.width, self.height);
}


//dati
-(void)showQuestionStatus:(AliyunLiveQuestionItem*)item
{
    self.progressLabel.frame = CGRectMake(0, 0, self.width, self.height);
    self.numLabel.frame = CGRectMake(0, 0, self.width-15, self.height);
    self.selectLabel.frame = CGRectMake(0, 0, self.width, self.height);

    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.numLabel.text = @"";
    self.selectLabel.text = [NSString stringWithFormat:@"   %@.%@",item.answerId,item.answerDesc];
    
    [self sizeToFit];
}


//jieguo
-(void)showAnswerStatus:(AliyunLiveQuestionItem*)item totalUserNumber:(int)totalUserNumber
{
    self.progressLabel.frame = CGRectMake(0, 0, self.width, self.height);
    self.numLabel.frame = CGRectMake(0, 0, self.width-15, self.height);
    self.selectLabel.frame = CGRectMake(0, 0, self.width, self.height);

    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.numLabel.text = [NSString stringWithFormat:@"%d",item.userNumber];

    if([[AliyunLiveQuestionManager shareManager] isChooseCorrect]){
        if (item.isCorrect) {
            self.progressLabel.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:197.0/255.0 blue:37.0/255.0 alpha:1];//[UIColor yellowColor];//[UIColor colorWithRed:60/255.0 green:150/255.0 blue:180/255.0 alpha:1];
        }
        else {
            self.progressLabel.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1];//[UIColor grayColor];
        }
    }
    else {
        if (item.isCorrect) {
            self.progressLabel.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:197.0/255.0 blue:37.0/255.0 alpha:1];//[UIColor yellowColor];//[UIColor colorWithRed:60/255.0 green:150/255.0 blue:180/255.0 alpha:1];
            
            NSLog(@"item.isCorrect11111");
        }
        else{
            self.progressLabel.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1];//[UIColor grayColor];
            NSLog(@"item.isCorrect11111333");
        }
    }
    
    CGRect frame = self.progressLabel.frame;
    float prg = 0;
    if (totalUserNumber >0){
        if(item.userNumber*1.0/totalUserNumber*1.0 >=1){
            prg = 1;
        }else{
            prg = item.userNumber*1.0/totalUserNumber*1.0;
        }
        
    }else{
        prg = 1;
    }
    
    if (prg==0) {
        prg = 1;
    }
    
    NSLog(@"item.isCorrect11111---%f---%d---%d",prg,item.userNumber,totalUserNumber);
    
//    prg = 1;
    frame.size.width = self.frame.size.width*prg;
    self.progressLabel.frame = frame;
    
    self.selectLabel.text = [NSString stringWithFormat:@"   %@.%@",item.answerId,item.answerDesc];
    [self sizeToFit];
}

@end
