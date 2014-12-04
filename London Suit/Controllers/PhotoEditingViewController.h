//
//  PhotoEditingViewController.h
//  London Suit
//
//  Created by Parikshit Hedau on 08/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SelectFrameViewController.h"
#import "HostViewController.h"

#import "GADBannerView.h"

#import "GADInterstitial.h"

@interface PhotoEditingViewController : UIViewController <SelectFrameDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,GADInterstitialDelegate>
{
    IBOutlet UIImageView *imgView;
    
    IBOutlet UIView *viewEditing,*viewMenuUpper,*viewMenuBottom;
    
    IBOutlet GADBannerView *adBanner;
    
    GADInterstitial *adBannerFullScreen;
    
    float lastScale,lastRotation,firstX,firstY;
    
    UIImageView *imgViewOverlay;
    
    AppDelegate *appDel;
}

@property (nonatomic,retain) UIImage *imgSelected;

@property (nonatomic,retain) NSString *strSelectedFrameTag;

-(IBAction)backAction:(id)sender;

-(IBAction)saveAction:(id)sender;

-(IBAction)resetAction:(id)sender;

-(IBAction)selectFrameAction:(id)sender;

-(IBAction)selectPhotoFromLibrary:(id)sender;

-(IBAction)shareAction:(id)sender;

@end
