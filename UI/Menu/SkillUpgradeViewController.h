//
//  SkillUpgradeViewController.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@interface SkillUpgradeViewController : PCBaseViewController
{
	IBOutlet UIView *subspaceView;
	IBOutlet UIView *spellView;
	IBOutlet UIView *abilityView;
	
	IBOutlet UISegmentedControl *mainSegmentControl;
}

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont;

@end
