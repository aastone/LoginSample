//
// LoginFormFieldTests.m
//
// Copyright (c) 2013 Ben Guo
//
// https://github.com/benzguo/LoginFormField
//

#import <XCTest/XCTest.h>
#import "LoginFormField.h"

@interface LoginFormFieldTests : XCTestCase

@property (strong, nonatomic) LoginFormField *formField;

@end

@implementation LoginFormFieldTests

- (void)setUp
{
    [super setUp];
    self.formField = [[LoginFormField alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
}

- (void)tearDown
{
    self.formField = nil;
    [super tearDown];
}

- (void)beginEditing
{
    if ([self.formField becomeFirstResponder]) {
        [self.formField textFieldDidBeginEditing:self.formField.textField];
    }
}

- (void)type
{
    [self.formField textField:self.formField.textField shouldChangeCharactersInRange:(NSRange){0,0} replacementString:@""];
}

- (void)endEditing
{
    if ([self.formField textFieldShouldReturn:self.formField.textField]) {
        [self.formField textFieldDidEndEditing:self.formField.textField];
        [self.formField resignFirstResponder];
    }
}

- (void)testPropertiesAreInitializedToCorrectDefaults
{
    // alert view defaults
    XCTAssertTrue([self.formField.alertView.title isEqualToString:@""]);
    XCTAssertTrue([self.formField.alertView.message isEqualToString:@""]);
    XCTAssertTrue([[self.formField.alertView buttonTitleAtIndex:self.formField.alertView.cancelButtonIndex]
                   isEqualToString:@"Ok"]);
    XCTAssertTrue(self.formField.alertView.delegate == self.formField);
    
    // text field defaults
    XCTAssertTrue([self.formField.textField.text isEqualToString:@""]);
    XCTAssertTrue(self.formField.textField.borderStyle == UITextBorderStyleNone);
    XCTAssertTrue(!self.formField.textField.placeholder);
    XCTAssertTrue(self.formField.textField.delegate == self.formField);
    
    // default state
    XCTAssertTrue([self.formField formFieldState] == LoginFormFieldStateNone);
    XCTAssertTrue([self.formField leftIndicatorState] == LoginLeftIndicatorStateInactive);
}

- (void)testBasicTextValidation
{
    [self.formField setTextValidationBlock:^BOOL(NSString *text) {
        return (text.length >= 4);
    }];
    
    // 0 chars; don't end editing
    [self beginEditing];
    self.formField.textField.text = @"";
    [self type];
    XCTAssertTrue(self.formField.leftIndicatorState == LoginLeftIndicatorStateInactive);
    XCTAssertTrue(self.formField.leftIndicator.frame.size.width/self.formField.frame.size.height == self.formField.leftIndicatorInactiveWidth);
    XCTAssertTrue(self.formField.formFieldState == LoginFormFieldStateInvalid);
    XCTAssertTrue([self.formField.leftIndicator.backgroundColor isEqual:self.formField.leftIndicatorInvalidColor]);
    
    // 0 chars; end editing
    [self endEditing];
    XCTAssertTrue(self.formField.leftIndicatorState == LoginLeftIndicatorStateInactive);
    XCTAssertTrue(self.formField.leftIndicator.frame.size.width/self.formField.frame.size.height == self.formField.leftIndicatorInactiveWidth);
    XCTAssertTrue(self.formField.formFieldState == LoginFormFieldStateNone);
    XCTAssertTrue([self.formField.leftIndicator.backgroundColor isEqual:self.formField.leftIndicatorNoneColor]);
    
    // 1 char; don't end editing
    [self beginEditing];
    self.formField.textField.text = @"a";
    [self type];
    XCTAssertTrue(self.formField.leftIndicatorState == LoginLeftIndicatorStateInactive);
    XCTAssertTrue(self.formField.leftIndicator.frame.size.width/self.formField.frame.size.height == self.formField.leftIndicatorInactiveWidth);
    XCTAssertTrue(self.formField.formFieldState == LoginFormFieldStateInvalid);
    XCTAssertTrue([self.formField.leftIndicator.backgroundColor isEqual:self.formField.leftIndicatorInvalidColor]);
    
    // 2 chars; end editing
    [self endEditing];
    XCTAssertTrue(self.formField.leftIndicatorState == LoginLeftIndicatorStateActive);
    XCTAssertTrue(self.formField.leftIndicator.frame.size.width/self.formField.frame.size.height == self.formField.leftIndicatorActiveWidth);
    XCTAssertTrue(self.formField.formFieldState == LoginFormFieldStateInvalid);
    XCTAssertTrue([self.formField.leftIndicator.backgroundColor isEqual:self.formField.leftIndicatorInvalidColor]);
    
    // 4 chars; don't end editing
    [self beginEditing];
    self.formField.textField.text = @"aaaa";
    [self type];
    XCTAssertTrue(self.formField.leftIndicatorState == LoginLeftIndicatorStateInactive);
    XCTAssertTrue(self.formField.leftIndicator.frame.size.width/self.formField.frame.size.height == self.formField.leftIndicatorInactiveWidth);
    XCTAssertTrue(self.formField.formFieldState == LoginFormFieldStateValid);
    XCTAssertTrue([self.formField.leftIndicator.backgroundColor isEqual:self.formField.leftIndicatorValidColor]);
    
    // 4 chars; end editing
    [self endEditing];
    XCTAssertTrue(self.formField.leftIndicatorState == LoginLeftIndicatorStateInactive);
    XCTAssertTrue(self.formField.leftIndicator.frame.size.width/self.formField.frame.size.height == self.formField.leftIndicatorInactiveWidth);
    XCTAssertTrue(self.formField.formFieldState == LoginFormFieldStateValid);
    XCTAssertTrue([self.formField.leftIndicator.backgroundColor isEqual:self.formField.leftIndicatorValidColor]);
}

- (void)testAlertView
{
    __weak LoginFormFieldTests *weakSelf = self;
    [self.formField setTextValidationBlock:^BOOL(NSString *text) {
        if ([text isEqualToString:@"foo"]) {
            weakSelf.formField.alertView.title = @"text can't be foo";
            return NO;
        } else {
            weakSelf.formField.alertView.title = @"";
            return YES;
        }
    }];
    
    [self beginEditing];
    self.formField.textField.text = @"foo";
    [self type];
    XCTAssertTrue([self.formField.alertView.title isEqualToString:@"text can't be foo"]);
    
    self.formField.textField.text = @"bar";
    [self type];
    XCTAssertTrue([self.formField.alertView.title isEqualToString:@""]);
}



@end
