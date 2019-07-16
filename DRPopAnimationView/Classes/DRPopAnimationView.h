//
//  DRAlarmSettingNoticeView.h
//  Records
//
//  Created by admin on 2017/12/23.
//  Copyright © 2017年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXExtension/JXExtension.h>

typedef void (^DRAlertViewCompletionBlock)(NSInteger buttonIndex);
typedef void (^DRAlertViewCompletionHandleBlock)(id object);

@interface DRPopAnimationView : UIView

+ (void)showAlertViewWithCancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                   completion:(DRAlertViewCompletionBlock)completion;

+ (instancetype)alertViewWithCancelButtonTitle:(NSString *)cancelButtonTitle
                             otherButtonTitles:(NSArray *)otherButtonTitles;

- (void)showWithCompletion:(DRAlertViewCompletionBlock)completion ;
- (void)showWithView:(UIView *)view completion:(DRAlertViewCompletionBlock)completion;
- (void)dismissWithButtonIndex:(NSInteger)buttonIndex ;
- (UIButton *)buttonWithTitle:(NSString *)title isBold:(BOOL)isBold;
- (UIView *)lineView ;

@property (nonatomic, copy) DRAlertViewCompletionBlock completionBlock;
@property (weak, nonatomic) IBOutlet JXAlertContainerView *containerView;
@property (nonatomic, assign) BOOL isTapBlankClose;//点击背景关闭

@end
