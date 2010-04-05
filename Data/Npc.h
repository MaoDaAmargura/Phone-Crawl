//
//  Npc.h
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct {
	NSString *dialog;
	int pointsTo;
} Response;

typedef struct {
	NSString *dialog;
	NSMutableArray *responses;
} Dialog;

@interface Npc : NSObject {
	NSMutableArray *dialogs;
}

@property (nonatomic, retain) NSMutableArray *dialogs;

-(id) init;

@end
