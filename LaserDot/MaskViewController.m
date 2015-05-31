//
//  MaskViewController.m
//  LaserDot
//
//  Created by Zakk Hoyt on 5/30/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "MaskViewController.h"
@import Photos;
#import "PHAsset+Utility.h"



@interface MaskViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}
@property (strong, nonatomic) GPUImageView *gpuImageView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) PHPhotoLibrary *photos;
@property (nonatomic, strong) NSURL *movieURL;
@end

@implementation MaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.gpuImageView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.gpuImageView];
    [self.gpuImageView addSubview:self.recordButton];
    
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
    
    filter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    
    
    [videoCamera addTarget:filter];
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [filter addTarget:self.gpuImageView];
    
    [videoCamera startCameraCapture];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)startRecording{
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(640.0, 480.0)];
    movieWriter.encodingLiveVideo = YES;
    [filter addTarget:movieWriter];

    
    
    NSLog(@"Start recording");
    
    videoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];
    
    //        NSError *error = nil;
    //        if (![videoCamera.inputCamera lockForConfiguration:&error])
    //        {
    //            NSLog(@"Error locking for configuration: %@", error);
    //        }
    //        [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
    //        [videoCamera.inputCamera unlockForConfiguration];
    
//    double delayInSeconds = 10.0;
//    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
//        
//        
//        //            [videoCamera.inputCamera lockForConfiguration:nil];
//        //            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
//        //            [videoCamera.inputCamera unlockForConfiguration];
//    });
}

-(void)stopRecording{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [filter removeTarget:movieWriter];
        videoCamera.audioEncodingTarget = nil;
        [movieWriter finishRecording];
        NSLog(@"Movie completed");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [PHAsset saveVideoAtURL:self.movieURL location:nil completionBlock:^(PHAsset *asset, BOOL success) {
                if(success){
                    NSLog(@"Success");
                } else {
                    NSLog(@"Error");
                }
            }];
        });
    }];

}

- (IBAction)recordButtonTouchUpInside:(UIButton*)sender {
    if([sender.titleLabel.text isEqualToString:@"Rec"]){
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self startRecording];
    } else {
        [sender setTitle:@"Rec" forState:UIControlStateNormal];
        [self stopRecording];
    }
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
