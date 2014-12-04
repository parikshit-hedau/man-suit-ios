//
//  HomeViewController.h
//  London Suit
//
//  Created by Parikshit Hedau on 06/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import <iAd/iAd.h>

#import <CoreImage/CoreImage.h>

#import "SelectFrameViewController.h"

#import "AppDelegate.h"

#import "HostViewController.h"

@interface HomeViewController : UIViewController <SelectFrameDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,ADBannerViewDelegate>
{
    AVCaptureSession *session;
    AVCaptureStillImageOutput *outputBack;
    AVCaptureDeviceInput *inputBack;
    
    IBOutlet UIView *viewCamera,*viewTopMenu,*viewBottomeMenu,*viewSelectedPhoto;
    
    IBOutlet UIImageView *imgViewCaptured;
    
    IBOutlet UIButton *btnCapture;
    
    IBOutlet UISlider *sliderBrightness;
    
    UIImageView *imgViewOverlay;
    
    UIImage *imgOverlay;
    
    AppDelegate *appDel;
    
    BOOL isAnimating;
    
    UIImage *imgCaputured;
    
    AVCaptureConnection *connectionVideo;
    
    AVCaptureStillImageOutput *stillImageOutput;
    
    IBOutlet ADBannerView *adBanner;
    
    float lastScale,lastRotation,firstX,firstY;
    
    UIPinchGestureRecognizer *pinchRecognizer;
    UIRotationGestureRecognizer *rotationRecognizer;
    UIPanGestureRecognizer *panRecognizer;
}

-(IBAction)sliderValueChangedEvent:(id)sender;

-(IBAction)capturePhotoAction:(id)sender;

-(IBAction)changeCamereDeviceAction:(id)sender;

-(IBAction)selectFramesAction:(id)sender;

-(IBAction)leftSwipeAction:(id)sender;

-(IBAction)rightSwipeAction:(id)sender;

-(IBAction)selectPhotoFromLibrary:(id)sender;

-(IBAction)photoAction:(id)sender;

-(IBAction)rateAction:(id)sender;

-(IBAction)saveAction:(id)sender;

@end
