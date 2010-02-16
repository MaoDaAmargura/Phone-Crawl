//
//  PCPopupMenu.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Customizable pop up menu class.
//  Takes objects and functions to call and lists them by the given name.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define POPUP_MENU_WIDTH	40
#define POPUP_MENU_HEIGHT	60

@interface PCPopupMenu : UIView
{
	NSMutableArray *menuItems;
	UIImageView *backGroundImageView;
	NSMutableArray *drawnItems;
}

// Custom initializer. Always use this. The frame should be given with respect to the view this
// menu will be displayed in. The height is determined by the number of menu items.
- (id) initWithFrame:(CGRect) newFrame;

// Add an item to this menu.
- (void) addMenuItem:(NSString*)name delegate:(id) delegate selector:(SEL) selector;

// Called once, when ready to display. This renders the menu. If you need to add more items, 
// remove the object from its superview, add the items, then call this method again.
- (void) showInView:(UIView*)view;

// Helpers for turning display on and off.
- (void) show;
- (void) hide;

@end
