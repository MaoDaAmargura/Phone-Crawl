//
//  BattleMenuManager.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Critter;
@class Engine;

@interface BattleMenuManager : NSObject <UIActionSheetDelegate>
{
	Critter *playerRef;
	Engine *gameEngineRef;
	UIView	*targetViewRef;
	
	UIActionSheet *battleMenu;
	UIActionSheet *attackMenu;
	UIActionSheet *castMenu;
	UIActionSheet *itemMenu;
	UIActionSheet *cspellMenu;
	UIActionSheet *dspellMenu;
}

@property (nonatomic, retain) Critter *playerRef;

- (id) initWithTargetView:(UIView*)target andDelegate:(Engine*) del;

- (void) showBattleMenu;

@end
