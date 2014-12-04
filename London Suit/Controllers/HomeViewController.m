//
//  HomeViewController.m
//  London Suit
//
//  Created by Parikshit Hedau on 06/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "HomeViewController.h"

#import "PhotoEditingViewController.h"

#import "SavedPhotoViewController.h"

#define SCALE_RATIO 2

@interface HomeViewController ()

@end

@implementation HomeViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

-(AVCaptureDevice *) frontFacingCameraIfAvailable{
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *captureDevice = nil;
    
    for (AVCaptureDevice *device in videoDevices){
        
        if (device.position == AVCaptureDevicePositionBack){
            
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if (!captureDevice){
        
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ///*
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    CGRect bounds=viewCamera.layer.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.bounds=bounds;
    captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [captureVideoPreviewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [captureVideoPreviewLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    AVCaptureConnection *previewLayerConnection=captureVideoPreviewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported])
    {
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [viewCamera.layer addSublayer:captureVideoPreviewLayer];
    
    NSError *error = nil;
    AVCaptureDevice *device = [self frontFacingCameraIfAvailable];
    inputBack = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!inputBack) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    
    [session addInput:inputBack];
    
    AVCaptureInput *inputPorts = [session.inputs objectAtIndex:0]; // maybe search the input in array
    AVCaptureInputPort *port = [inputPorts.ports objectAtIndex:0];
    CMFormatDescriptionRef formatDescription = port.formatDescription;
    
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    
    NSLog(@"camera width=%d, height=%d",dimensions.width,dimensions.height);
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    [session startRunning];
    
    //*/
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [viewCamera addGestureRecognizer:tapRecognizer];
    
    imgViewOverlay = [[UIImageView alloc] init];
    
    NSString *tag = [appDel.arrFrames objectAtIndex:0];
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",tag]];
    
    img = [self resizeImage:img resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.height*2)];
    
    NSLog(@"resize image frame : %@",NSStringFromCGSize(img.size));
    
    imgViewOverlay.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-img.size.height/SCALE_RATIO, [UIScreen mainScreen].bounds.size.width, img.size.height/SCALE_RATIO);
    
    imgViewOverlay.image = img;
    
    imgViewOverlay.tag = [tag intValue];
    
    imgViewOverlay.contentMode = UIViewContentModeScaleAspectFit;
    
    imgOverlay = img;
    
    [self.view addSubview:imgViewOverlay];
    
    [self.view bringSubviewToFront:viewBottomeMenu];
    
    [self.view bringSubviewToFront:viewTopMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectFrameWithTag:) name:@"DIDSELECTFRAME" object:nil];
    
    adBanner.delegate = self;
    
    adBanner.hidden = YES;
    
    viewSelectedPhoto.hidden = YES;
    
    sliderBrightness.hidden = YES;
}

-(IBAction)sliderValueChangedEvent:(id)sender{
    
    UISlider *slider = (UISlider*)sender;
    
    UIImage *img = [self filteredImage:imgOverlay withValue:slider.value];
    
    imgViewOverlay.image = img;
}

-(void)addGesturesInView{
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [viewSelectedPhoto addGestureRecognizer:pinchRecognizer];
    
    rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [viewSelectedPhoto addGestureRecognizer:rotationRecognizer];
    
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [viewSelectedPhoto addGestureRecognizer:panRecognizer];
}

-(void)removeGesturesFromView{
    
    [self.view removeGestureRecognizer:pinchRecognizer];
    [self.view removeGestureRecognizer:rotationRecognizer];
    [self.view removeGestureRecognizer:panRecognizer];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"frame=%@",NSStringFromCGRect(imgViewOverlay.frame));
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
    [self.view bringSubviewToFront:adBanner];
    
    //adBanner.hidden = NO;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
    adBanner.hidden = YES;
}

-(void)didSelectFrameWithTag:(NSNotification*)notification{
    
    [self didSelectFrame:notification.object];
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSLog(@"preview frame = %@",NSStringFromCGRect(viewCamera.frame));
}

-(void)tapAction{
    
    if (!viewTopMenu.tag) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            viewTopMenu.alpha = 0.0;
            
            viewBottomeMenu.alpha = 0.0;
        }];
        
        viewTopMenu.tag = 1;
    }
    else{
        
        [UIView animateWithDuration:0.2 animations:^{
            
            viewTopMenu.alpha = 1.0;
            
            viewBottomeMenu.alpha = 1.0;
        }];
        
        viewTopMenu.tag = 0;
    }
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = imgViewCaptured.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [imgViewCaptured setTransform:newTransform];
    
    lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = imgViewCaptured.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [imgViewCaptured setTransform:newTransform];
    
    lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:viewCamera];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [imgViewCaptured center].x;
        firstY = [imgViewCaptured center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [imgViewCaptured setCenter:translatedPoint];
}

-(IBAction)leftSwipeAction:(id)sender{
    
    if (isAnimating) {
        
        return;
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewOverlay.frame.size.width, imgViewOverlay.frame.origin.y, imgViewOverlay.frame.size.width, imgViewOverlay.frame.size.height)];
    
    imgView.tag = imgViewOverlay.tag + 1;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",(int)imgViewOverlay.tag+1]];
    
    if (![appDel.arrFrames containsObject:[NSString stringWithFormat:@"%d",(int)imgView.tag]]) {
        
        imgView.tag = 0;
        
        img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",(int)imgView.tag]];
    }
    
    img = [self resizeImage:img resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.height*2)];
    
    NSLog(@"resize image frame : %@",NSStringFromCGSize(img.size));
    
    imgView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-img.size.height/SCALE_RATIO, [UIScreen mainScreen].bounds.size.width, img.size.height/SCALE_RATIO);
    
    imgView.image = img;
    
    imgView.alpha = 0.0;
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    imgOverlay = img;
    
    [self.view addSubview:imgView];
    
    isAnimating = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        imgViewOverlay.frame = CGRectMake(-imgViewOverlay.frame.size.width, imgViewOverlay.frame.origin.y, imgViewOverlay.frame.size.width, imgViewOverlay.frame.size.height);
        
        imgViewOverlay.alpha = 0.0;
        
        imgView.frame = CGRectMake(0, imgView.frame.origin.y, imgView.frame.size.width, imgView.frame.size.height);
        
        imgView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [imgViewOverlay removeFromSuperview];
        
        imgViewOverlay = imgView;
        
        isAnimating = NO;
    }];
    
    [self.view bringSubviewToFront:adBanner];
    
    [self.view bringSubviewToFront:viewBottomeMenu];
}

-(IBAction)rightSwipeAction:(id)sender{
    
    if (isAnimating) {
        
        return;
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewOverlay.frame.origin.x-320, imgViewOverlay.frame.origin.y, imgViewOverlay.frame.size.width, imgViewOverlay.frame.size.height)];
    
    imgView.tag = imgViewOverlay.tag - 1;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",(int)imgViewOverlay.tag-1]];
    
    if (![appDel.arrFrames containsObject:[NSString stringWithFormat:@"%ld",(long)imgView.tag]]) {
        
        imgView.tag = appDel.arrFrames.count - 1;
        
        img = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",(long)imgView.tag]];
    }
    
    img = [self resizeImage:img resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.height*2)];
    
    NSLog(@"resize image frame : %@",NSStringFromCGSize(img.size));
    
    imgView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-img.size.height/SCALE_RATIO, [UIScreen mainScreen].bounds.size.width, img.size.height/SCALE_RATIO);
    
    imgView.image = img;
    
    imgView.alpha = 0.0;
    
    imgOverlay = img;
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:imgView];
    
    isAnimating = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        imgViewOverlay.frame = CGRectMake(imgViewOverlay.frame.size.width, imgViewOverlay.frame.origin.y, imgViewOverlay.frame.size.width, imgViewOverlay.frame.size.height);
        
        imgViewOverlay.alpha = 0.0;
        
        imgView.frame = CGRectMake(0, imgView.frame.origin.y, imgView.frame.size.width, imgView.frame.size.height);
        
        imgView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        [imgViewOverlay removeFromSuperview];
        
        imgViewOverlay = imgView;
        
        isAnimating = NO;
    }];
    
    [self.view bringSubviewToFront:adBanner];
    
    [self.view bringSubviewToFront:viewBottomeMenu];
}

-(IBAction)selectPhotoFromLibrary:(id)sender{
    
    UIImagePickerController *imagePickr = [[UIImagePickerController alloc] init];
    
    imagePickr.delegate = self;
    
    imagePickr.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePickr.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
    
    [self presentViewController:imagePickr animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"info =%@",info);
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    imgCaputured = img;
    
    imgViewCaptured.image = imgCaputured;
    
    imgViewCaptured.hidden = NO;
    
    viewSelectedPhoto.hidden = NO;
    
    sliderBrightness.hidden = NO;
    
    sliderBrightness.value = 0.0;
    
    btnCapture.tag = 1;
    
    [btnCapture setImage:[UIImage imageNamed:@"capture2_btn"] forState:UIControlStateNormal];
    
    [self resetAction];
    
    [self addGesturesInView];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)selectFramesAction:(id)sender{
    
    //HostViewController *selectFrameViewController = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
    
    SelectFrameViewController *selectFrameViewController = [[SelectFrameViewController alloc] initWithNibName:@"SelectFrameViewController" bundle:nil];
    
    selectFrameViewController.strFrameTitle = @"Casuals";
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectFrameViewController];
    
    nav.navigationBar.barTintColor = [UIColor colorWithRed:198.0/255.0 green:156.0/255.0 blue:109.0/255.0 alpha:0.5];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)didSelectFrame:(NSString*)tag{
    
    int frameTag = [tag intValue];
    
    imgViewOverlay.tag = frameTag;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",tag]];
    
    img = [self resizeImage:img resizeSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.height*2)];
    
    NSLog(@"resize image frame : %@",NSStringFromCGSize(img.size));
    
    imgViewOverlay.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-img.size.height/SCALE_RATIO, [UIScreen mainScreen].bounds.size.width, img.size.height/SCALE_RATIO);
    
    imgViewOverlay.image = img;
}

-(IBAction)photoAction:(id)sender{
    
    SavedPhotoViewController *savedPhotoViewController = [[SavedPhotoViewController alloc] initWithNibName:@"SavedPhotoViewController" bundle:nil];
    
    [self.navigationController pushViewController:savedPhotoViewController animated:YES];
}

-(IBAction)capturePhotoAction:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    
    [self removeGesturesFromView];
    
    [self resetAction];
    
    if (btn.tag == 0) {
        
        btn.tag = 1;
        
        [btn setImage:[UIImage imageNamed:@"capture2_btn"] forState:UIControlStateNormal];
        
        [self takePicture];
    }
    else{
        
        btn.tag = 0;
        
        [btn setImage:[UIImage imageNamed:@"capture1_btn"] forState:UIControlStateNormal];
        
        imgCaputured = nil;
        
        imgViewCaptured.hidden = YES;
        
        viewSelectedPhoto.hidden = YES;
        
        sliderBrightness.hidden = YES;
    }
}

-(IBAction)changeCamereDeviceAction:(id)sender{
    
    [self toggleCamera];
}

- (void)toggleCamera {
    
    AVCaptureDevicePosition newPosition = inputBack.device.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    NSArray *devices=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *device = nil;
    
    if (devices.count > 1) {
        
        if (newPosition == AVCaptureDevicePositionBack) {
            
            device = [devices objectAtIndex:0];
        }
        else{
            
            if (devices.count > 1) {
                
                device = [devices objectAtIndex:1];
            }
            else{
                
                device = [devices objectAtIndex:0];
            }
        }
        
        [session beginConfiguration];
        [session removeInput:inputBack];
        [session setSessionPreset:AVCaptureSessionPresetPhoto]; //Always reset preset before testing canAddInput because preset will cause it to return NO
        
        inputBack = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        if ([session canAddInput:inputBack]) {
            [session addInput:inputBack];
        } else {
            [session addInput:inputBack];
        }
        
        if ([device lockForConfiguration:nil]) {
            [device setSubjectAreaChangeMonitoringEnabled:YES];
            [device unlockForConfiguration];
        }
        
        [session commitConfiguration];
    }
}

-(void)takePicture
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *__strong error) {
                                                      // Do something with the captured image
                                                      
                                                      NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                      
                                                      UIImage *imageTaken = [[UIImage alloc] initWithData:imageData];
                                                      
                                                      if(inputBack.device.position == AVCaptureDevicePositionFront){
                                                          
                                                          CGSize imageSize = imageTaken.size;
                                                          UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
                                                          CGContextRef ctx = UIGraphicsGetCurrentContext();
                                                          CGContextRotateCTM(ctx, M_PI/2);
                                                          CGContextTranslateCTM(ctx, 0, -imageSize.width);
                                                          CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
                                                          CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageTaken.CGImage);
                                                          imageTaken = UIGraphicsGetImageFromCurrentImageContext();
                                                          UIGraphicsEndImageContext();
                                                      }
                                                      
                                                      imgCaputured = imageTaken;
                                                      
                                                      NSLog(@"image size width = %f, height = %f",imageTaken.size.width,imageTaken.size.height);
                                                      
                                                      int deviceHeight = [UIScreen mainScreen].bounds.size.height;
                                                      
                                                      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                                          
                                                          NSLog(@"ipad");
                                                          
//                                                          imageTaken = [self resizeImage:imageTaken resizeSize:CGSizeMake(imageTaken.size.width /2, imageTaken.size.height /2)];
//                                                          
//                                                          CGRect rectToCrop = CGRectMake(40, 0, (imageTaken.size.width)-80, (imageTaken.size.height)-98*2);
//                                                          
//                                                          CGImageRef cropped_img = CGImageCreateWithImageInRect(imageTaken.CGImage, rectToCrop);
//                                                          
//                                                          imageTaken = [UIImage imageWithCGImage:cropped_img];
                                                      }
                                                      else{
                                                          
                                                          NSLog(@"iphone");
                                                          
                                                          if (deviceHeight == 480)
                                                          {
                                                              if(inputBack.device.position == AVCaptureDevicePositionBack){
                                                                  
                                                                  //for Phone4 cropping rear camera
                                                                  
                                                                  imageTaken = [self resizeImage:imageTaken resizeSize:CGSizeMake(imageTaken.size.width /2, imageTaken.size.height /2)];
                                                                  
                                                                  CGRect rectToCrop = CGRectMake(40, 0, (imageTaken.size.width)-80, (imageTaken.size.height)-98*2);
                                                                  
                                                                  CGImageRef cropped_img = CGImageCreateWithImageInRect(imageTaken.CGImage, rectToCrop);
                                                                  
                                                                  imageTaken = [UIImage imageWithCGImage:cropped_img];
                                                                  
                                                              }else{
                                                                  
                                                                  //for Phone4 cropping front camera
                                                                  
                                                                  CGRect rectToCrop = CGRectMake(0, 0, (imageTaken.size.width), (imageTaken.size.height)-98);
                                                                  
                                                                  CGImageRef cropped_img = CGImageCreateWithImageInRect(imageTaken.CGImage, rectToCrop);
                                                                  
                                                                  imageTaken = [UIImage imageWithCGImage:cropped_img];
                                                              }
                                                          }
                                                          else if (deviceHeight == 568){
                                                              
                                                              if(inputBack.device.position == AVCaptureDevicePositionBack ){
                                                                  
                                                                  //for Phone4 cropping rear camera
                                                                  /*
                                                                   imageTaken = [self resizeImavge:imageTaken resizeSize:CGSizeMake(imageTaken.size.width /2, imageTaken.size.height /2)];
                                                                   
                                                                   CGRect rectToCrop = CGRectMake(40, 0, (imageTaken.size.width/ 2)-80, (imageTaken.size.height/2)-98*2);
                                                                   
                                                                   CGImageRef cropped_img = CGImageCreateWithImageInRect(imageTaken.CGImage, rectToCrop);
                                                                   
                                                                   imageTaken = [UIImage imageWithCGImage:cropped_img];
                                                                   */
                                                              }else{
                                                                  
                                                                  //for Phone4 cropping front camera
                                                                  /*
                                                                   CGRect rectToCrop = CGRectMake(0, 0, (imageTaken.size.width), (imageTaken.size.height)-98);
                                                                   
                                                                   CGImageRef cropped_img = CGImageCreateWithImageInRect(imageTaken.CGImage, rectToCrop);
                                                                   
                                                                   imageTaken = [UIImage imageWithCGImage:cropped_img];
                                                                   */
                                                              }
                                                          }
                                                          else if (deviceHeight == 700){
                                                              
                                                              dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                                                              
                                                              dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                                                              
                                                              dispatch_semaphore_signal(sema);
                                                          }
                                                          else{
                                                              
                                                          }
                                                      }
                                                      
                                                      NSLog(@"image size width = %f, height = %f",imageTaken.size.width,imageTaken.size.height);
                                                      
                                                      imgCaputured = imageTaken;
                                                      
                                                      imgViewCaptured.hidden = NO;
                                                      
                                                      viewSelectedPhoto.hidden = NO;
                                                      
                                                      sliderBrightness.hidden = NO;
                                                      
                                                      sliderBrightness.value = 0.0;
                                                      
                                                      imgViewCaptured.image = imgCaputured;
                                                  }];
}

-(IBAction)rateAction:(id)sender{
    
    
}

-(IBAction)saveAction:(id)sender{
    
    if (imgCaputured) {
        
        UIImage *img = [self getImageFromContext];
        
        PhotoEditingViewController *photoEditingViewController = [[PhotoEditingViewController alloc] initWithNibName:@"PhotoEditingViewController" bundle:nil];
        
        photoEditingViewController.imgSelected = img;
        
        photoEditingViewController.strSelectedFrameTag = [NSString stringWithFormat:@"%ld",(long)imgViewOverlay.tag];
        
        [self.navigationController pushViewController:photoEditingViewController animated:YES];
    }
    else{
        
        [[[UIAlertView alloc] initWithTitle:@"Man Suit" message:@"Please capture photo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)resetAction{
    
    imgViewCaptured.transform = viewSelectedPhoto.transform;
    
    imgViewCaptured.frame = viewSelectedPhoto.bounds;
}

-(UIImage *)getImageFromContext{
    
    UIImageView *imgview1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, viewSelectedPhoto.frame.size.height-imgOverlay.size.height/SCALE_RATIO, viewSelectedPhoto.frame.size.width, imgOverlay.size.height/SCALE_RATIO)];
    
    imgview1.image = imgViewOverlay.image;
    
    imgview1.contentMode = UIViewContentModeScaleAspectFit;
    
    [viewSelectedPhoto addSubview:imgview1];
    
    UIImage *imgFrame = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpeg",(int)imgViewOverlay.tag]];
    
    imgFrame = imgOverlay;
    
    //CGSize size = CGSizeMake(viewSelectedPhoto.frame.size.width, viewSelectedPhoto.frame.size.height);
    
    CGSize size = CGSizeMake(viewSelectedPhoto.frame.size.width, viewSelectedPhoto.frame.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [viewSelectedPhoto.layer renderInContext:context];
    
    //UIGraphicsPushContext(context);
    
    //[imgFrame drawInRect:CGRectMake(0, viewSelectedPhoto.frame.size.height-200, 320, 200)];
    
    //UIGraphicsPopContext();
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [imgview1 removeFromSuperview];
    
    return img;
}

-(UIImage *) resizeImage:(UIImage *)orginalImage resizeSize:(CGSize)size
{
    CGFloat actualHeight = orginalImage.size.height;
    CGFloat actualWidth = orginalImage.size.width;
    //  if(actualWidth <= size.width && actualHeight<=size.height)
    //  {
    //      return orginalImage;
    //  }
    float oldRatio = actualWidth/actualHeight;
    float newRatio = size.width/size.height;
    if(oldRatio < newRatio)
    {
        oldRatio = size.height/actualHeight;
        actualWidth = oldRatio * actualWidth;
        actualHeight = size.height;
    }
    else
    {
        oldRatio = size.width/actualWidth;
        actualHeight = oldRatio * actualHeight;
        actualWidth = size.width;
    }
    
    CGRect rect = CGRectMake(0.0,0.0,actualWidth,actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [orginalImage drawInRect:rect];
    orginalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return orginalImage;
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CIImage *)changeLuminosityOfCIImage:(CIImage *)inputImage luminosity:(CGFloat)luminosity
{
    CIFilter *exposureAdjustmentFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [exposureAdjustmentFilter setDefaults];
    [exposureAdjustmentFilter setValue:inputImage forKey:@"inputImage"];
    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputEV"];
    CIImage *outputImage = [exposureAdjustmentFilter valueForKey:@"outputImage"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    UIImage *img = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
    
    return img.CIImage;
}

- (UIImage*)filteredImage:(UIImage*)image withValue:(float)value
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    
    CGFloat brightness = 2*value;
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputEV"];
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

- (UIImage*)filteredImageContrast:(UIImage*)image withValue:(float)value
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrast   = value*value;
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputPower"];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
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
