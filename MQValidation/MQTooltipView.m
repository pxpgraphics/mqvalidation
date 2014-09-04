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

@property (nonatomic, assign) BOOL highlight;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize tooltipSize;
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
		self.backgroundColor = [UIColor colorWithRed:11.0f/255.0f green:38.0f/255.0f blue:96.0f/255.0f alpha:0.9f];
		self.opaque = NO;

		_borderWidth = 1.0f;
		_cornerRadius = 10.0f;
		_horizontalMargins = 2.0f;
		_pointerSize = 12.0f;
		_textAlignment = NSTextAlignmentCenter;
		_textColor = [UIColor whiteColor];
		_textFont = [UIFont fontWithName:@"AvenirNext-Regular" size:[UIFont systemFontSize]];
		_verticalMargins = 2.0f;
        _animation = MQTooltipViewAnimationSlide;
        _borderColor = [UIColor blackColor];
        _dismissTapAnywhere = NO;
        _gradientBackground = YES;
        _pointDirection = MQTooltipViewPointDirectionAny;
        _shadow = NO;
	}
	return self;
}

- (instancetype)initWithCustomView:(UIView *)customView
{
	self = [self initWithFrame:CGRectZero];
	if (self) {
		_customView = customView;
		[self addSubview:_customView];
	}
	return self;
}

- (instancetype)initWithMessage:(NSString *)message
{
	self = [self initWithFrame:CGRectZero];
	if (self) {
		_message = message;
	}
	return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
	self = [self initWithFrame:CGRectZero];
	if (self) {
		_message = message;
		_textColor = [UIColor whiteColor];
		_textFont = [UIFont fontWithName:@"AvenirNext-Regular" size:[UIFont systemFontSize]];
		_title = title;
		_titleAlignment = NSTextAlignmentCenter;
		_titleColor = [UIColor whiteColor];
		_titleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:[UIFont labelFontSize]];
	}
	return self;
}

#pragma mark - Custom accessors

- (CGRect)tooltipFrame
{
	CGRect frame;
	switch (self.pointDirection) {
		case MQTooltipViewPointDirectionUp:
			frame = CGRectMake(self.horizontalMargins,
							   self.anchorPoint.y + self.pointerSize,
							   self.tooltipSize.width,
							   self.tooltipSize.height);
			break;
		case MQTooltipViewPointDirectionDown:
			frame = CGRectMake(self.horizontalMargins,
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

#pragma mark - UIView

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
			CGPathMoveToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargins, self.anchorPoint.y);
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargins + self.pointerSize, self.anchorPoint.y + self.pointerSize);

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
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargins - self.pointerSize, self.anchorPoint.y + self.pointerSize);
			break;
		}
		case MQTooltipViewPointDirectionDown:
		{
			CGPathMoveToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargins, self.anchorPoint.y);
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargins - self.pointerSize, self.anchorPoint.y - self.pointerSize);

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
			CGPathAddLineToPoint(tooltipPath, NULL, self.anchorPoint.x + self.horizontalMargins + self.pointerSize, self.anchorPoint.y - self.pointerSize);
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
		if (self.highlight) {
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

- (void)layoutSubviews
{
	[super layoutSubviews];

	if (self.customView) {
		CGRect contentFrame = [self contentFrame];
		self.customView.frame = contentFrame;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.disableTapToDismiss) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
}

#pragma mark - Private methods

- (void)popAnimationDidStop:(__unused NSString *)animationID finished:(__unused NSNumber *)finished context:(__unused void *)context
{
	// At the end set to normal size.
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)dismissTapAnywhereAction:(id)sender
{

}

#pragma mark - Public methods

- (void)dismissAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated
{

}

- (void)dismissAnimated:(BOOL)animated
{

}

- (void)presentFromBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated
{

}

- (void)presentFromView:(UIView *)anchorView inView:(UIView *)containerView animated:(BOOL)animated
{
	if (!self.targetObject) {
		self.targetObject = anchorView;
	}

	// If we want to dismiss the tooltip when the user taps anywhere on the screen,
	// we need to insert a transparent button over the background.
	if (self.dismissTapAnywhere) {
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
		self.pointDirection = MQTooltipViewPointDirectionUp;
	} else if (anchorRelativeOrigin.y > containerRelativeOrigin.y + containerView.bounds.size.height) {
		yPointer = containerView.bounds.size.height;
		self.pointDirection = MQTooltipViewPointDirectionDown;
	} else {
		CGPoint anchorOriginInContainer = [anchorView convertPoint:CGPointZero toView:containerView];
		CGFloat sizeBelow = containerView.bounds.size.height - anchorOriginInContainer.y;

		switch (self.pointDirection) {
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
					self.pointDirection = MQTooltipViewPointDirectionUp;
				} else {
					yPointer = anchorOriginInContainer.y;
					self.pointDirection = MQTooltipViewPointDirectionDown;
				}
				break;
			}
		}
	}

	CGFloat width = containerView.bounds.size.width;
	CGPoint point = [anchorView.superview convertPoint:anchorView.center toView:containerView];
	CGFloat xPoint = point.x;
	CGFloat xTooltip = xPoint - roundf((self.tooltipSize.width / 2.0f));
	if (xTooltip < self.horizontalMargins) {
		xTooltip = self.horizontalMargins;
	}
	if (xTooltip + self.tooltipSize.width + self.horizontalMargins > width) {
		xTooltip = width - self.tooltipSize.width - self.horizontalMargins;
	}
	if (xPoint - self.pointerSize < xTooltip + self.cornerRadius) {
		xPoint = xTooltip + self.cornerRadius + self.pointerSize;
	}
	if (xPoint + self.pointerSize > xTooltip + self.tooltipSize.width - self.cornerRadius) {
		xPoint = xTooltip + self.tooltipSize.width - self.cornerRadius - self.pointerSize;
	}

	CGFloat height = self.tooltipSize.height + self.pointerSize + 10.0f;
	CGFloat yTooltip;
	switch (self.pointDirection) {
		case MQTooltipViewPointDirectionUp:
		{
			yTooltip = self.verticalMargins + yPointer;
			self.anchorPoint = CGPointMake(xPoint - xTooltip, 0.0f);
			break;
		}
		case MQTooltipViewPointDirectionDown:
		{
			yTooltip = self.verticalMargins - height;
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

	CGRect frame = CGRectMake(xTooltip - self.horizontalMargins,
							  yTooltip,
							  self.tooltipSize.width + (self.horizontalMargins * 2.0f),
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

}

@end
