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
        
        //        self.env = [[SKSpriteNode alloc]init];
        //        self.env.name = @"env";
        //        self.env.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        //        self.env.size = self.size;
        //        [self addChild:self.env];
        
        
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


-(void)clearAllDots{
    [self removeChildrenInArray:self.dots];
}


-(void)updateTextureWithPixels:(uint8_t*)pixel length:(size_t)size{
    //    NSLog(@"pixels[0]: %02X", (uint8_t) pixel[0]);
    //    NSLog(@"pixels[1]: %02X", (uint8_t) pixel[1]);
    //    NSLog(@"pixels[2]: %02X", (uint8_t) pixel[2]);
    //    NSLog(@"pixels[3]: %02X", (uint8_t) pixel[3]);
    
    
    //    if(self.envTexture == nil){
    //        self.envTexture = [SKMutableTexture mutableTextureWithSize:self.env.size];
    //        self.env.physicsBody = [SKPhysicsBody bodyWithTexture:self.envTexture alphaThreshold:0.5 size:self.env.size];
    //        self.env.physicsBody.friction = 0.0f;
    //        self.env.physicsBody.restitution = 1.0f;
    //        self.env.physicsBody.linearDamping = 0.0f;
    //        self.env.physicsBody.allowsRotation = NO;
    //        self.env.physicsBody.dynamic = NO;
    //    }
    //
    //
    //
    //    NSMutableData *data = [[NSMutableData alloc]initWithCapacity:300*300*4];
    //    char on[4] = {0xFF, 0xFF, 0xFF, 0xFF};
    //    char off[4] = {0x00, 0x00, 0x00, 0x00};
    //    for(NSUInteger x = 0; x < 300; x++){
    //        for(NSUInteger y = 0; y < 300; y++){
    //            if(x >= 148 && x <= 152){
    //                [data appendBytes:on length:4     ];
    //            } else {
    //                [data appendBytes:off length:4];
    //            }
    //        }
    //    }
    //    [self.envTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
    //        uint8_t *byteData = (uint8_t*)malloc(data.length);
    //        memcpy(byteData, data.bytes, data.length);
    //        pixelData = byteData;
    //
    ////        pixelData = pixel;
    //        NSLog(@"update texture");
    //    }];
    //    self.env.physicsBody = [SKPhysicsBody bodyWithTexture:self.envTexture alphaThreshold:0.5 size:self.env.size];
    
    
    //    if(self.env){
    //        [self.env removeChildrenInArray:@[self.env]];
    //    }
    //        self.env = [[SKSpriteNode alloc]init];
    //        self.env.name = @"env";
    //        self.env.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    //        self.env.size = self.size;
    //        [self addChild:self.env];
    //
    //
    //
    //        NSData* data = [NSData dataWithBytes:(const void *)pixel length:sizeof(unsigned char)*size];
    //        SKTexture *text = [SKTexture textureWithData:data size:self.size];
    //        self.env.physicsBody = [SKPhysicsBody bodyWithTexture:text alphaThreshold:0.5 size:self.env.size];
    //        self.env.physicsBody.friction = 0.0f;
    //        self.env.physicsBody.restitution = 1.0f;
    //        self.env.physicsBody.linearDamping = 0.0f;
    //        self.env.physicsBody.allowsRotation = NO;
    //        self.env.physicsBody.dynamic = NO;
    ////    }
    
    
    
    
    
}








-(void)updateTextureWithImage:(UIImage*)image{
    
    //    unsigned char *pixels = [self convertUIImageToBitmapRGBA8:image];
    //    NSLog(@"pixels[0]: %lu", (unsigned long) pixels[0]);
    //    NSLog(@"pixels[1]: %lu", (unsigned long) pixels[1]);
    //    NSLog(@"pixels[2]: %lu", (unsigned long) pixels[2]);
    //    NSLog(@"pixels[3]: %lu", (unsigned long) pixels[3]);
    
    if(self.envTexture == nil){
        //        self.envTexture = [SKMutableTexture mutableTextureWithSize:self.env.size];
        ////        self.envTexture = [[SKTexture textureWithImage:image] mutableCopy];
        //        self.env.physicsBody = [SKPhysicsBody bodyWithTexture:self.envTexture alphaThreshold:0.5 size:self.env.size];
        //        self.env.physicsBody.friction = 0.0f;
        //        self.env.physicsBody.restitution = 1.0f;
        //        self.env.physicsBody.linearDamping = 0.0f;
        //        self.env.physicsBody.allowsRotation = NO;
        //        self.env.physicsBody.dynamic = NO;
        ////        self.env.physicsBody.categoryBitMask = envCategory;
        ////        self.env.physicsBody.collisionBitMask = ballCategory;
        
        SKTexture *t = [SKTexture textureWithImage:image];
        self.env.physicsBody = [SKPhysicsBody bodyWithTexture:t alphaThreshold:0.5 size:self.env.size];
        //        self.envTexture = [[SKTexture textureWithImage:image] mutableCopy];
        //        self.env.physicsBody = [SKPhysicsBody bodyWithTexture:self.envTexture alphaThreshold:0.5 size:self.env.size];
        self.env.physicsBody.friction = 0.0f;
        self.env.physicsBody.restitution = 1.0f;
        self.env.physicsBody.linearDamping = 0.0f;
        self.env.physicsBody.allowsRotation = NO;
        self.env.physicsBody.dynamic = NO;
        //        self.env.physicsBody.categoryBitMask = envCategory;
        //        self.env.physicsBody.collisionBitMask = ballCategory;
        
    }
    
    
    //    [self.envTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
    //        unsigned char *pixels = [self convertUIImageToBitmapRGBA8:image];
    //        pixelData = pixels;
    //        NSLog(@"update texture");
    //    }];
    
    
    
    //    NSMutableData *data = [[NSMutableData alloc]initWithCapacity:300*300*4];
    //    char on[4] = {0xFF, 0xFF, 0xFF, 0xFF};
    //    char off[4] = {0x00, 0x00, 0x00, 0x00};
    //    for(NSUInteger x = 0; x < 300; x++){
    //        for(NSUInteger y = 0; y < 300; y++){
    //            if(x >= 148 && x <= 152){
    //                [data appendBytes:on length:4];
    //            } else {
    //                [data appendBytes:off length:4];
    //            }
    //        }
    //    }
    //    SKTexture *t = [SKTexture textureWithData:data size:CGSizeMake(300, 300)];
    //    self.env.physicsBody = [SKPhysicsBody bodyWithTexture:t size:self.size];
    //    self.env.physicsBody.friction = 0.0f;
    //    self.env.physicsBody.restitution = 1.0f;
    //    self.env.physicsBody.linearDamping = 0.0f;
    //    self.env.physicsBody.allowsRotation = NO;
    //    self.env.physicsBody.dynamic = NO;
    
    //    static bool once = NO;
    //    if(once == NO){
    //        once = YES;
    //        SKTexture *t = [SKTexture textureWithImage:image];
    //        self.env.physicsBody = [SKPhysicsBody bodyWithTexture:t size:image.size];
    //        self.env.physicsBody.friction = 0.0f;
    //        self.env.physicsBody.restitution = 1.0f;
    //        self.env.physicsBody.linearDamping = 0.0f;
    //        self.env.physicsBody.allowsRotation = NO;
    //        self.env.physicsBody.dynamic = NO;
    //    }
    
    
}


-(void)updateTextureWithData:(void*)pixelData lengthInBytes:(size_t)lengthInBytes size:(CGSize)size{
    
    //    if(self.objTexture == nil){
    //        NSData *data = [NSData dataWithBytes:pixelData length:lengthInBytes];
    //        self.objTexture = [SKMutableTexture textureWithData:data size:size];
    //        self.obj.physicsBody = [SKPhysicsBody bodyWithTexture:self.objTexture size:self.size];
    //    } else {
    //
    ////        Modifies the contents of a mutable texture.
    ////        The contents of the texture can be modified only at specific times when the graphics hardware permits it. When this method is called, it schedules a new background task to update the texture and then returns. Your block is called when the texture can be modified. Your block is called on an arbitrary queue. Your block should modify the texture’s contents and then return.
    ////        The texture bytes are assumed to be stored as tightly packed 32 bpp, 8bpc (unsigned integer) RGBA pixel data. The color components you provide should have already been multiplied by the alpha value.
    //
    //        [self.objTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
    //
    //        }];
    //    }
}



-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    self.startPoint = touchLocation;
    
    //    self.ball = [SKSpriteNode spriteNodeWithImageNamed: @"ball.png"];
    self.ball = [SKSpriteNode spriteNodeWithImageNamed: @"dot.png"];
    self.ball.name = ballCategoryName;
    self.ball.position = self.startPoint;
    self.ball.size = CGSizeMake(10, 10);
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
    UITouch* touch = [touches anyObject];
    CGPoint endPoint = [touch locationInNode:self];
    CGFloat deltaX = endPoint.x - self.startPoint.x;
    CGFloat deltaY = endPoint.y - self.startPoint.y;
    
    
    if(fabs(deltaX) + fabs(deltaY) > 5){
        deltaX /= 50.0;
        deltaY /= 50.0;
        [self.ball.physicsBody applyImpulse:CGVectorMake(deltaX, deltaY)];
        NSLog(@"%fx%f", deltaX, deltaY);
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






@end
