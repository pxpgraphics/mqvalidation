//
//  MQValidationManager.m
//  MQValidationExample
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import "MQValidationManager.h"

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



#pragma mark - Public methods



@end
