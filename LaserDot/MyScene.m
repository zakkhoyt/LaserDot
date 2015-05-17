//
//  MyScene.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/16/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "MyScene.h"

static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";


@interface MyScene ()
@property (nonatomic) BOOL isFingerOnPaddle;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) SKSpriteNode* ball;
@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
//        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
//        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//        [self addChild:background];

        
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        
        // 1 Create a physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
        
        
        
        
        
        
        
        
//        SKSpriteNode* paddle = [[SKSpriteNode alloc] initWithImageNamed: @"paddle.png"];
//        paddle.name = paddleCategoryName;
//        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddle.frame.size.height * 0.6f);
//        [self addChild:paddle];
//        paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.frame.size];
//        paddle.physicsBody.restitution = 0.1f;
//        paddle.physicsBody.friction = 0.4f;
//        // make physicsBody static
//        paddle.physicsBody.dynamic = NO;
        
        
        
        
        NSString *objImageName = @"tree.png";
        SKSpriteNode* obj = [[SKSpriteNode alloc] initWithImageNamed: objImageName];
        obj.name = paddleCategoryName;
        obj.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/3);
        obj.size = CGSizeMake(300, 300);
        [self addChild:obj];
        
        
        SKTexture *objTexture = [SKTexture textureWithImageNamed:objImageName];
        obj.physicsBody = [SKPhysicsBody bodyWithTexture:objTexture size:obj.size];
        // 3
        obj.physicsBody.friction = 0.0f;
        // 4
        obj.physicsBody.restitution = 1.0f;
        // 5
        obj.physicsBody.linearDamping = 0.0f;
        // 6
        obj.physicsBody.allowsRotation = NO;
        obj.physicsBody.dynamic = NO;
    }
    return self;
}



-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    self.startPoint = touchLocation;
    
    
    // 1
    self.ball = [SKSpriteNode spriteNodeWithImageNamed: @"ball.png"];
    self.ball.name = ballCategoryName;
    self.ball.position = self.startPoint;
    [self addChild:self.ball];
    
    // 2
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.frame.size.width/2];
    // 3
    self.ball.physicsBody.friction = 0.0f;
    // 4
    self.ball.physicsBody.restitution = 1.0f;
    // 5
    self.ball.physicsBody.linearDamping = 0.0f;
    // 6
    self.ball.physicsBody.allowsRotation = NO;
//    [ball.physicsBody applyImpulse:CGVectorMake(deltaX, deltaY)];

    
    
//    /* Called when a touch begins */
//    UITouch* touch = [touches anyObject];
//    CGPoint touchLocation = [touch locationInNode:self];
//    
//    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
//    if (body && [body.node.name isEqualToString: paddleCategoryName]) {
//        NSLog(@"Began touch on paddle");
//        self.isFingerOnPaddle = YES;
//    }

}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInNode:self];
    self.ball.position = currentPoint;
    
    
    
    
    
//    // 1 Check whether user tapped paddle
//    if (self.isFingerOnPaddle) {
//        // 2 Get touch location
//        UITouch* touch = [touches anyObject];
//        CGPoint touchLocation = [touch locationInNode:self];
//        CGPoint previousLocation = [touch previousLocationInNode:self];
//        // 3 Get node for paddle
//        SKSpriteNode* paddle = (SKSpriteNode*)[self childNodeWithName: paddleCategoryName];
//        // 4 Calculate new position along x for paddle
//        int paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
//        // 5 Limit x so that the paddle will not leave the screen to left or right
//        paddleX = MAX(paddleX, paddle.size.width/2);
//        paddleX = MIN(paddleX, self.size.width - paddle.size.width/2);
//        // 6 Update position of paddle
//        paddle.position = CGPointMake(paddleX, paddle.position.y);
//    }
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    CGPoint endPoint = [touch locationInNode:self];
    
    

    CGFloat deltaX = endPoint.x - self.startPoint.x;
    CGFloat deltaY = endPoint.y - self.startPoint.y;
    deltaX /= 10.0;
    deltaY /= 10.0;
    
    [self.ball.physicsBody applyImpulse:CGVectorMake(deltaX, deltaY)];
//    self.isFingerOnPaddle = NO;
}
@end
