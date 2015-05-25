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



@interface ZHDotViewController ()
@property (nonatomic, strong) SKView *skView;
@property (nonatomic, strong) ZHDotScene *dotScene;
@property (weak, nonatomic) IBOutlet UIImageView *textureImageView;
@property (nonatomic) CGFloat alphaThreshold;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UISlider *alphaThresholdSlider;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property dispatch_queue_t avqueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL cameraRunning;
@end

@interface ZHDotViewController (AVFoundation) <AVCaptureVideoDataOutputSampleBufferDelegate>
-(void)toggleCamera;
-(void)startCamera;
@end

@implementation ZHDotViewController

- (void)viewDidLoad {
    self.skView = [[SKView alloc]initWithFrame:self.view.bounds];
    self.skView.allowsTransparency = YES;
    [self.view addSubview:self.skView];
    self.avqueue = dispatch_queue_create("com.vaporwarewolf.laserdot.camera", NULL);
    
    self.textureImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.textureImageView.alpha = 0.4;
    self.alphaThreshold = 0.5;
    [self startCamera];
    
    self.alphaThresholdSlider.value = self.alphaThreshold;
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longPress];

}



-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!self.skView.scene) {
        self.skView.showsFPS = YES;
        self.skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        self.dotScene = [ZHDotScene sceneWithSize:self.skView.bounds.size];
        self.dotScene.scaleMode = SKSceneScaleModeAspectFill;
        self.dotScene.backgroundColor = [UIColor clearColor];
        // Present the scene.
        [self.skView presentScene:self.dotScene];
    }
}


- (BOOL)shouldAutorotate {
    return YES;
}



// TOOD: Update this to transitioncoordinators
- (NSUInteger)supportedInterfaceOrientations {
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
        [self.view bringSubviewToFront:self.settingsView];
    }
}

- (IBAction)alphaThresholdSliderValueChanged:(UISlider*)sender {
    self.alphaThreshold = sender.value;
}
- (IBAction)cameraButtonTouchUpInside:(id)sender {
//    [self toggleCamera];
    [self.dotScene clearAllDots];

}
- (IBAction)closeButtonTouchUpInside:(id)sender {
    [self.view sendSubviewToBack:self.settingsView];
}

@end

@implementation ZHDotViewController (AVFoundation)
#pragma mark AVFoundation stuff


-(void)startCamera{
    if(self.cameraRunning == YES) return;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
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
    
    if([self.session canAddInput:input]){
        [self.session addInput:input];
    } else {
        NSLog(@"Can't add input. Returing");
        return;
    }
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    
    self.videoPreviewLayer.frame = self.skView.bounds;
    
    
    AVCaptureConnection *previewLayerConnection=self.videoPreviewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported]){
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    
    [self.view.layer insertSublayer:self.videoPreviewLayer below:self.skView.layer];
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
    
    if([self.session canAddOutput:videoOutput]){
        [self.session addOutput:videoOutput];
        self.cameraRunning = YES;
        [self.session startRunning];
    }
    else {
        NSLog(@"Could not add videoOutput");
        self.cameraRunning = NO;
    }
}

-(void)stopCamera{
    if(self.cameraRunning == NO) return;
    
    NSLog(@"Stop the camera capturing");
    [self.session stopRunning];
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
    self.session = nil;
    self.cameraRunning = NO;
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
    if(self.session) {
        //Indicate that some changes will be made to the session
        [self.session beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [self.session.inputs objectAtIndex:0];
        [self.session removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [self.session addInput:newVideoInput];
        
        [self.session commitConfiguration];
    }
}




#pragma mark AVCaptureVideoDataOutputDelegate


-(void)captureOutput :(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    // Throttle the frame processing.
    // TODO: Throttle by setting the AV output's duration.
    static NSUInteger counter = 0;
    counter++;
    if(counter % 10 == 0){
//        NSLog(@"counter: %lu", (unsigned long)counter++);
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
                pixel[0] = 0x00 * self.alphaThreshold; // b
                pixel[1] = 0x00 * self.alphaThreshold; // g
                pixel[2] = 0xFF * self.alphaThreshold; // r
                pixel[3] = 0xFF * self.alphaThreshold; // a
//                pixel[0] = 0xFF * self.alphaThreshold; // b
//                pixel[1] = 0xFF * self.alphaThreshold; // g
//                pixel[2] = 0xFF * self.alphaThreshold; // r
//                pixel[3] = 0xFF * self.alphaThreshold; // a

            } else {
                pixel[0] = 0;
                pixel[1] = 0;
                pixel[2] = 0;
                pixel[3] = 0;
            }
            pixel += kBytesPerPixel;
        }
    }


    
    
    // Convert baseAddress (pixel) to a UIImage
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
//        [self.myScene updateTextureWithImage:textureImage];

        [self.dotScene updateTextureWithPixels:baseAddress length:width*height*4];
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
