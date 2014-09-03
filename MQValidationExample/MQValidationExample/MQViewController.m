//
//  MQViewController.m
//  MQValidationExample
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import "MQViewController.h"
#import "MQValidationManager.h"

@interface MQViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *phoneNumberTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@end

@implementation MQViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor grayColor];

	self.nameTextField = [self textFieldWithPlaceholder:@"Name"];
	self.emailTextField = [self textFieldWithPlaceholder:@"Email"];
	self.phoneNumberTextField = [self textFieldWithPlaceholder:@"Phone"];
	self.usernameTextField = [self textFieldWithPlaceholder:@"Username"];
	self.passwordTextField = [self textFieldWithPlaceholder:@"Password"];

	[self.view addSubview:self.nameTextField];
	[self.view addSubview:self.emailTextField];
	[self.view addSubview:self.phoneNumberTextField];
	[self.view addSubview:self.usernameTextField];
	[self.view addSubview:self.passwordTextField];
}

#pragma mark - Custom accessors

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder
{
	static CGFloat yOrigin = 35.0f;
	static MQViewControllerTags tag = MQViewControllerNameTextFieldTag;
	CGRect frame = CGRectMake(30.0f, yOrigin, 260.0f, 44.0f);
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	textField.placeholder = placeholder;
	textField.tag = tag;
	[textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];

	yOrigin += 64.0f;
	tag++;
	return textField;
}

#pragma mark - Private methods

- (void)textFieldTextDidChange:(UITextField *)textField;
{
	if (!textField.text || textField.text.length == 0) {
		return;
	}

	MQValidationManager *validationManager = [MQValidationManager sharedManager];
	BOOL valid = NO;
	switch (textField.tag) {
		case MQViewControllerNameTextFieldTag:
			valid = [validationManager validateValue:textField.text forKey:kMQValidationManagerNameKey];
			break;
		case MQViewControllerEmailTextFieldTag:
			valid = [validationManager validateValue:textField.text forKey:kMQValidationManagerEmailAddressKey];
			break;
		case MQViewControllerPhoneNumberTextFieldTag:
			valid = [validationManager validateValue:textField.text forKey:kMQValidationManagerPhoneNumberKey];
		case MQViewControllerUsernameTextFieldTag:
			valid = [validationManager validateValue:textField.text forKey:kMQValidationManagerUsernameKey];
			break;
		case MQViewControllerPasswordTextFieldTag:
			valid = [validationManager validateValue:textField.text forKey:kMQValidationManagerPasswordKey];
			break;
	}

	NSLog(@"%@ isValid %@", textField.placeholder, valid ? @"YES" : @"NO");
}

@end
