//
//  MQTooltipView.h
//  MQValidation
//
//  Created by Paris Pinkney on 9/3/14.
//

//  Copyright (c) Chris Miles 2010-2014.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MQTooltipViewPointDirection) {
	MQTooltipViewPointDirectionAny, // Default.
	MQTooltipViewPointDirectionUp,
	MQTooltipViewPointDirectionDown,
	MQTooltipViewPointDirectionLeft,
	MQTooltipViewPointDirectionRight
};

typedef NS_ENUM(NSUInteger, MQTooltipViewAnimation) {
	MQTooltipViewAnimationFade,
	MQTooltipViewAnimationSlide, // Default.
	MQTooltipViewAnimationPop
};

@class MQTooltipView;

@protocol MQTooltipViewDelegate <NSObject>

@optional
- (void)tooltipViewDidDismiss:(MQTooltipView *)tooltipView;
- (void)tooltipViewWillDismiss:(MQTooltipView *)tooltipView;
- (void)tooltipViewDidPresent:(MQTooltipView *)tooltipView;
- (void)tooltipViewWillPresent:(MQTooltipView *)tooltipView;

@end

@interface MQTooltipView : UIView

@property (nonatomic, assign) BOOL dismissTapAnywhere;
@property (nonatomic, assign, getter = hasGradientBackground) BOOL gradientBackground;
@property (nonatomic, assign, getter = hasShadow) BOOL shadow;
@property (nonatomic, assign, getter = isTapToDismissDisabled) BOOL disableTapToDismiss;
@property (nonatomic, assign, getter = isTranslucent) BOOL translucent;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat horizontalMargins;
@property (nonatomic, assign) CGFloat maximumWidth;
@property (nonatomic, assign) CGFloat pointerSize;
@property (nonatomic, assign) CGFloat verticalMargins;
@property (nonatomic, assign) CGSize margins;
@property (nonatomic, assign) MQTooltipViewAnimation animation;
@property (nonatomic, assign) MQTooltipViewPointDirection pointDirection;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSTextAlignment titleAlignment;
@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) UIColor *textColor;
@property (nonatomic, copy) UIColor *titleColor;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong, readonly) id targetObject;
@property (nonatomic, weak) id<MQTooltipViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;
- (instancetype)initWithMessage:(NSString *)message;
- (instancetype)initWithCustomView:(UIView *)customView;

- (void)dismissAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
- (void)presentFromBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated;
- (void)presentFromView:(UIView *)anchorView inView:(UIView *)containerView animated:(BOOL)animated;

@end
