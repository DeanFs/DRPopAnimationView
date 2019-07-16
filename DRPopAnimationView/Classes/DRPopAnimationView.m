//
//  DRAlarmSettingNoticeView.m
//  Records
//
//  Created by admin on 2017/12/23.
//  Copyright © 2017年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "DRPopAnimationView.h"
#import <Masonry/Masonry.h>
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRPopAnimationView ()<UIGestureRecognizerDelegate>{
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewBottom;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) UITapGestureRecognizer *tapRemoveSuperViewGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapInterceptGestureRecognizer;

@end

@implementation DRPopAnimationView

- (UITapGestureRecognizer *)tapRemoveSuperViewGestureRecognizer{
    if (!_tapRemoveSuperViewGestureRecognizer){
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        _tapRemoveSuperViewGestureRecognizer = tap ;
    }
    return _tapRemoveSuperViewGestureRecognizer;
}

- (UITapGestureRecognizer *)tapInterceptGestureRecognizer{
    if (!_tapInterceptGestureRecognizer){
        //截获手势
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        tap1.delegate = self;
        tap1.numberOfTapsRequired = 1;
        _tapInterceptGestureRecognizer = tap1 ;
        
    }
    return _tapInterceptGestureRecognizer;
}

- (void)setIsTapBlankClose:(BOOL)isTapBlankClose{
    if (!isTapBlankClose){
        [self removeGestureRecognizer:self.tapRemoveSuperViewGestureRecognizer];
        [self.containerView removeGestureRecognizer:self.tapInterceptGestureRecognizer];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Event Response

- (IBAction)editAction:(UIButton *)sender {
    [self dismissWithButtonIndex:sender.tag];
}
- (IBAction)closeWindow:(UIButton *)sender {
    [self dismissWithButtonIndex:sender.tag];
}
- (void)dismissAction:(UIButton *)sender {
    [self dismissWithButtonIndex:sender.tag];
}

#pragma mark - Public method
+ (instancetype)alertViewWithCancelButtonTitle:(NSString *)cancelButtonTitle
                             otherButtonTitles:(NSArray *)otherButtonTitles {
    DRPopAnimationView *alertView = kDR_LOAD_XIB_NAMED(NSStringFromClass([self class]));
    [alertView setFrame:[UIScreen mainScreen].bounds];
    [alertView addGestureRecognizer:alertView.tapRemoveSuperViewGestureRecognizer];
    [alertView.containerView addGestureRecognizer:alertView.tapInterceptGestureRecognizer];
    NSMutableArray *buttonArray = [NSMutableArray array];
    if (cancelButtonTitle.length) {
        [buttonArray addObject:[alertView buttonWithTitle:cancelButtonTitle isBold:YES]];
    }
    if (otherButtonTitles.count) {
        for (NSString *otherTitle in otherButtonTitles) {
            [buttonArray addObject:[alertView buttonWithTitle:otherTitle isBold:NO]];
        }
    }
    BOOL isVertical = buttonArray.count >= 4;
    NSInteger lineCount = buttonArray.count - 1;
    alertView.stackView.axis = isVertical ? UILayoutConstraintAxisVertical : UILayoutConstraintAxisHorizontal;
    alertView.stackViewHeight.constant = isVertical ? buttonArray.count * 40 + lineCount * 0.5 : 40.0;
    for (UIButton *button in buttonArray) {
        NSInteger index = [buttonArray indexOfObject:button];
        button.tag = index;
        if (index != 0) {
            if (buttonArray.count >= 2 || (index != lineCount)) {
                //分割线
                UIView *lineView = alertView.lineView;
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (isVertical) {
                        make.height.mas_equalTo(0.5);
                    } else {
                        make.width.mas_equalTo(0.5);
                    }
                }];
                [alertView.stackView addArrangedSubview:lineView];
            }
        }
        //按钮
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (isVertical) {
                make.height.mas_equalTo(40.0);
            } else {
                make.width.mas_equalTo((alertView.containerView.jx_width - lineCount * 0.5) / buttonArray.count);
            }
        }];
        [alertView.stackView addArrangedSubview:button];
    }
    return alertView;
}

+ (void)showAlertViewWithCancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                   completion:(DRAlertViewCompletionBlock)completion {
    DRPopAnimationView *alertView = [DRPopAnimationView alertViewWithCancelButtonTitle:cancelButtonTitle
                                                                     otherButtonTitles:otherButtonTitles];
    [alertView showWithCompletion:completion];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)showWithCompletion:(DRAlertViewCompletionBlock)completion {
    self.completionBlock = completion;
    [kDRWindow addSubview:self];
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.layer.opacity = 1.0;
    }];
    [self.containerView popToShow];
}

- (void)showWithView:(UIView *)view completion:(DRAlertViewCompletionBlock)completion {
    self.completionBlock = completion;
    [view addSubview:self];
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.layer.opacity = 1.0;
    }];
    [self.containerView popToShow];
}

- (void)dismissWithButtonIndex:(NSInteger)buttonIndex {
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [self.containerView popToDismiss];
    if (self.completionBlock) {
        self.completionBlock(buttonIndex);
    }
}

- (UIView *)lineView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:221.0/255.0
                                           green:221.0/255.0
                                            blue:221.0/255.0
                                           alpha:1.0];
    return view;
}

- (UIButton *)buttonWithTitle:(NSString *)title isBold:(BOOL)isBold {
    UIColor *normalColor = [UIColor colorWithRed:89.0/255.0
                                           green:142.0/255.0
                                            blue:252.0/255.0
                                           alpha:1.0];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = isBold ? [UIFont boldSystemFontOfSize:17.0] : [UIFont systemFontOfSize:17.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


@end
