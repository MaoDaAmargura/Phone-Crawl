//
//  NPCDialogManager.h
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	The NPCDialogManager is responsible for creating the dialog menus
//	and detecting when a response is selected

#import <Foundation/Foundation.h>
#import "Util.h"

#import "Engine.h"
#import "Critter.h"

@class Dialog;

// interface for NPCDialogManager
@interface NPCDialogManager : NSObject <UIActionSheetDelegate> {
	// UIActionSheet is the menu that shows the conversation text and the responses
	UIActionSheet *initial;
	// pointer to the target view, used for drawing the menu
	UIView *targetViewRef;
	// pointer to the game engine
	Engine *delegate;
	// pointer to the current NPC
	Critter *current;
	// pointer to the current message being displayed
	Dialog *message;
}

// init functions
- (id) initWithView:(UIView*)target andDelegate:(id)del;
// start dialog with NPC
- (void) beginDialog:(Critter *)c;
// change dialog based on response
- (void) setDialog:(Dialog *)d;

@end
