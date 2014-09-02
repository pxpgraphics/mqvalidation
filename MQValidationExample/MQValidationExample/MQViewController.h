//
//  MQViewController.h
//  MQValidationExample
//
//  Created by Paris Pinkney on 9/2/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MQViewControllerTags) {
	MQViewControllerNameTextFieldTag = 1000,
	MQViewControllerEmailTextFieldTag,
	MQViewControllerPhoneNumberTextFieldTag,
	MQViewControllerUsernameTextFieldTag,
	MQViewControllerPasswordTextFieldTag
};

@interface MQViewController : UIViewController

@end
