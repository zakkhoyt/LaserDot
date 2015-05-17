//
//  SKScene+Unarchive.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/17/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "SKScene+Unarchive.h"

@implementation SKScene (Unarchive)

+(instancetype)unarchiveFromFile:(NSString*)file{
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    return scene;
}

@end
