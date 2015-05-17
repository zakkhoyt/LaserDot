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
@property (nonatomic, strong) SKSpriteNode* obj;
@property (nonatomic, strong) SKMutableTexture *objTexture;
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
        self.obj = [[SKSpriteNode alloc] initWithImageNamed: objImageName];
        self.obj.name = paddleCategoryName;
        self.obj.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/3);
        self.obj.size = CGSizeMake(300, 300);
        [self addChild:self.obj];
        
        
        NSMutableData *data = [[NSMutableData alloc]initWithCapacity:300*300*4];
        char on[4] = {0xFF, 0xFF, 0xFF, 0xFF};
        char off[4] = {0x00, 0x00, 0x00, 0x00};
        for(NSUInteger x = 0; x < 300; x++){
            for(NSUInteger y = 0; y < 300; y++){
                if(x >= 148 && x <= 152){
                    [data appendBytes:on length:4];
                } else {
                    [data appendBytes:off length:4];
                }
            }
        }
        SKTexture *t = [SKTexture textureWithData:data size:CGSizeMake(300, 300)];
        self.obj.physicsBody = [SKPhysicsBody bodyWithTexture:t size:self.obj.size];
        
        
//        SKTexture *objTexture = [SKTexture textureWithImageNamed:objImageName];
//        self.obj.physicsBody = [SKPhysicsBody bodyWithTexture:objTexture size:self.obj.size];
        // 3
        self.obj.physicsBody.friction = 0.0f;
        // 4
        self.obj.physicsBody.restitution = 1.0f;
        // 5
        self.obj.physicsBody.linearDamping = 0.0f;
        // 6
        self.obj.physicsBody.allowsRotation = NO;
        self.obj.physicsBody.dynamic = NO;
    }
    return self;
}


-(void)updateTextureWithData:(void*)pixelData lengthInBytes:(size_t)lengthInBytes size:(CGSize)size{
    if(self.objTexture == nil){
//        NSData *data = [NSData dataWithBytes:pixelData length:lengthInBytes];
//        self.objTexture = [SKMutableTexture textureWithData:data size:size];
//        self.obj.physicsBody = [SKPhysicsBody bodyWithTexture:self.objTexture size:size];
    } else {
        
////        Modifies the contents of a mutable texture.
////        The contents of the texture can be modified only at specific times when the graphics hardware permits it. When this method is called, it schedules a new background task to update the texture and then returns. Your block is called when the texture can be modified. Your block is called on an arbitrary queue. Your block should modify the texture’s contents and then return.
////        The texture bytes are assumed to be stored as tightly packed 32 bpp, 8bpc (unsigned integer) RGBA pixel data. The color components you provide should have already been multiplied by the alpha value.
//
//        [self.objTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
//
//        }];
    }
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
