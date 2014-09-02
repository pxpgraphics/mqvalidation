//
//  MQViewController.m
//  MQValidationExample
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import "MQViewController.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneMetaDataGenerator.h"
#import "NBPhoneNumberUtil.h"

@interface MQViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NBAsYouTypeFormatter *phoneNumberFormatter;
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

	NBPhoneMetaDataGenerator *generator = [[NBPhoneMetaDataGenerator alloc] init];
    [generator generateMetadataClasses];

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

- (NBAsYouTypeFormatter *)phoneNumberFormatter
{
	if (!_phoneNumberFormatter) {
		_phoneNumberFormatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"US"];
	}
	return _phoneNumberFormatter;
}

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

	switch (textField.tag) {
		case MQViewControllerPhoneNumberTextFieldTag:
		{
			NSString *text = [_phoneNumberFormatter inputDigit:[textField.text substringFromIndex:[textField.text length] - 1]];
			NSLog(@"- %@", text);
			break;
		}
		default:
			break;
	}
}

@end
