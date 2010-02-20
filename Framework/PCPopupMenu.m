//
//  PCPopupMenu.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PCPopupMenu.h"

#define MENU_ITEM_SIZE 20

@interface PopupMenuItem : NSObject
{
	id target;
	SEL method;
	NSString *title;
}

- (id) initWithName:(NSString*)name del:(id) delegate sel:(SEL)selector;
- (NSString*) title;
- (void) fire;

@end

@implementation PopupMenuItem

- (id) initWithName:(NSString*)name del:(id) delegate sel:(SEL)selector
{
	if(self = [super init])
	{
		target = delegate;
		method = selector;
		title = name;
		return self;
	}
	return nil;
}

- (void) dealloc
{
	[title release];
	[super dealloc];
}

- (NSString*) title
{
	return title;
}

- (void) fire
{
	if ([target respondsToSelector:method])
	{
		IMP f = [target methodForSelector:method];
		(f)(target, method);
	}
}

@end


@implementation PCPopupMenu

- (id) initWithOrigin:(CGPoint)origin
{
	CGRect newFrame = CGRectMake(origin.x, origin.y, POPUP_MENU_WIDTH, MENU_ITEM_SIZE);
	if(self = [super initWithFrame:newFrame])
	{
		PopupMenuItem *i = [[[PopupMenuItem alloc] initWithName:@"Cancel" del:self sel:@selector(hide)] autorelease];
		menuItems = [[NSMutableArray alloc] initWithCapacity:5];
		[menuItems addObject:i];
		backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, newFrame.size.width, newFrame.size.height)];
		backGroundImageView.image = [UIImage imageNamed:@"popup_menu_background.png"];
		backGroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backGroundImageView];
		drawnItems = [[NSMutableArray alloc] initWithCapacity:5];
		return self;
	}
	return nil;
}

- (void) dealloc
{
	[menuItems release];
	[backGroundImageView release];
	[drawnItems release];
	[super dealloc];
}					 

- (void) addMenuItem:(NSString*)name delegate:(id) delegate selector:(SEL) selector
{
	PopupMenuItem *i = [[[PopupMenuItem alloc] initWithName:name del:delegate sel:selector] autorelease];
	[menuItems addObject:i];
}

- (void) renderMenuItems
{
	for(UILabel *l in drawnItems)
		[l removeFromSuperview];
	[drawnItems removeAllObjects];
	int index = 0;
	for(PopupMenuItem *i in [menuItems reverseObjectEnumerator])
	{
		UILabel *l = [[[UILabel alloc] initWithFrame:CGRectMake(0, MENU_ITEM_SIZE*index, POPUP_MENU_WIDTH, MENU_ITEM_SIZE)] autorelease];
		[drawnItems addObject:l];
		l.backgroundColor = [UIColor clearColor];
		l.text = [i title];
		[self addSubview:l];
		++index;
	}
}

- (void) showInView:(UIView*)view
{
	[self removeFromSuperview];
	CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 20*[menuItems count]);
	self.frame = newFrame;
	backGroundImageView.frame = self.bounds;
	[self renderMenuItems];
	[view addSubview:self];
	[self show];
}

- (void) show
{
	self.hidden = NO;
}

- (void) hide
{
	self.hidden = YES;
}

#pragma mark -
#pragma mark UIResponder


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touch = [[[touches allObjects] objectAtIndex:0] locationInView:self];
	int menuOption = touch.y/MENU_ITEM_SIZE;
	PopupMenuItem *i = [menuItems objectAtIndex:([menuItems count] - menuOption - 1)];
	[i fire];
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}


@end
