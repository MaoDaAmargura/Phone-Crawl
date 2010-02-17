//
//  PCPopupMenu.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PCPopupMenu.h"


@interface PopupMenuItem : NSObject
{
	id target;
	SEL method;
	NSString *title;
}

- (id) initWithName:(NSString*)name del:(id) delegate sel:(SEL)selector;
- (NSString*) title;

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

@end


@implementation PCPopupMenu

- (id) initWithOrigin:(CGPoint)origin
{
	CGRect newFrame = CGRectMake(origin.x, origin.y, POPUP_MENU_WIDTH, 20);
	if(self = [super initWithFrame:newFrame])
	{
		PopupMenuItem *i = [[[PopupMenuItem alloc] initWithName:@"Cancel" del:nil sel:nil] autorelease];
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
		UILabel *l = [[[UILabel alloc] initWithFrame:CGRectMake(0, 20*index, POPUP_MENU_WIDTH, 20)] autorelease];
		[drawnItems addObject:l];
		l.backgroundColor = [UIColor clearColor];
		l.text = [i title];;
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
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}


@end
