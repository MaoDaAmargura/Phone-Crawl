//
//  NPCDialogManager.h
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

#import "Engine.h"


@interface NPCDialogManager : NSObject <UIActionSheetDelegate> {
	UIActionSheet *initial;
	UIView *targetViewRef;
	Engine *delegate;
}

- (id) initWithView:(UIView*)target andDelegate:(id)del;

- (void) beginDialog:(CGPoint)p;

@end
