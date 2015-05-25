//
//  MyScene.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/16/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHDotScene.h"

static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* envCategoryName = @"env";

static const uint32_t ballCategory  = 0x1 << 0;
static const uint32_t envCategory = 0x1 << 1;
static const uint32_t treeCategory = 0x1 << 2;


@interface ZHDotScene () <SKPhysicsContactDelegate>
@property (nonatomic) BOOL isFingerOnPaddle;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) NSMutableArray *dots;
@property (nonatomic, strong) SKSpriteNode* ball;
@property (nonatomic, strong) SKSpriteNode* obj;
@property (nonatomic, strong) SKSpriteNode* env;
@property (nonatomic, strong) SKMutableTexture *envTexture;
@end

@implementation ZHDotScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.dots = [@[]mutableCopy];
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        
        NSString *objImageName = @"tree.png";
        self.obj = [[SKSpriteNode alloc] initWithImageNamed: objImageName];
        self.obj.name = paddleCategoryName;
        self.obj.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/3);
        self.obj.size = CGSizeMake(300, 300);
        [self addChild:self.obj];
        SKTexture *objTexture = [SKTexture textureWithImageNamed:objImageName];
        self.obj.physicsBody = [SKPhysicsBody bodyWithTexture:objTexture size:self.obj.size];
        // 3
        self.obj.physicsBody.friction = 0.0f;
        // 4
        self.obj.physicsBody.restitution = 1.0f;
        // 5
        self.obj.physicsBody.linearDamping = 0.0f;
        // 6
        self.obj.physicsBody.allowsRotation = NO;
        self.obj.physicsBody.dynamic = NO;
        self.obj.physicsBody.categoryBitMask = treeCategory;
        self.obj.physicsBody.collisionBitMask = ballCategory;
        
    }
    return self;
}



-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    self.startPoint = touchLocation;
    
    // We are using self.ball as a means to reference the node in touchesBegan|Moved|Ended
    self.ball = [SKSpriteNode spriteNodeWithImageNamed: @"ball"];
    self.ball.name = ballCategoryName;
    self.ball.position = self.startPoint;
    [self.dots addObject:self.ball];
    [self addChild:self.ball];
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.frame.size.width/2];
    self.ball.physicsBody.friction = 0.2f;
    self.ball.physicsBody.restitution = 1.0f;
    self.ball.physicsBody.linearDamping = 0.0f;
    self.ball.physicsBody.allowsRotation = NO;
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInNode:self];
    self.ball.position = currentPoint;
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    // Calculate delta since touch start.
    UITouch* touch = [touches anyObject];
    CGPoint endPoint = [touch locationInNode:self];
    CGFloat deltaX = endPoint.x - self.startPoint.x;
    CGFloat deltaY = endPoint.y - self.startPoint.y;
    if(fabs(deltaX) + fabs(deltaY) > 5){
        deltaX /= 10.0;
        deltaY /= 10.0;
        [self.ball.physicsBody applyImpulse:CGVectorMake(deltaX, deltaY)];
        NSLog(@"%.2f %.2f", deltaX, deltaY);
    } else {
        [self removeChildrenInArray:@[self.ball]];
    }
}



-(void)didBeginContact:(SKPhysicsContact*)contact {
    NSLog(@"collision");
    //    // 1 Create local variables for two physics bodies
    //    SKPhysicsBody* firstBody;
    //    SKPhysicsBody* secondBody;
    //    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    //    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
    //        firstBody = contact.bodyA;
    //        secondBody = contact.bodyB;
    //    } else {
    //        firstBody = contact.bodyB;
    //        secondBody = contact.bodyA;
    //    }
    //    // 3 react to the contact between ball and bottom
    //    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory) {
    //        //TODO: Replace the log statement with display of Game Over Scene
    //        NSLog(@"Hit bottom. First contact has been made.");
    //    }
}




-(void)clearAllDots{
    [self removeChildrenInArray:self.dots];
}

-(void)updateTextureWithImage:(UIImage*)image{
    // Lazy clean up
    if(self.env) {
        [self.env removeFromParent];
        self.env = nil;
    }
    
    SKTexture *texture = [SKTexture textureWithImage:image];
    self.env = [[SKSpriteNode alloc]initWithTexture:texture color:[UIColor greenColor] size:self.size];
    self.env.color = [UIColor blueColor];
    self.env.alpha = 0.4;
    self.env.name = envCategoryName;
    self.env.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    // Self an image may have different aspect ratios
    CGFloat ratio = self.size.width / image.size.width;
    self.env.size = CGSizeMake(self.size.width, image.size.height * ratio);
    [self addChild:self.env];
    
    self.env.physicsBody = [SKPhysicsBody bodyWithTexture:texture size:self.env.size];
    // 3
    self.env.physicsBody.friction = 0.0f;
    // 4
    self.env.physicsBody.restitution = 1.0f;
    // 5
    self.env.physicsBody.linearDamping = 0.0f;
    // 6
    self.env.physicsBody.allowsRotation = NO;
    self.env.physicsBody.dynamic = NO;
    self.env.physicsBody.categoryBitMask = envCategory;
    self.env.physicsBody.collisionBitMask = ballCategory;
}

@end
