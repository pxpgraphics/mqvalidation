//
//  MQValidationManager.h
//  MQValidationExample
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQValidationManager : NSObject

- (BOOL)validateValue:(NSString *)value forKey:(NSString *)key;

+ (instancetype)sharedManager;

+ (NSString *)emailAddressRegex;
+ (NSString *)phoneNumberRegex;

@end
