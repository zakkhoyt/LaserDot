//
//  MaskViewController.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/30/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "VideoViewController.h"
@import Photos;
@import CoreLocation;
#import "PHAsset+Utility.h"
#import "UIView+RenderToImage.h"
#import "NSTimer+Blocks.h"


//#define VWW_EDGE_DETECTION 1
//#define VWW_MASK 1
#define VWW_IMAGE_OVERLAY 1

@interface VideoViewController ()

@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *filter;
@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (strong, nonatomic) GPUImagePicture *sourcePicture;

@property (strong, nonatomic) GPUImageView *gpuImageView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (nonatomic, strong) PHPhotoLibrary *photos;
@property (nonatomic, strong) NSURL *movieURL;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gpuImageView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [self.view addSubview:self.gpuImageView];
    [self.gpuImageView addSubview:self.recordButton];
    [self.gpuImageView addSubview:self.dateButton];
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;

    [self setupFilters];

    [self.videoCamera startCameraCapture];
    
}

#pragma mark Private methods

-(void)setupFilters{
    
#if defined(VWW_EDGE_DETECTION)
    
    self.filter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    [self.videoCamera addTarget:self.filter];
    
#elif defined(VWW_MASK)
    
    self.filter = [[GPUImageMaskFilter alloc] init];
    [(GPUImageFilter*)self.filter setBackgroundColorRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    [self.videoCamera addTarget:self.filter];
    
    UIImage *inputImage = [UIImage imageNamed:@"mask"];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    [self.sourcePicture processImage];
    [self.sourcePicture addTarget:self.filter];
    
#elif defined(VWW_IMAGE_OVERLAY)
    
    self.filter = [[GPUImageOverlayBlendFilter alloc] init];
    [(GPUImageFilter*)self.filter setBackgroundColorRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    [self.videoCamera addTarget:self.filter];
    
    UIImage *image = [self imageFromLabel];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture processImage];
    [self.sourcePicture addTarget:self.filter];x
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
        [self updateText];
    } repeats:YES];
    
#endif
    
    [self.filter addTarget:self.gpuImageView];
}

// This usually breaks with:
// NSAssert(framebufferReferenceCount > 0, @"Tried to overrelease a framebuffer, did you forget to call -useNextFrameForImageCapture before using -imageFromCurrentFramebuffer?");
-(void)updateText{
    static NSUInteger counter = 1;
    NSLog(@"Counter: %lu", (unsigned long)counter++);

    
    UIImage *image = [self imageFromLabel];
    if(counter == 1){
    [self.filter useNextFrameForImageCapture];
    [self.sourcePicture useNextFrameForImageCapture];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self.sourcePicture processImageWithCompletionHandler:^{
        [self.sourcePicture addTarget:self.filter];
    }];
    
    } else {
        [self.sourcePicture updateCGImage:image.CGImage smoothlyScaleOutput:YES];
        [self.sourcePicture processImageWithCompletionHandler:^{
//            [self.sourcePicture addTarget:self.filter];
        }];
    }
    
}

-(UIImage*)imageFromLabel{
    // Mask
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 400, 300)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 190, 400, 20)];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSDate date].description;
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    return [view imageRepresentation];
}

#pragma mark IBActions

- (IBAction)recordButtonTouchUpInside:(UIButton*)sender {
    if([sender.titleLabel.text isEqualToString:@"Rec"]){
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self startRecording];
    } else {
        [sender setTitle:@"Rec" forState:UIControlStateNormal];
        [self stopRecording];
    }
}

- (IBAction)dateButtonTouchUpInside:(id)sender {
    [self updateText];
}

#pragma mark Recording video to a file

-(void)startRecording{
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(640.0, 480.0)];
    self.movieWriter.encodingLiveVideo = YES;
    [self.filter addTarget:self.movieWriter];
    NSLog(@"Start recording");
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
}

-(void)stopRecording{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [self.filter removeTarget:self.movieWriter];
        self.videoCamera.audioEncodingTarget = nil;
        [self.movieWriter finishRecording];
        NSLog(@"Movie completed");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [PHAsset saveVideoAtURL:self.movieURL location:nil completionBlock:^(PHAsset *asset, BOOL success) {
                if(success){
                    NSLog(@"Success adding video to Photos");
                    [asset saveToAlbum:@"LaserDot" completionBlock:^(BOOL success) {
                        if(success){
                            NSLog(@"Success adding video to App Album");
                        } else {
                            NSLog(@"Error adding video to App Album");
                        }
                    }];
                } else {
                    NSLog(@"Error adding video to Photos");
                }
            }];
        });
    }];
}




@end
