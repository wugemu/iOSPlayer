//
//  AliyunResultView.m
//  AliyunPlayerAnswer
//
//  Created by 王凯 on 2018/2/4.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunResultView.h"
#import "UIView+Layout.h"
@interface AliyunResultView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *subjLabel;

@end

@implementation AliyunResultView

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sucessed"]];
        
    }
    return _imageView;
}

- (UILabel *)subjLabel{
    if(!_subjLabel){
        _subjLabel = [[UILabel alloc] init];
        _subjLabel.text  = @"恭喜你，12题全答对了坐等吃鸡吧";
        _subjLabel.font = [UIFont systemFontOfSize:20.0f];
        _subjLabel.textColor = [UIColor redColor];
        _subjLabel.numberOfLines = 999;
    
    }
    return _subjLabel;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        [self addSubview: self.imageView];
//        [self addSubview:self.subjLabel];
    }
    return self;
}

-(void)layoutSubviews{
    
    self.imageView.frame = CGRectMake((self.width-192)/2, 5, 192, 203);
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:20],NSFontAttributeName, nil];
    CGSize size = [self.subjLabel.text boundingRectWithSize:CGSizeMake(192, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
//    self.subjLabel.frame = CGRectMake((self.width-192)/2, self.imageView.bottom+10, 192, size.height+5);
    
    
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
