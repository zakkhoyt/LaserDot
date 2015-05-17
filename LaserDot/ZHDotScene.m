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
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";

@interface ZHDotScene ()
@property (nonatomic) BOOL isFingerOnPaddle;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) SKSpriteNode* ball;
@property (nonatomic, strong) SKSpriteNode* obj;
@property (nonatomic, strong) SKMutableTexture *objTexture;
@end

@implementation ZHDotScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

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
        
        
//        NSMutableData *data = [[NSMutableData alloc]initWithCapacity:300*300*4];
//        char on[4] = {0xFF, 0xFF, 0xFF, 0xFF};
//        char off[4] = {0x00, 0x00, 0x00, 0x00};
//        for(NSUInteger x = 0; x < 300; x++){
//            for(NSUInteger y = 0; y < 300; y++){
//                if(x >= 148 && x <= 152){
//                    [data appendBytes:on length:4];
//                } else {
//                    [data appendBytes:off length:4];
//                }
//            }
//        }
//        SKTexture *t = [SKTexture textureWithData:data size:CGSizeMake(300, 300)];
//        self.obj.physicsBody = [SKPhysicsBody bodyWithTexture:t size:self.obj.size];
        
        
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
    
    self.ball = [SKSpriteNode spriteNodeWithImageNamed: @"ball.png"];
    self.ball.name = ballCategoryName;
    self.ball.position = self.startPoint;
    [self addChild:self.ball];
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.frame.size.width/2];
    self.ball.physicsBody.friction = 0.0f;
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
    UITouch* touch = [touches anyObject];
    CGPoint endPoint = [touch locationInNode:self];
    CGFloat deltaX = endPoint.x - self.startPoint.x;
    CGFloat deltaY = endPoint.y - self.startPoint.y;
    
    if(fabs(deltaX) + fabs(deltaY) > 5){
        deltaX /= 10.0;
        deltaY /= 10.0;
        [self.ball.physicsBody applyImpulse:CGVectorMake(deltaX, deltaY)];
    } else {
        [self removeChildrenInArray:@[self.ball]];
    }
}

@end
