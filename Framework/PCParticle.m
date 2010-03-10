#import "PCParticle.h"

#import <Foundation/Foundation.h>

static NSMutableArray *liveParticles = nil;
static NSMutableArray *deadParticles = nil;
static NSMutableArray *liveEmitters = nil;
static NSMutableArray *deadEmitters = nil;



@implementation PCParticle
@synthesize velocity, life;

- (PCParticle*) initWithX: (int) x Y: (int) y velocityX: (int) vx velocityY: (int) vy imagePath: (NSString*) path lifeSpan: (int) _life {
	UIImage *img = [UIImage imageNamed: path];
	CGSize size = img.size;

	self = [super initWithFrame: CGRectMake(0, 0, size.x, size.y)];
	self.center = CGPointMake(x, y);
	life = _life;
	velocity = CGPointMake(vx, vy);
	self.image = img;
	return self;
}

+ (PCParticle*) getParticle {
	if (![deadParticles count]) {
		for (int LCV = 0; LCV < 18; LCV++) {
			[deadParticles addObject: [PCParticle alloc]];
		}
	}
	PCParticle *retval = [deadParticles lastObject];
	[liveParticles addObject: retval];
	[deadParticles removeLastObject];
	return retval;
}

+ (void) initialize {
	deadParticles = [[NSMutableArray alloc] initWithCapacity: 36];
	liveParticles = [[NSMutableArray alloc] initWithCapacity: 36];
	for (int LCV = 0; LCV < 18; LCV++) {
		[deadParticles addObject: [PCParticle alloc]];
	}
}

@end


@implementation PCEmitter
@synthesize frequency, bias;

- (PCEmitter*) initWithX: (int) x Y: (int) y velocityX: (int) vx velocityY: (int) vy
			   imagePath: (NSString*) path lifeSpan: (int) _life freq: (float) _frequency bias: (CGPoint) _bias {
	[super initWithX: x Y: y velocityX: vx velocityY: vy imagePath: path lifeSpan: _life];
	frequency = _frequency;
	bias = _bias;

	return self;
}

+ (PCEmitter*) get {
	if (!deadEmitters) {
		deadEmitters = [[NSMutableArray alloc] initWithCapacity: 6];
		liveEmitters = [[NSMutableArray alloc] initWithCapacity: 6];
	}
	if (![deadEmitters count]) {
		for (int LCV = 0; LCV < 6; LCV++) {
			[deadEmitters addObject: [PCEmitter alloc]];
		}
	}
	PCEmitter *retval = [deadEmitters lastObject];
	[liveEmitters addObject: retval];
	[deadEmitters removeLastObject];
	return retval;
}

- (void) updateEmitter: (NSString*) animationID finished: (BOOL) finished context: (void*) context {
	// FIXME randomize
	NSLog([self description]);
	if (!self.superview) exit(1);
}

+ (PCEmitter*) startWithX: (int) x Y: (int) y velocityX: (int) vx velocityY: (int) vy
			  imagePath: (NSString*) path lifeSpan: (int) _life freq: (float) _frequency bias: (CGPoint) _bias {
	PCEmitter *retval = [PCEmitter get];
	[retval initWithX: x Y: y velocityX: vx velocityY: vy imagePath: path lifeSpan: _life freq: _frequency bias: _bias];

	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate: retval];
	[UIView setAnimationRepeatCount: retval.life * 60];
	[UIView setAnimationDidStopSelector:@selector(updateEmitter:finished:context:)];
	[UIView setAnimationDuration: 0.01];
	float dx = retval.velocity.x / 60;
	float dy = retval.velocity.y / 60;
	retval.center = CGPointMake(retval.center.x + dx , retval.center.y + dy);
	[UIView commitAnimations];

	return retval;
}


//- (void) finishedMoveOutAnimation:(NSString*)animationID finished:(BOOL)finished context:(void *)context {	
//	shrinker.imageView.transform = CGAffineTransformMakeScale(1, 1);
//	shrinker.imageView.center = CGPointMake(shrinker.imageView.center.x, shrinker.view.center.y - 36);
//	[shrinker.view removeFromSuperview];
//	
//	shrinker = nil;
//	if (verbose) NSLog(@"shrinker unloaded");
//	
//	[[ManagedObject context] save: nil];
//	
//	[MovieViewController stopIgnore];
//	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
//	ignoreScroll = false;
//	
//	for (int LCV = -PAGES_TO_LOAD; LCV <= PAGES_TO_LOAD; LCV++) {
//		[self loadScrollViewWithPage: [self page] + LCV];
//	}
//}
//
//- (void) finishedMoveInAnimation:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
//	NSMutableArray *array = (NSMutableArray*)context;
//	MovieViewController *left = (MovieViewController*) [array objectAtIndex:0];
//	MovieViewController *right = (MovieViewController*) [array objectAtIndex:1];
//	
//	[UIView beginAnimations:animationID context:context];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(finishedMoveOutAnimation:finished:context:)];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	// EaseOut seems to cause a jump...?
//	[UIView setAnimationDuration: shrinkDuration];
//	left.view.center = CGPointMake(left.view.center.x - PAGE_WIDTH / 2, left.view.center.y);
//	right.view.center = CGPointMake(right.view.center.x - PAGE_WIDTH / 2, right.view.center.y);	
//	[UIView commitAnimations];
//}


@end


