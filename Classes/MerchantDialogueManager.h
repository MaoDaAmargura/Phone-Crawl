//
//  MerchantDialogueManager.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Engine;

@interface MerchantDialogueManager : NSObject <UIActionSheetDelegate>
{
	UIView *targetViewRef;
	Engine *delegate;
	
	NSMutableArray *mostRecentInv;
	int currentInvIndex;
	
	UIActionSheet *initial;
	UIActionSheet *sellMenu;
	UIActionSheet *buyMenu;
	
	
}

- (id) initWithView:(UIView*)target andDelegate:(id)del;

- (void) interactionWithInventory:(NSMutableArray*)inv;

@end
