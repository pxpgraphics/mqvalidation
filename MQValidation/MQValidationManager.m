//
//  MQValidationManager.m
//  MQValidation
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import "MQValidationManager.h"

NSString * const kMQValidationManagerEmailAddressKey = @"kMQValidationManagerEmailAddressKey";
NSString * const kMQValidationManagerNameKey = @"kMQValidationManagerNameKey";
NSString * const kMQValidationManagerPasswordKey = @"kMQValidationManagerPasswordKey";
NSString * const kMQValidationManagerPhoneNumberKey = @"kMQValidationManagerPhoneNumberKey";
NSString * const kMQValidationManagerUsernameKey = @"kMQValidationManagerUsernameKey";

@implementation MQValidationManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
	static MQValidationManager *sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[MQValidationManager alloc] init];
	});
	return sharedManager;
}

- (instancetype)init
{
	self = [super init];
	if (self) {

	}
	return self;
}

#pragma mark - Private methods

- (BOOL)validateValue:(NSString *)value forKey:(NSString *)key
{
	if (!value || value.length == 0) {
		return NO;
	}

	BOOL valid = NO;
	NSRegularExpression *regex;
	if ([key isEqualToString:kMQValidationManagerEmailAddressKey]) {
		// Email Address.
		regex = [[NSRegularExpression alloc] initWithPattern:[[self class] emailAddressRegex] options:NSRegularExpressionCaseInsensitive error:nil];
	} else if ([key isEqualToString:kMQValidationManagerNameKey]) {
		// Name.
		regex = [[NSRegularExpression alloc] initWithPattern:[[self class] nameRegex] options:NSRegularExpressionCaseInsensitive error:nil];
	} else if ([key isEqualToString:kMQValidationManagerPasswordKey]) {
		// Password.
		regex = [[NSRegularExpression alloc] initWithPattern:[[self class] passwordRegex] options:NSRegularExpressionCaseInsensitive error:nil];
	} else if ([key isEqualToString:kMQValidationManagerPhoneNumberKey]) {
		// Phone Number.
		regex = [[NSRegularExpression alloc] initWithPattern:[[self class] phoneNumberRegex] options:NSRegularExpressionCaseInsensitive error:nil];
	} else if ([key isEqualToString:kMQValidationManagerUsernameKey]) {
		// Username.
		regex = [[NSRegularExpression alloc] initWithPattern:[[self class] usernameRegex] options:NSRegularExpressionCaseInsensitive error:nil];
	} else {
		// Invalid key.
		return NO;
	}

	NSUInteger results = [regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
	if (results > 0) {
		valid = YES;
	}

	return valid;
}

#pragma mark - Public methods

+ (NSString *)emailAddressRegex
{
	return @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
}

+ (NSString *)nameRegex
{
	return @"^[A-Za-z.-]{2,}$";
}

+ (NSString *)passwordRegex
{
	return @"^(?=.*\\d+)(?=.*[A-Za-z])[0-9a-zA-Z!@#$%]{6,20}$";
}

+ (NSString *)phoneNumberRegex
{
	return @"^\\+[1-9]{1}[0-9]{10}$";
}

+ (NSString *)usernameRegex
{
	return @"^[A-Z0-9a-z_]{4,20}$";
}

@end
