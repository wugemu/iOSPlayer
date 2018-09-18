//
//  AliyunAnswerLogView.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/19.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunAnswerLogView.h"

//
//  AliyunPlayMessageShowView.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/25.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

//#import "AliyunPlayMessageShowView.h"
#import "UIView+Layout.h"
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface AliyunAnswerLogView()

@property (nonatomic, strong)UIView* contentView;
@property (nonatomic, strong)UIButton * leftButton;
@property (nonatomic, strong)UIButton * hiddenButton;
@end
@implementation AliyunAnswerLogView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        //        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.borderColor = [UIColor redColor].CGColor;
        _contentView.layer.borderWidth = 1;
        _contentView.layer.cornerRadius = 10;
        
    }
    return _contentView;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.textColor = [UIColor redColor];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont systemFontOfSize:12.0f];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _textView.layer.cornerRadius = 5;
        _textView.layer.masksToBounds = YES;
        
    }
    return _textView;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_leftButton setTitle:NSLocalizedString(@"CLEAR", nil) forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(clearButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)hiddenButton{
    if (!_hiddenButton) {
        _hiddenButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_hiddenButton setTitle:NSLocalizedString(@"LOG_OK", nil) forState:UIControlStateNormal];
        [_hiddenButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_hiddenButton addTarget:self action:@selector(hiddenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hiddenButton;
}

- (void)clearButtonClicked:(UIButton *)sender{
    self.textView.text = @"";
}

- (void)hiddenButtonClicked:(UIButton *)sender{
    self.hidden = YES;
}

- (void)layoutSubviews{
    
    self.contentView.frame = CGRectMake(0, 0, 280, SCREEN_HEIGHT-130);
    self.contentView.center = self.center;
    
    self.textView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height-50);
    self.leftButton.frame = CGRectMake(10, self.textView.bottom+10, self.contentView.width/2-20, 30);
    self.hiddenButton.frame = CGRectMake(self.contentView.width/2+10, self.textView.bottom+10, self.contentView.width/2.0-20, 30);
    
    //    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.textView];
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.hiddenButton];
    [self addSubview:self.contentView];
}

- (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

- (void)addTextString:(NSString *)text{
    self.textView.text = [self.textView.text stringByAppendingString: [NSString stringWithFormat:@"\n%@ %@",[self getCurrentTimes],text]];
}

@end

