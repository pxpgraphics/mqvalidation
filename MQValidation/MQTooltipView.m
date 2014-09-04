//
//  MQTooltipView.m
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

#import "MQTooltipView.h"
#import <QuartzCore/QuartzCore.h>

@interface MQTooltipView ()
{
//	BOOL _highlight;
//	CGFloat _cornerRadius;
//	CGFloat _pointerSize;
//	CGPoint self.anchorPoint;
//	CGSize self.tooltipSize;
//	MQTooltipViewPointDirection _pointDirection;
}

@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize tooltipSize;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, strong) NSTimer *autoDismissTimer;
@property (nonatomic, strong) UIButton *dismissTarget;
@property (nonatomic, strong, readwrite) id targetObject;

@end

@implementation MQTooltipView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
		self.opaque = NO;

		_backgroundColor = [UIColor colorWithRed:11.0f/255.0f green:38.0f/255.0f blue:96.0f/255.0f alpha:0.9f];
		_horizontalMargin = 2.0;
		_pointerSize = 12.0;
		_textAlignment = NSTextAlignmentCenter;
		_textColor = [UIColor whiteColor];
		_textFont = [UIFont fontWithName:@"AvenirNext-Regular" size:[UIFont systemFontSize]];
		_verticalMargin = 2.0;
        _animation = MQTooltipViewAnimationSlide;
        _borderColor = [UIColor blackColor];
        _borderWidth = 1.0;
        _cornerRadius = 10.0;
        _gradientBackground = YES;
        _preferredPointDirection = MQTooltipViewPointDirectionAny;
        _shadow = YES;
        _tapAnywhereToDismiss = NO;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
	CGRect frame = CGRectZero;
	self = [self initWithFrame:frame];
    if (self) {
        _title = title;
		_message = message;

        _titleFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:[UIFont labelFontSize]];
        _titleColor = [UIColor whiteColor];
        _titleAlignment = NSTextAlignmentCenter;
        _textFont = [UIFont fontWithName:@"AvenirNext-Regular" size:[UIFont systemFontSize]];
		_textColor = [UIColor whiteColor];
	}
	return self;
}

- (instancetype)initWithMessage:(NSString *)message
{
	CGRect frame = CGRectZero;
	self = [self initWithFrame:frame];
    if (self) {
		_message = message;
	}
	return self;
}

- (instancetype)initWithCustomView:(UIView *)customView
{
	CGRect frame = CGRectZero;
	self = [self initWithFrame:frame];
    if (self) {
		_customView = customView;
        [self addSubview:_customView];
	}
	return self;
}

#pragma mark - Custom accessors

- (CGRect)tooltipFrame
{
	CGRect frame;
	switch (self.pointDirection) {
		case MQTooltipViewPointDirectionUp:
			frame = CGRectMake(self.horizontalMargin,
							   self.anchorPoint.y + self.pointerSize,
							   self.tooltipSize.width,
							   self.tooltipSize.height);
			break;
		case MQTooltipViewPointDirectionDown:
			frame = CGRectMake(self.horizontalMargin,
							   self.anchorPoint.y - self.pointerSize - self.tooltipSize.height,
							   self.tooltipSize.width,
							   self.tooltipSize.height);
			break;
		case MQTooltipViewPointDirectionLeft:
			// TODO:
			break;
		case MQTooltipViewPointDirectionRight:
			// TODO:
			break;
		case MQTooltipViewPointDirectionAny:
			// TODO:
			break;
	}
	return frame;
}

- (CGRect)contentFrame
{
	CGRect tooltipFrame = [self tooltipFrame];
	CGRect frame = CGRectMake(tooltipFrame.origin.x + self.cornerRadius,
							  tooltipFrame.origin.y + self.cornerRadius,
							  tooltipFrame.size.width - (self.cornerRadius * 2.0f),
							  tooltipFrame.size.height - (self.cornerRadius * 2.0f));
	return frame;
}

- (void)setShadow:(BOOL)shadow
{
	if (_shadow == shadow) {
		return;
	}

	_shadow = shadow;

	if (shadow) {
		self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
		self.layer.shadowRadius = 2.0f;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOpacity = 0.3f;
	} else {
		self.layer.shadowOpacity = 0.0f;
	}
}

#pragma mark - UIView

- (void)layoutSubviews
{
	if (self.customView) {
		CGRect contentFrame = [self contentFrame];
        [self.customView setFrame:contentFrame];
    }
}

- (void)drawRect:(CGRect)rect
{
	CGRect tooltipRect = [self tooltipFrame];

	CGContextRef context = UIGraphicsGetCurrentContext();

	// Stroke.
	CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f); // Black.
	CGContextSetLineWidth(context, self.borderWidth);

	// Path.
	CGMutablePathRef tooltipPath = CGPathCreateMutable();

	CGPoint tooltipOrigin = tooltipRect.origin;
	CGSize tooltipSize = tooltipRect.size;

	switch (self.pointDirection) {
		case MQTooltipViewPointDirectionUp:
		{
			CGPathMoveToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargin, self.anchorPoint.y);
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargin + self.pointerSize, self.anchorPoint.y + self.pointerSize);

			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x + tooltipSize.width, tooltipOrigin.y,
								tooltipOrigin.x + tooltipSize.width, tooltipOrigin.y + self.cornerRadius,
								self.cornerRadius);
			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x + tooltipSize.width, tooltipOrigin.y + tooltipSize.height,
								tooltipOrigin.x + tooltipSize.width - self.cornerRadius, tooltipOrigin.y + tooltipSize.height,
								self.cornerRadius);
			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x, tooltipOrigin.y + tooltipSize.height,
								tooltipOrigin.x, tooltipOrigin.y + tooltipSize.height - self.cornerRadius,
								self.cornerRadius);
			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x, tooltipOrigin.y,
								tooltipOrigin.x + self.cornerRadius, tooltipOrigin.y,
								self.cornerRadius);
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargin - self.pointerSize, self.anchorPoint.y + self.pointerSize);
			break;
		}
		case MQTooltipViewPointDirectionDown:
		{
			CGPathMoveToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargin, self.anchorPoint.y);
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargin - self.pointerSize, self.anchorPoint.y - self.pointerSize);

			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x, tooltipOrigin.y + tooltipSize.height,
								tooltipOrigin.x, tooltipOrigin.y + tooltipSize.height - self.cornerRadius,
								self.cornerRadius);
			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x, tooltipOrigin.y,
								tooltipOrigin.x + self.cornerRadius, tooltipOrigin.y,
								self.cornerRadius);
			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x + tooltipSize.width, tooltipOrigin.y,
								tooltipOrigin.x + tooltipSize.width, tooltipOrigin.y + self.cornerRadius,
								self.cornerRadius);
			CGPathAddArcToPoint(tooltipPath, NULL,
								tooltipOrigin.x + tooltipSize.width, tooltipOrigin.y + tooltipSize.height,
								tooltipOrigin.x + tooltipSize.width - self.cornerRadius, tooltipOrigin.y + tooltipSize.height,
								self.cornerRadius);
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargin + self.pointerSize, self.anchorPoint.y - self.pointerSize);
			break;
		}
		case MQTooltipViewPointDirectionLeft:
		{
			// TODO:
			break;
		}
		case MQTooltipViewPointDirectionRight:
		{
			// TODO:
			break;
		}
		case MQTooltipViewPointDirectionAny:
		{
			// TODO:
			break;
		}
	}

	CGPathCloseSubpath(tooltipPath);

	CGContextSaveGState(context);
	CGContextAddPath(context, tooltipPath);
	CGContextClip(context);

	if (self.gradientBackground) {
		// Draw clipped background gradient.
		CGFloat tooltipMiddle = ((tooltipOrigin.y + (tooltipSize.height / 2.0f)) / self.bounds.size.height);

		CGGradientRef gradient;
		CGColorSpaceRef colorSpace;
		size_t locationCount = 5;
		CGFloat locationList[] = { 0.0f, tooltipMiddle - 0.03f, tooltipMiddle, tooltipMiddle + 0.03f, 1.0f};

		CGFloat colorHighlight = 0.0f;
		if (self.highlighted) {
			colorHighlight = 0.25f;
		}

		CGFloat red, green, blue, alpha;
		size_t numComponents = CGColorGetNumberOfComponents(self.backgroundColor.CGColor);
		const CGFloat *components = CGColorGetComponents(self.backgroundColor.CGColor);
		if (numComponents == 2) {
			red   = components[0];
			green = components[0];
			blue  = components[0];
			alpha = components[1];
		} else {
			red   = components[0];
			green = components[1];
			blue  = components[2];
			alpha = components[3];
		}

		CGFloat colorList[] = {
			// R | G | B | A.
			(red * 1.16f) + colorHighlight, (green * 1.16f) + colorHighlight, (blue * 1.16f) + colorHighlight, alpha,
			(red * 1.16f) + colorHighlight, (green * 1.16f) + colorHighlight, (blue * 1.16f) + colorHighlight, alpha,
			(red * 1.08f) + colorHighlight, (green * 1.08f) + colorHighlight, (blue * 1.08f) + colorHighlight, alpha,
			(red * 1.00f) + colorHighlight, (green * 1.00f) + colorHighlight, (blue * 1.00f) + colorHighlight, alpha,
			(red * 1.00f) + colorHighlight, (green * 1.00f) + colorHighlight, (blue * 1.00f) + colorHighlight, alpha
		};

		colorSpace = CGColorSpaceCreateDeviceRGB();
		gradient = CGGradientCreateWithColorComponents(colorSpace, colorList, locationList, locationCount);

		CGPoint startPoint, endPoint;
		startPoint = CGPointZero;
		endPoint = CGPointMake(0.0f, CGRectGetMaxY(self.bounds));

		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
		CGGradientRelease(gradient);
		CGColorSpaceRelease(colorSpace);
	} else {
		// Fill with solid color.
		CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
		CGContextFillRect(context, self.bounds);
	}

	CGContextRestoreGState(context);

	// Draw border.
	if (self.borderWidth > 0.0f) {
		size_t numBorderComponents = CGColorGetNumberOfComponents(self.borderColor.CGColor);
		const CGFloat *borderComponents = CGColorGetComponents(self.borderColor.CGColor);
		CGFloat red, green, blue, alpha;
		if (numBorderComponents == 2) {
			red   = borderComponents[0];
			green = borderComponents[0];
			blue  = borderComponents[0];
			alpha = borderComponents[1];
		} else {
			red   = borderComponents[0];
			green = borderComponents[1];
			blue  = borderComponents[2];
			alpha = borderComponents[3];
		}

		CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
		CGContextAddPath(context, tooltipPath);
		CGContextDrawPath(context, kCGPathStroke);
	}

	CGPathRelease(tooltipPath);

	// Draw title and text.
	if (self.title && self.title.length > 0) {
		[self.titleColor set];

		CGRect titleFrame = [self contentFrame];
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.alignment = self.titleAlignment;
		paragraphStyle.lineBreakMode = NSLineBreakByClipping;

		NSDictionary *attributes = @{ NSFontAttributeName: self.titleFont,
									  NSForegroundColorAttributeName: self.titleColor,
									  NSParagraphStyleAttributeName: paragraphStyle };

		[self.title drawWithRect:titleFrame
						 options:NSStringDrawingUsesLineFragmentOrigin
					  attributes:attributes
						 context:nil];
	}

	if (self.message && self.message.length > 0) {
		[self.textColor set];

		CGRect textFrame = [self contentFrame];
		// Move down to make room for title.
		if (self.title && self.title.length > 0) {
			NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
			paragraphStyle.lineBreakMode = NSLineBreakByClipping;

			CGSize textSize = CGSizeMake(textFrame.size.width, 99999.0f);
			NSDictionary *attributes = @{ NSFontAttributeName: self.titleFont,
										  NSParagraphStyleAttributeName: paragraphStyle };

			textFrame.origin.y += [self.title boundingRectWithSize:textSize
														   options:kNilOptions
														attributes:attributes
														   context:nil].size.height;
		}

		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.alignment = self.textAlignment;
		paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

		NSDictionary *attributes = @{ NSFontAttributeName: self.textFont,
									  NSForegroundColorAttributeName: self.textColor,
									  NSParagraphStyleAttributeName: paragraphStyle };

		[self.message drawWithRect:textFrame
						   options:NSStringDrawingUsesLineFragmentOrigin
						attributes:attributes
						   context:nil];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.enableTapToDismiss) {
		[super touchesBegan:touches withEvent:event];
		return;
	}

	[self dismiss];
}

#pragma mark - Private methods

- (void)autoDismissAnimatedDidFire:(NSTimer *)timer
{
    NSNumber *animated = [[timer userInfo] objectForKey:@"animated"];
    [self dismissAnimated:[animated boolValue]];
}

- (void)dismiss
{
	_highlighted = YES;
	[self setNeedsDisplay];

	[self dismissAnimated:YES];
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self finalizeDismiss];
}

- (void)dismissTapAnywhereAction:(id)sender
{
	[self dismiss];
}

- (void)finalizeDismiss
{
	[self.autoDismissTimer invalidate];
	self.autoDismissTimer = nil;

    if (self.dismissTarget) {
        [self.dismissTarget removeFromSuperview];
		self.dismissTarget = nil;
    }

	[self removeFromSuperview];

	_highlighted = NO;
	self.targetObject = nil;
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    // At the end set to normal size.
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

#pragma mark - Public methods

- (void)dismissAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:animated] forKey:@"animated"];

    self.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:delay
															 target:self
														   selector:@selector(autoDismissAnimatedDidFire:)
														   userInfo:userInfo
															repeats:NO];
}

- (void)dismissAnimated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(tooltipViewWillDismiss:)]) {
		[self.delegate tooltipViewWillDismiss:self];
	}

	if (!animated) {
		[self finalizeDismiss];
	}

	CGRect frame = self.frame;
	frame.origin.y += 10.0;

	[UIView beginAnimations:nil context:nil];
	self.alpha = 0.0;
	self.frame = frame;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
	[UIView commitAnimations];

	if ([self.delegate respondsToSelector:@selector(tooltipViewDidDismiss:)]) {
		[self.delegate tooltipViewDidDismiss:self];
	}
}

- (void)presentFromBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated
{

	UIView *anchorView = (UIView *)[barButtonItem performSelector:@selector(view)];
	UIView *anchorSuperview = [anchorView superview];
	UIView *containerView = [anchorSuperview superview];

	if (!containerView) {
		NSLog(@"Cannot determine container view from UIBarButtonItem: %@", barButtonItem);
		self.targetObject = nil;
		return;
	}

	self.targetObject = barButtonItem;
	[self presentFromView:anchorView inView:containerView animated:animated];
}

- (void)presentFromView:(UIView *)anchorView inView:(UIView *)containerView animated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(tooltipViewWillPresent:)]) {
		[self.delegate tooltipViewWillPresent:self];
	}

	if (!self.targetObject) {
		self.targetObject = anchorView;
	}

	// If we want to dismiss the tooltip when the user taps anywhere on the screen,
	// we need to insert a transparent button over the background.
	if (!self.enableTapToDismiss) {
		self.dismissTarget = [UIButton buttonWithType:UIButtonTypeCustom];
		self.dismissTarget.frame = containerView.bounds;
		[self.dismissTarget addTarget:self action:@selector(dismissTapAnywhereAction:) forControlEvents:UIControlEventTouchUpInside];
		[self.dismissTarget setTitle:@"" forState:UIControlStateNormal];
		[containerView addSubview:self.dismissTarget];
	}

	[containerView addSubview:self];

	// Size of rounded rect.
	CGFloat rectWidth;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.maximumWidth > 0.0f && self.maximumWidth < containerView.frame.size.width) {
			rectWidth = self.maximumWidth;
		} else if (self.maximumWidth > 0.0f) {
			rectWidth = containerView.frame.size.width - 20.0f;
		} else {
			rectWidth = (containerView.frame.size.width / 3.0f);
		}
	} else {
		if (self.maximumWidth > 0.0f && self.maximumWidth < containerView.frame.size.width) {
			rectWidth = self.maximumWidth;
		} else if (self.maximumWidth > 0.0f) {
			rectWidth = containerView.frame.size.width - 10.0f;
		} else {
			rectWidth = ((containerView.frame.size.width * 2.0f) / 3.0f);
		}
	}

	CGSize textSize = CGSizeZero;
	if (self.message && self.message.length > 0) {
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.alignment = self.textAlignment;
		paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

		NSDictionary *attributes = @{ NSFontAttributeName: self.textFont,
									  NSParagraphStyleAttributeName: paragraphStyle };

		textSize = [self.message boundingRectWithSize:CGSizeMake(rectWidth, 99999.0f)
											  options:NSStringDrawingUsesLineFragmentOrigin
										   attributes:attributes
											  context:nil].size;
	}

	if (self.customView) {
		textSize = self.customView.frame.size;
	}

	if (self.title && self.title.length > 0) {
		CGSize titleSize;
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.lineBreakMode = NSLineBreakByClipping;

		NSDictionary *attributes = @{ NSFontAttributeName: self.titleFont,
									  NSParagraphStyleAttributeName: paragraphStyle };

		titleSize = [self.title boundingRectWithSize:CGSizeMake(rectWidth, 99999.0f)
											 options:kNilOptions
										  attributes:attributes
											 context:nil].size;

		if (titleSize.width > textSize.width) {
			textSize.width = titleSize.width;
		}
		textSize.height += titleSize.height;
	}

	self.tooltipSize = CGSizeMake(textSize.width + (self.cornerRadius * 2.0f), textSize.height + (self.cornerRadius * 2.0f));

	UIView *superview = containerView.superview;
	if ([superview isKindOfClass:[UIWindow class]]) {
		superview = containerView;
	}

	CGPoint anchorRelativeOrigin = [anchorView.superview convertPoint:anchorView.frame.origin toView:superview];
	CGPoint containerRelativeOrigin = [superview convertPoint:containerView.frame.origin toView:superview];

	CGFloat yPointer = 0.0f; // Coordinate Y of pointer anchor (within containerView).
	if (anchorRelativeOrigin.y + anchorView.bounds.size.height < containerRelativeOrigin.y) {
		_pointDirection = MQTooltipViewPointDirectionUp;
	} else if (anchorRelativeOrigin.y > containerRelativeOrigin.y + containerView.bounds.size.height) {
		yPointer = containerView.bounds.size.height;
		_pointDirection = MQTooltipViewPointDirectionDown;
	} else {
		CGPoint anchorOriginInContainer = [anchorView convertPoint:CGPointZero toView:containerView];
		CGFloat sizeBelow = containerView.bounds.size.height - anchorOriginInContainer.y;

		switch (_pointDirection) {
			case MQTooltipViewPointDirectionUp:
			{
				yPointer = anchorOriginInContainer.y;
				break;
			}
			case MQTooltipViewPointDirectionDown:
			{
				yPointer = anchorOriginInContainer.y + anchorView.bounds.size.height;
				break;
			}
			case MQTooltipViewPointDirectionLeft:
			{
				// TODO:
				break;
			}
			case MQTooltipViewPointDirectionRight:
			{
				// TODO:
				break;
			}
			case MQTooltipViewPointDirectionAny:
			{
				if (sizeBelow > anchorOriginInContainer.y) {
					yPointer = anchorOriginInContainer.y + anchorView.bounds.size.height;
					_pointDirection = MQTooltipViewPointDirectionUp;
				} else {
					yPointer = anchorOriginInContainer.y;
					_pointDirection = MQTooltipViewPointDirectionDown;
				}
				break;
			}
		}
	}

	CGFloat width = containerView.bounds.size.width;
	CGPoint point = [anchorView.superview convertPoint:anchorView.center toView:containerView];
	CGFloat xPoint = point.x;
	CGFloat xTooltip = xPoint - roundf((self.tooltipSize.width / 2.0f));
	if (xTooltip < self.horizontalMargin) {
		xTooltip = self.horizontalMargin;
	}
	if (xTooltip + self.tooltipSize.width + self.horizontalMargin > width) {
		xTooltip = width - self.tooltipSize.width - self.horizontalMargin;
	}
	if (xPoint - self.pointerSize < xTooltip + self.cornerRadius) {
		xPoint = xTooltip + self.cornerRadius + self.pointerSize;
	}
	if (xPoint + self.pointerSize > xTooltip + self.tooltipSize.width - self.cornerRadius) {
		xPoint = xTooltip + self.tooltipSize.width - self.cornerRadius - self.pointerSize;
	}

	CGFloat height = self.tooltipSize.height + self.pointerSize + 10.0f;
	CGFloat yTooltip;
	switch (_pointDirection) {
		case MQTooltipViewPointDirectionUp:
		{
			yTooltip = self.verticalMargin + yPointer;
			self.anchorPoint = CGPointMake(xPoint - xTooltip, 0.0f);
			break;
		}
		case MQTooltipViewPointDirectionDown:
		{
			yTooltip = self.verticalMargin - height;
			self.anchorPoint = CGPointMake(xPoint - xTooltip, height - 2.0f);
			break;
		}
		case MQTooltipViewPointDirectionLeft:
		{
			// TODO:
			break;
		}
		case MQTooltipViewPointDirectionRight:
		{
			// TODO:
			break;
		}
		case MQTooltipViewPointDirectionAny:
		{
			// TODO:
			break;
		}
	}

	CGRect frame = CGRectMake(xTooltip - self.horizontalMargin,
							  yTooltip,
							  self.tooltipSize.width + (self.horizontalMargin * 2.0f),
							  height);
	frame = CGRectIntegral(frame);

	if (animated) {
		switch (self.animation) {
			case MQTooltipViewAnimationFade:
			{
				// TODO:
				break;
			}
			case MQTooltipViewAnimationPop:
			{
				self.frame = frame;
				self.alpha = 0.5f;
				self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);

				// Pop animation.
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
				[UIView setAnimationDuration:0.15f];
				self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
				self.alpha = 1.0;
				[UIView commitAnimations];
				break;
			}
			case MQTooltipViewAnimationSlide:
			{
				self.alpha = 0.0f;
				CGRect startFrame = frame;
				startFrame.origin.y += 10.0f;
				self.frame = startFrame;

				// Slide animation.
				[UIView beginAnimations:nil context:nil];
				self.alpha = 1.0;
				self.frame = frame;
				[UIView commitAnimations];

				break;
			}
		}

		[self setNeedsDisplay];
	} else {
		[self setNeedsDisplay];
		self.frame = frame;
	}

	if ([self.delegate respondsToSelector:@selector(tooltipViewDidPresent:)]) {
		[self.delegate tooltipViewDidPresent:self];
	}
}

@end
