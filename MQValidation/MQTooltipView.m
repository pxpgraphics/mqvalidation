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

@end
