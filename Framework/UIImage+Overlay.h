//
//  UIImage+Overlay.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (PCOverlay)

- (UIImage*) overlayedWithImage:(UIImage*)img;

- (UIImage*) resize:(CGSize)newSize;

@end
