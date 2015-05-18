//
//  GameViewController.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/16/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHDotViewController.h"
#import "GameScene.h"
#import "ZHDotScene.h"


#include <sys/types.h>
#include <sys/sysctl.h>
@import AVFoundation;

@interface ZHDotViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL cameraRunning;
@property (nonatomic, strong) SKView *skView;
@property dispatch_queue_t avqueue;
@property (nonatomic, strong) ZHDotScene *myScene;
@property (weak, nonatomic) IBOutlet UIImageView *textureImageView;
@end

@implementation ZHDotViewController

- (void)viewDidLoad {
    self.skView = [[SKView alloc]initWithFrame:self.view.bounds];
    self.skView.allowsTransparency = YES;
    [self.view addSubview:self.skView];
    self.avqueue = dispatch_queue_create("com.vaporwarewolf.laserdot.camera", NULL);
    
    self.textureImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.textureImageView.alpha = 0.4;
    [self startCamera];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];

}



-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!self.skView.scene) {
        self.skView.showsFPS = YES;
        self.skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        self.myScene = [ZHDotScene sceneWithSize:self.skView.bounds.size];
        self.myScene.scaleMode = SKSceneScaleModeAspectFill;
        self.myScene.backgroundColor = [UIColor clearColor];
        // Present the scene.
        [self.skView presentScene:self.myScene];
    }
}



//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//
//}


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

#pragma mark IBActions
-(void)longPress:(UILongPressGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self.myScene clearAllDots];
    }
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
    [self.view bringSubviewToFront:self.textureImageView];
    
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




#pragma mark AVCaptureVideoDataOutputDelegate


-(void)captureOutput :(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    // Throttle the frame processing.
    // TODO: Throttle by setting the AV output's duration.
    static NSUInteger counter = 0;
    counter++;
    if(counter % 10 == 0){
        NSLog(@"counter: %lu", (unsigned long)counter++);
    } else {
        return;
    }
    
    
    // Get a copy of the buffer that we can work with:
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    
    unsigned char *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    const NSUInteger kBytesPerPixel = 4;
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    
    // TODO: We need to rotate this image about the Z axis for M_PI.
    // Using a transform on the layer works for display but it will create our texture mask backwards.
    
    for(int row = 0; row < height;row++){
        uint8_t *pixel = baseAddress + row * bytesPerRow;
        for(int column = 0;column < width; column++){
//            // Degreen
//            pixel[1] = 0; // De-green (second pixel in BGRA is green)
            
            // Convert to alpya
            if(pixel[0] < 0x50){
//                pixel[0] = 0x00; // b
//                pixel[1] = 0x00; // g
//                pixel[2] = 0xFF; // r
//                pixel[3] = 0xFF; // a
                pixel[0] = 0xFF; // b
                pixel[1] = 0xFF; // g
                pixel[2] = 0xFF; // r
                pixel[3] = 0xFF; // a

            } else {
                pixel[0] = 0;
                pixel[1] = 0;
                pixel[2] = 0;
                pixel[3] = 0;
            }
            pixel += kBytesPerPixel;
        }
    }


    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *textureImage = [UIImage imageWithCGImage:quartzImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textureImageView.image = textureImage;
//        UIImage *i = [self imageWithView:self.textureImageView];
        [self.myScene updateTextureWithImage:textureImage];

    });
    
    CGImageRelease(quartzImage);
    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
}



- (UIImage *) imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
@end
