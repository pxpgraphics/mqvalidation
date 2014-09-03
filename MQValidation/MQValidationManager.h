//
//  MQValidationManager.h
//  MQValidationExample
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMQValidationManagerEmailAddressKey;
extern NSString * const kMQValidationManagerNameKey;
extern NSString * const kMQValidationManagerPasswordKey;
extern NSString * const kMQValidationManagerPhoneNumberKey;
extern NSString * const kMQValidationManagerUsernameKey;

@interface MQValidationManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)validateValue:(NSString *)value forKey:(NSString *)key;

+ (NSString *)emailAddressRegex;
+ (NSString *)nameRegex;
+ (NSString *)passwordRegex;
+ (NSString *)phoneNumberRegex;
+ (NSString *)usernameRegex;

@end
