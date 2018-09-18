//
//  UIAliyunSlider.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2018/1/23.
//  Copyright © 2018年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "UIAliyunSlider.h"

@implementation UIAliyunSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{//返回滑块大小
    rect.origin.x = rect.origin.x - 15.5 ;
    rect.size.width = rect.size.width +20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

@end
