#import <Foundation/Foundation.h>


@interface PCParticle : UIImageView {
	CGPoint velocity;
	float life;			// in seconds
}

@property (nonatomic) CGPoint velocity;
@property (nonatomic) float life;



@end



@interface PCEmitter: PCParticle {
	float frequency;	// approximate number per second
	CGPoint bias;		// where to center most particles - x and y both range -1 .. 1
}

@property (nonatomic) float frequency;
@property (nonatomic) CGPoint bias;


+ (PCEmitter*) startWithX: (int) x Y: (int) y velocityX: (int) vx velocityY: (int) vy
				imagePath: (NSString*) path lifeSpan: (float) _life freq: (float) _frequency bias: (CGPoint) _bias;

@end
