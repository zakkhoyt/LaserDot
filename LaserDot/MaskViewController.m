//
//  MaskViewController.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/30/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "MaskViewController.h"


@interface MaskViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}
@property (strong, nonatomic) GPUImageView *gpuImageView;

@end

@implementation MaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gpuImageView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.gpuImageView];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
    
    filter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    
    
    [videoCamera addTarget:filter];
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // Record a movie for 10 s and store it in /Documents, visible via iTunes file sharing
    
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
//    movieWriter.encodingLiveVideo = YES;
//    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
//    //    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1080.0, 1920.0)];
//    [filter addTarget:movieWriter];
    [filter addTarget:self.gpuImageView];
    
    [videoCamera startCameraCapture];
    
//    double delayToStartRecording = 0.5;
//    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
//    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
//        NSLog(@"Start recording");
//        
//        videoCamera.audioEncodingTarget = movieWriter;
//        [movieWriter startRecording];
//        
//        //        NSError *error = nil;
//        //        if (![videoCamera.inputCamera lockForConfiguration:&error])
//        //        {
//        //            NSLog(@"Error locking for configuration: %@", error);
//        //        }
//        //        [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
//        //        [videoCamera.inputCamera unlockForConfiguration];
//        
//        double delayInSeconds = 10.0;
//        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
//            
//            [filter removeTarget:movieWriter];
//            videoCamera.audioEncodingTarget = nil;
//            [movieWriter finishRecording];
//            NSLog(@"Movie completed");
//            
//            //            [videoCamera.inputCamera lockForConfiguration:nil];
//            //            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
//            //            [videoCamera.inputCamera unlockForConfiguration];
//        });
//    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
