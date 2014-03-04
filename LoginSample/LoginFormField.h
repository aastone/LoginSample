//
//  LoginFormField.h
//  LoginSample
//
//  Created by wangyipu on 14-2-28.
//  Copyright (c) 2014年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoginLeftIndicatorState) {
    LoginLeftIndicatorStateInactive,
    LoginLeftIndicatorStateActive
};

typedef NS_ENUM(NSInteger, LoginFormFieldState) {
    LoginFormFieldStateInvalid,
    LoginFormFieldStateValid,
    LoginFormFieldStateNone
};

@protocol LoginFormFieldDelegate;

typedef BOOL (^LoginTextValidationBlock) (NSString *text);

@interface LoginFormField : UIView <UITextFieldDelegate,UIAlertViewDelegate>

#pragma mark - View
@property (weak, nonatomic) id <LoginFormFieldDelegate> delegate;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *leftIndicator;
@property (strong, nonatomic) UIAlertView *alertView;

#pragma mark - leftIndicator
@property (assign, nonatomic) CGFloat leftIndicatorInactiveWidth;
@property (assign, nonatomic) CGFloat leftIndicatorActiveWidth;

@property (assign, nonatomic) CGFloat leftIndicatorRightPadding;

@property (strong, nonatomic) UIColor *leftIndicatorInvalidColor;
@property (strong, nonatomic) UIColor *leftIndicatorValidColor;
@property (strong, nonatomic) UIColor *leftIndicatorNoneColor;

#pragma mark - Actions

- (LoginFormFieldState)formFieldState;
- (LoginLeftIndicatorState)leftIndicatorState;

- (void)setTextValidationBlock:(LoginTextValidationBlock)block;

@end

@protocol LoginFormFieldDelegate <UITextFieldDelegate, UIAlertViewDelegate>

@end
