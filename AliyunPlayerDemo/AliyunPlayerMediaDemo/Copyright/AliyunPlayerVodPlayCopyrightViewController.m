//
//  AliyunPlayerVodPlayCopyrightViewController.m
//  AliyunPlayerDemo
//
//  Created by 王凯 on 2017/9/26.
//  Copyright © 2017年 shiping chen. All rights reserved.
//

#import "AliyunPlayerVodPlayCopyrightViewController.h"

@interface AliyunPlayerVodPlayCopyrightViewController ()
@property(nonatomic, strong)UITextView *textView;

@end

@implementation AliyunPlayerVodPlayCopyrightViewController

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.textColor = [UIColor redColor];
        _textView.backgroundColor = [UIColor whiteColor];
        
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
        _textView.layer.cornerRadius = 5;
        _textView.layer.masksToBounds = YES;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;// 字体的行间距
        
        NSString *cr = NSLocalizedString(@"copyright_information", nil);
        NSString *crl = NSLocalizedString(@"copyright_license", nil);
        
        NSString *str = [NSString stringWithFormat:@"%@\n%@\n",cr,crl];
        //@"版权信息\n阿里云 copyrightⒸ2017,阿里巴巴集团\n";
        
        NSMutableAttributedString *maString = [[NSMutableAttributedString alloc] initWithString:str];
        [maString addAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] ,
                                   NSFontAttributeName : [UIFont boldSystemFontOfSize:25.0f],
                                   NSParagraphStyleAttributeName:paragraphStyle,
                                   } range:NSMakeRange(0, cr.length)];
        [maString addAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] ,
                                   NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0f],
                                   NSParagraphStyleAttributeName:paragraphStyle,
                                   } range:NSMakeRange(cr.length+1, crl.length)];
        
        NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"license" ofType:@"txt"];
        NSString *txtStr = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:txtStr];
        [maString appendAttributedString:as];
        
        _textView.attributedText = [maString copy];
    }
    return _textView;
}

#pragma mark - naviBar
- (void)InitNaviBar{
    NSString *backString = NSLocalizedString(@"Back",nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backString style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonItemCliceked:)];
}

- (void)returnButtonItemCliceked:(UIBarButtonItem*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self InitNaviBar];
    self.view.backgroundColor = [UIColor whiteColor];
    self.textView.frame = self.view.bounds;
    [self.view addSubview:self.textView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
