//
//  SKScene+Unarchive.h
//  LaserDot
//
//  Created by Zakk Hoyt on 5/17/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKScene (Unarchive)
+(instancetype)unarchiveFromFile:(NSString*)file;
@end
