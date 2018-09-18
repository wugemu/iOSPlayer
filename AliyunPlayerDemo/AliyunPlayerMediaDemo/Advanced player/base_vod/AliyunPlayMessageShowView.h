//
//  AliyunPlayMessageShowView.h
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/25.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunPlayMessageShowView : UIView
@property (nonatomic, strong)UITextView *textView;
- (void)addTextString:(NSString *)text;
@end
