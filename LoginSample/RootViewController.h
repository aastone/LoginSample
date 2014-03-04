//
//  RootViewController.h
//  LoginSample
//
//  Created by wangyipu on 14-3-3.
//  Copyright (c) 2014年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginFormField.h"

@protocol LoginFormFieldDelegate;

@interface RootViewController : UIViewController<LoginFormFieldDelegate>

@property (weak, nonatomic) IBOutlet LoginFormField *emailField;
@property (weak, nonatomic) IBOutlet LoginFormField *passwordField;
@property (weak, nonatomic) IBOutlet LoginFormField *passwordConfirmField;

@end
