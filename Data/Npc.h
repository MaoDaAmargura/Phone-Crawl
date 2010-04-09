//
//  Npc.h
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	This file contains the main NPC class, which is designed to hold the data
//	required for complete interaction for an NPC, and the Dialog and Response
//	helper classes
//	Npc is meant to be extended by child classes into different types of
//	conversation behavior

#import <Foundation/Foundation.h>
#import "Critter.h"



// interface for Response
// Responses have a string of dialog text,
// a number that points to a response from the NPC
// and an optional function pointer
@interface Response : NSObject {
	NSString *dialog;
	int pointsTo;
	NSString *action;
}

// getter and setter methods
@property (retain) NSString *dialog;
@property int pointsTo;
@property (retain) NSString *action;

// init methods
-(id) initWithDialog:(NSString *)d pointsTo:(int) points action:(NSString *)acts;

@end

// interface for Dialog
// Dialogs have a dialog string
// and a linked list of possible responses
@interface Dialog : NSObject {
	NSString *dialog;
	NSMutableArray *responses;
}

// getter and setter methods
@property (retain) NSString *dialog;
@property (nonatomic, retain) NSMutableArray *responses;

// init methods (addResponse is only called during initialization)
-(id) initWithDialog:(NSString *)d;
-(void) addResponse:(Response *)r;

@end

// interface for Npc
// Npc has a linked list of dialogs that the NPC can say
// an opening dialog, which the NPC says upon starting conversation
// a pointer to the player object (needed for healing player, selling items, ect)
// and a pointer to the current dialog object in use in the conversation
@interface Npc : NSObject {
	NSMutableArray *dialogs;
	Dialog *opening;
	Critter *player;
	Dialog *current;
}

// getter and setter methods
@property (retain) NSMutableArray *dialogs;
@property (retain) Dialog *current;
@property (nonatomic, copy) Dialog *opening;

// init methods
-(id) initWithCritter:(Critter *)c;
// given a chosen response, moves the conversation to the required dialog
-(void) changeDialog:(Response *)r;

-(void) handle:(NSString *)act target:(Critter *) t;

@end
