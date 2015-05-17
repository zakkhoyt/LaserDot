//
//  GameViewController.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/16/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "MyScene.h"


#include <sys/types.h>
#include <sys/sysctl.h>
@import AVFoundation;

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
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



@interface GameViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureSession *_session;
    BOOL _cameraRunning;
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
}
@property (nonatomic, strong) SKView *skView;
@property dispatch_queue_t avqueue;
@property (nonatomic, strong) MyScene *myScene;
@end

@implementation GameViewController

- (void)viewDidLoad {
    self.skView = [[SKView alloc]initWithFrame:self.view.bounds];
    self.skView.allowsTransparency = YES;
    [self.view addSubview:self.skView];
    self.avqueue = dispatch_queue_create("com.vaporwarewolf.laserdot.camera", NULL);
}



-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!self.skView.scene) {
        self.skView.showsFPS = YES;
        self.skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        self.myScene = [MyScene sceneWithSize:self.skView.bounds.size];
        self.myScene.scaleMode = SKSceneScaleModeAspectFill;
        self.myScene.backgroundColor = [UIColor clearColor];
        // Present the scene.
        [self.skView presentScene:self.myScene];
    }
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startCamera];
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    // TOOD: Update this to transitioncoordinators
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark AVFoundation stuff


-(void)startCamera{
    if(_cameraRunning == YES) return;
    
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    
    if (!input) {
        NSLog(@"Couldnt' create AV video capture device");
    }
    
    NSString *deviceHardwareName = [self deviceHardwareName];
    NSLog(@"deviceHardwareName: %@", deviceHardwareName);
    
    // If we are running on hardware capable of doing a good job at higher frame rates
    if([deviceHardwareName rangeOfString:@"iPad3"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPad4"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPad5"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPod6"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPhone5"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPhone6"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPhone7"].location != NSNotFound ||
       [deviceHardwareName rangeOfString:@"iPhone8"].location != NSNotFound){
        
        // Go up to the highest framerate
        for(AVCaptureDeviceFormat *vFormat in [device formats]) {
            CMFormatDescriptionRef description= vFormat.formatDescription;
            float maxrate = ((AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
            if(maxrate>59 && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                if([device lockForConfiguration:NULL] == YES) {
                    device.activeFormat = vFormat;
                    [device setActiveVideoMinFrameDuration:CMTimeMake(10,600)];
                    [device setActiveVideoMaxFrameDuration:CMTimeMake(10,600)];
                    [device unlockForConfiguration];
                    NSLog(@"Selected Video Format:  %@ %@ %@", vFormat.mediaType, vFormat.formatDescription, vFormat.videoSupportedFrameRateRanges);
                }
            }
        }
    }
    
    if([_session canAddInput:input]){
        [_session addInput:input];
    } else {
        NSLog(@"Can't add input. Returing");
        return;
    }
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    
    _videoPreviewLayer.frame = self.skView.bounds;
    
    
    AVCaptureConnection *previewLayerConnection=_videoPreviewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported]){
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    
    [self.view.layer insertSublayer:_videoPreviewLayer below:self.skView.layer];

    
    // ************************* configure AVCaptureSession to deliver raw frames via callback (as well as preview layer)
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSMutableDictionary *cameraVideoSettings = [[NSMutableDictionary alloc] init];
    NSString *key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
    [cameraVideoSettings setValue:value forKey:key];
    [videoOutput setVideoSettings:cameraVideoSettings];
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoOutput setSampleBufferDelegate:self queue:self.avqueue];
    
    if([_session canAddOutput:videoOutput]){
        
        [_session addOutput:videoOutput];
        _cameraRunning = YES;
        [_session startRunning];
    }
    else {
        NSLog(@"Could not add videoOutput");
        _cameraRunning = NO;
    }
}

-(void)stopCamera{
    if(_cameraRunning == NO) return;
    
    NSLog(@"Stop the camera capturing");
    [_session stopRunning];
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
    _session = nil;
    _cameraRunning = NO;
}

-(NSString*)deviceHardwareName{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return sDeviceModel;
}

-(AVCaptureDevice *)frontFacingCameraIfAvailable {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            captureDevice = device;
            break;
        }
    }
    
    if (captureDevice == nil) {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return captureDevice;
}


-(AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if([device position] == position) return device;
    }
    return nil;
}

//Change camera source
-(void)toggleCamera{
    if(_session) {
        //Indicate that some changes will be made to the session
        [_session beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [_session.inputs objectAtIndex:0];
        [_session removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [_session addInput:newVideoInput];
        
        [_session commitConfiguration];
    }
}


- (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(NSInteger)xx andY:(NSInteger)yy count:(int)count{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0 ; ii < count ; ++ii) {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}

#pragma mark AVCaptureVideoDataOutputDelegate

#define BYTES_PER_PIXEL 4

-(void)captureOutput :(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
    
    // Get a copy of the buffer that we can work with:
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    
    
//    // Synchronously process the pixel buffer to de-green it.
//    [self processPixelBuffer:imageBuffer];
    CVPixelBufferLockBaseAddress( imageBuffer, 0 );
    
    size_t bufferWidth = CVPixelBufferGetWidth(imageBuffer);
    size_t bufferHeight = CVPixelBufferGetHeight(imageBuffer);
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    for( int row = 0; row < bufferHeight; row++ ) {
        for( int column = 0; column < bufferWidth; column++ ) {
            //            pixel[1] = 0; // De-green (second pixel in BGRA is green)
            //            pixel[0] = MAX(hudPixel[0], pixel[0]);
            //            pixel[1] = MAX(hudPixel[1], pixel[1]);
            //            pixel[2] = MAX(hudPixel[2], pixel[2]);
            ////            pixel[3] += hudPixel[3];
            
            if(pixel[0] >= 128){
                pixel[0] = 1;
                pixel[1] = 1;
                pixel[2] = 1;
                pixel[3] = 1;
            } else {
                pixel[0] = 0;
                pixel[1] = 0;
                pixel[2] = 0;
                pixel[3] = 0;
            }
            pixel += BYTES_PER_PIXEL;
        }
    }
    
    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
    
    
    [self.myScene updateTextureWithData:pixel lengthInBytes:(width * height * 4) size:CGSizeMake(width, height)];
    
    // Next pass it to our scene in order to update/create our SKTexture
    
}




//- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer{
//    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
//    
//    size_t bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
//    size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
//    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
//    
//    for( int row = 0; row < bufferHeight; row++ ) {
//        for( int column = 0; column < bufferWidth; column++ ) {
////            pixel[1] = 0; // De-green (second pixel in BGRA is green)
//            //            pixel[0] = MAX(hudPixel[0], pixel[0]);
//            //            pixel[1] = MAX(hudPixel[1], pixel[1]);
//            //            pixel[2] = MAX(hudPixel[2], pixel[2]);
//            ////            pixel[3] += hudPixel[3];
//            
//            if(pixel[0] >= 128){
//                pixel[0] = 1;
//                pixel[1] = 1;
//                pixel[2] = 1;
//                pixel[3] = 1;
//            } else {
//                pixel[0] = 0;
//                pixel[1] = 0;
//                pixel[2] = 0;
//                pixel[3] = 0;
//            }
//            pixel += BYTES_PER_PIXEL;
//        }
//    }
//    
//    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
//}


@end
