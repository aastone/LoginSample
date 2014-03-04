//
//  LoginFormField.m
//  LoginSample
//
//  Created by wangyipu on 14-2-28.
//  Copyright (c) 2014年 stone. All rights reserved.
//

#import "LoginFormField.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

// relative to self.frame.height
#define DEFAULT_LEFT_TEXT_PADDING 0.2
#define DEFAULT_LEFT_INDICATOR_INACTIVE_ASPECT_RATIO 0.2
#define DEFAULT_LEFT_INDICATOR_ACTIVE_ASPECT_RATIO 0.8
#define DEFAULT_NONE_COLOR UIColorFromRGB(0x95A5A6)
#define DEFAULT_VALID_COLOR UIColorFromRGB(0x2ECC71)
#define DEFAULT_INVALID_COLOR UIColorFromRGB(0xE74C3C)

@implementation LoginFormField
{
    CGFloat _currentLeftIndicatorAspectRatio;
    
    LoginLeftIndicatorState _currentLeftIndicatorState;
    LoginFormFieldState _currentFormFieldState;
    
    LoginTextValidationBlock _textValidationBlock;
}

#pragma mark - Public

- (LoginLeftIndicatorState)leftIndicatorState
{
    return _currentLeftIndicatorState;
}

- (LoginFormFieldState)formFieldState
{
    return _currentFormFieldState;
}

- (void)setTextValidationBlock:(LoginTextValidationBlock)block
{
    _textValidationBlock = block;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    self.leftIndicatorInactiveWidth = DEFAULT_LEFT_INDICATOR_INACTIVE_ASPECT_RATIO;
    self.leftIndicatorActiveWidth = DEFAULT_LEFT_INDICATOR_ACTIVE_ASPECT_RATIO;
    self.leftIndicatorRightPadding = DEFAULT_LEFT_TEXT_PADDING;
    
    _currentLeftIndicatorAspectRatio = self.leftIndicatorInactiveWidth;
    _textValidationBlock = ^BOOL(NSString *text) {return YES;};
    
    self.leftIndicatorInvalidColor = DEFAULT_INVALID_COLOR;
    self.leftIndicatorValidColor = DEFAULT_VALID_COLOR;
    self.leftIndicatorNoneColor = DEFAULT_NONE_COLOR;
    
    self.textField = [[UITextField alloc] init];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.delegate = self;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.text = @" ";
    [self addSubview:self.textField];
    
    self.leftIndicator = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftIndicator.titleLabel.textColor = [UIColor whiteColor];
    [self.leftIndicator addTarget:self action:@selector(leftIndicatorTouchDown)
                 forControlEvents:UIControlEventTouchDown];
    [self.leftIndicator addTarget:self action:@selector(leftIndicatorTouchUp)
                 forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    [self addSubview:self.leftIndicator];
    
    [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateNone animated:NO];
    
    self.textField.text = @"";
    self.alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    self.alertView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - Drawing

- (void)updateLeftIndicatorState:(LoginLeftIndicatorState)leftIndicatorState
                  formFieldState:(LoginFormFieldState)formFieldState
                        animated:(BOOL)animated
{
    BOOL shouldAnimate = (_currentLeftIndicatorState && !leftIndicatorState) || animated;
    _currentLeftIndicatorState = leftIndicatorState;
    _currentFormFieldState = formFieldState;
    
    switch (leftIndicatorState) {
        case LoginLeftIndicatorStateInactive:
            self.leftIndicator.userInteractionEnabled = NO;
            [self updateLeftIndicatorAspectRatio:self.leftIndicatorInactiveWidth animated:shouldAnimate];
            break;
        case LoginLeftIndicatorStateActive:
        default:
            self.leftIndicator.userInteractionEnabled = YES;
            [self updateLeftIndicatorAspectRatio:self.leftIndicatorActiveWidth animated:shouldAnimate];
            break;
    }
    
    switch (formFieldState) {
        case LoginFormFieldStateNone:
            self.leftIndicator.backgroundColor = self.leftIndicatorNoneColor;
            [self.leftIndicator setTitle:@"" forState:UIControlStateNormal];
            break;
        case LoginFormFieldStateInvalid:
            self.leftIndicator.backgroundColor = self.leftIndicatorInvalidColor;
            [self.leftIndicator setTitle:(leftIndicatorState) ? @"!" : @"" forState:UIControlStateNormal];
            break;
        case LoginFormFieldStateValid:
        default:
            self.leftIndicator.backgroundColor = self.leftIndicatorValidColor;
            [self.leftIndicator setTitle:@"" forState:UIControlStateNormal];
            break;
    }
}

- (void)updateLeftIndicatorAspectRatio:(CGFloat)aspectRatio animated:(BOOL)animated
{
    _currentLeftIndicatorAspectRatio = aspectRatio;
    void (^animations)() = ^{
        self.leftIndicator.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.height * _currentLeftIndicatorAspectRatio, self.bounds.size.height);
        
        CGFloat textFieldX = self.bounds.size.height * (_currentLeftIndicatorAspectRatio + self.leftIndicatorRightPadding);
        self.textField.frame = CGRectMake(self.bounds.origin.x + textFieldX, self.bounds.origin.y, self.bounds.size.width - textFieldX, self.bounds.size.height);
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:animations completion:nil];
    } else {
        animations();
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateLeftIndicatorAspectRatio:_currentLeftIndicatorAspectRatio animated:NO];
    self.leftIndicator.titleLabel.font = [UIFont systemFontOfSize:self.textField.font.pointSize*1.5];
    
}

#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField];
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.delegate textFieldShouldEndEditing:textField];
    } else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateNone animated:NO];
    } else if (_textValidationBlock(textField.text)) {
        [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateValid animated:NO];
    } else {
        [self updateLeftIndicatorState:LoginLeftIndicatorStateActive formFieldState:LoginFormFieldStateInvalid animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_textValidationBlock(newText)) {
        [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateValid animated:NO];
    } else {
        [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateInvalid animated:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(textField: shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateNone animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegate textFieldShouldReturn:textField];
    } else {
        return YES;
    }
}

#pragma mark - textfield Notification

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    if ([textField isEqual:self.textField] && !textField.text.length) {
        [self updateLeftIndicatorState:LoginLeftIndicatorStateInactive formFieldState:LoginFormFieldStateNone animated:NO];
    }
}


#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.textField becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [self.delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}



#pragma mark - Button Actions

- (void)leftIndicatorTouchDown
{
    UIColor *color = [self.leftIndicator.backgroundColor colorWithAlphaComponent:0.8];
    self.leftIndicator.backgroundColor = color;
}

- (void)leftIndicatorTouchUp
{
    UIColor *color = [self.leftIndicator.backgroundColor colorWithAlphaComponent:1.0];
    self.leftIndicator.backgroundColor = color;
    
    [self.alertView show];
}

@end

































