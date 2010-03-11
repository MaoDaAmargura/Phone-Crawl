//
//  UIImage+Overlay.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Overlay.h"


@implementation UIImage (PCOverlay)

- (UIImage*) overlayedWithImage:(UIImage*)img
{
	int h = self.size.height;
	int w = self.size.width;
	UIGraphicsBeginImageContext(self.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIGraphicsPushContext(context);
	
	[self drawInRect:CGRectMake(0, 0, w, h)];
	[img drawInRect:CGRectMake(0, 0, w, h)];
	
	UIGraphicsPopContext();
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

- (UIImage*) resize:(CGSize)newSize
{	
	UIGraphicsBeginImageContext(newSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIGraphicsPushContext(context);
	
	[self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	
	UIGraphicsPopContext();
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

@end
