#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@protocol WorldViewDelegate;

typedef enum {
	displayStatHealth,
	displayStatShield,
	displayStatMana,
} displayStatType;


@interface WorldView : PCBaseViewController
{
	IBOutlet UIImageView *mapImageView;
	
	IBOutlet UIView *healthBar;
	IBOutlet UIView *shieldBar;
	IBOutlet UIView	*manaBar;
	NSArray *displayBarArray;
	
	IBOutlet UILabel *healthLabel;
	IBOutlet UILabel *shieldLabel;
	IBOutlet UILabel *manaLabel;
	NSArray *displayLabelArray;
}

- (void) setDelegate:(id<WorldViewDelegate>) delegate;

@property (nonatomic, retain) IBOutlet UIImageView *mapImageView;
@property (nonatomic, retain) IBOutlet UIView *healthBar;
@property (nonatomic, retain) IBOutlet UIView *shieldBar;
@property (nonatomic, retain) IBOutlet UIView *manaBar;

- (void) setDisplay:(displayStatType) display withAmount:(float) amount ofMax:(float) max;

@end

#pragma mark -
#pragma mark WorldViewDelegate

@protocol WorldViewDelegate <NSObject>

- (void) worldView:(WorldView*) worldView touchedAt:(CGPoint)point;
- (void) worldView:(WorldView*) worldView selectedAt:(CGPoint)point;
- (void) worldViewDidLoad:(WorldView*) worldView;

@end
