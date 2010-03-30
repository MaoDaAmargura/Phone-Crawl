//
//  Critter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Critter.h"

#import "Util.h"
#import "Item.h"
#import "Spell.h"
#import "CombatAbility.h"



@implementation Critter

- (id) initWithLevel:(int)lvl
{
	if (self = [super init])
	{
		level = lvl;
		alive = YES;
	}
	return self;
}

- (void) gainCondition:(conditionType)cond
{
	conditionBitSet |= cond;
}

- (void) loseCondition:(conditionType)cond
{
	conditionBitSet &= ~cond;
}

- (void) takeDamage:(int)amount
{
	current.sp -= amount;
	if (current.sp >= 0) return;

	current.hp += current.sp;
	current.sp = 0;

	if (current.hp <= 0)
		alive = NO;
}

- (void) gainHealth:(int)amount
{
	current.hp += amount;
	if (current.hp <= total.hp) return;
	
	current.sp += current.hp - total.hp;
	current.hp = total.hp;
	if (current.sp > total.sp) 
		current.sp = total.sp;
}

- (void) gainItem:(Item*)it
{
	[inventory addObject:it];
}

- (void) loseItem:(Item*)it
{
	[inventory removeObject:it];
}

- (void) gainStatsForItem:(Item*)it
{
	if (!it) return;
}

- (void) loseStatsForItem:(Item*)it
{
	if (!it) return;
}

- (void) equipItem:(Item*)it
{
	if ([inventory containsObject:it])
	{
		if (![self hasItemEquipped:it]) 
		{
			switch (it.slot) 
			{
				case HEAD:
					[self loseStatsForItem:equipment.head];
					[self gainStatsForItem:it];
					equipment.head = it;
					break;
				case CHEST:
					[self loseStatsForItem:equipment.chest];
					[self gainStatsForItem:it];
					equipment.chest = it;
					break;
				case LEFT:
					[self loseStatsForItem:equipment.lhand];
					[self gainStatsForItem:it];
					equipment.lhand = it;
					break;
				case RIGHT:
					[self loseStatsForItem:equipment.lhand];
					[self gainStatsForItem:it];
					equipment.rhand = it;
					break;
				case EITHER:
					if (!equipment.rhand) 
					{
						[self gainStatsForItem:it];
						equipment.rhand = it;
					}
					else 
					{
						[self loseStatsForItem:equipment.lhand];
						[self gainStatsForItem:it];
						equipment.lhand = it;
					}
					break;
				case BOTH:
					[self loseStatsForItem:equipment.rhand];
					[self loseStatsForItem:equipment.lhand];
					[self gainStatsForItem:it];
					equipment.rhand = it;
					equipment.lhand = nil;
				default:
					[[[[UIAlertView alloc] initWithTitle:@"Can't Do That" 
												 message:[NSString stringWithFormat:@"%@ can't be equipped.", it.name]
												delegate:nil
									   cancelButtonTitle:@"Cancel"
									   otherButtonTitles:nil] autorelease] show];
					break;
			}
		}
	}
}

- (void) dequipItem:(Item*)it
{
	if (![self hasItemEquipped:it]) return;
	
	[self loseStatsForItem:it];
	switch (it.slot) {
		case HEAD:
			equipment.head = nil;
			break;
		case CHEST:
			equipment.chest = nil;
			break;
		case LEFT:
			equipment.lhand = nil;
			break;
		case RIGHT:
		case BOTH:
			equipment.rhand = nil;
			break;
		case EITHER:
			if (equipment.rhand == it) 
				equipment.rhand = nil;
			else if (equipment.lhand = it)
				equipment.lhand = nil;
			else 
				[[[[UIAlertView alloc] initWithTitle:@"Can't Do That"
											 message:[NSString stringWithFormat:@"%@ wasn't equipped.", it.name]
											delegate:nil
								   cancelButtonTitle:@"Cancel"
								   otherButtonTitles:nil] autorelease] show];

		default:
			break;
	}
}

- (BOOL) hasItemEquipped:(Item*)it
{
	return (	(equipment.rhand == it)
			||	(equipment.lhand == it)
			||	(equipment.head == it)
			||	(equipment.chest == it) );
}
	
- (float) getPhysDamage
{
	float dmg = 0;
	if (equipment.rhand) dmg+=equipment.rhand.damage;
	if (equipment.lhand) dmg+=equipment.lhand.damage * OFFHAND_DMG_PERCENTAGE;
	return dmg > 1? dmg : 1;	
}

- (float) getElemDamage
{
	int dmg = 0;
	if (equipment.rhand) dmg+=equipment.rhand.elementalDamage;
	if (equipment.lhand) dmg+=equipment.lhand.elementalDamage * OFFHAND_DMG_PERCENTAGE;
	return dmg;
}

@end
