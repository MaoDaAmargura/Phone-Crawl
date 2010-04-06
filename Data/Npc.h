//
//  Npc.h
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Critter.h"


@interface Response : NSObject {
	NSString *dialog;
	int pointsTo;
	SEL callfunc;
}

@property (retain) NSString *dialog;
@property int pointsTo;
@property SEL callfunc;

-(id) initWithDialog:(NSString *)d pointsTo:(int) points func:(SEL) func;

@end

@interface Dialog : NSObject {
	NSString *dialog;
	NSMutableArray *responses;
}

@property (nonatomic, retain) NSString *dialog;
@property (nonatomic, retain) NSMutableArray *responses;

-(id) initWithDialog:(NSString *)d;
-(void) addResponse:(Response *)r;

@end

@interface Npc : NSObject {
	NSMutableArray *dialogs;
	Dialog *opening;
	Critter *player;
	Dialog *current;
}

@property (nonatomic, retain) NSMutableArray *dialogs;
@property (retain) Dialog *current;
@property (nonatomic, copy) Dialog *opening;

-(id) initWithCritter:(Critter *)c;
-(void) changeDialog:(Response *)r;

@end
