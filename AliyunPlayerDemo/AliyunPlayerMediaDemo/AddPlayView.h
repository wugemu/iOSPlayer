//
//  LoginView.h
//  DemoAlivcLive
//
//  Created by LYZ on 16/8/22.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol addPlayDelegate <NSObject>

-(void) onClickAddPlay:(int)clickType vid:(NSString*)vid playAuth:(NSString*)playAuth;

-(void) onClickAddPlay:(int)clickType vid:(NSString *)vid accessKeyId:(NSString*)accessKeyId accessKeySecret:(NSString*)accessKeySecret securityToken:(NSString *)securityToken;

@end

@interface AddPlayView: UIView
@property (nonatomic, strong)UILabel * fLabel;
@property (nonatomic, strong)UITextField *fTextField;

@property (nonatomic, strong)UILabel *tLabel;
@property (nonatomic, strong)UITextField *tTextField;

@property (nonatomic, strong)UILabel *thLabel;
@property (nonatomic, strong)UITextField *thTextField;

@property (nonatomic, strong)UILabel *fourthLabel;
@property (nonatomic, strong)UITextView *fourthTextView;

@property (nonatomic, strong)UIButton *getQulalitysButton;

@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, strong)UIButton *addButton;

@property (nonatomic, strong) id<addPlayDelegate> delegate;
-(void)setAddPlayType:(int)Type;
@end
