//
//  MyScene.h
//  LaserDot
//
//  Created by Zakk Hoyt on 5/16/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

// TODO Call this from captureOutput;
-(void)updateTextureWithData:(void*)pixelData lengthInBytes:(size_t)lengthInBytes size:(CGSize)size;
@end
