//
//  SelectFrameViewController.h
//  London Suit
//
//  Created by Parikshit Hedau on 07/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "GADBannerView.h"

#import "GADInterstitial.h"


@protocol SelectFrameDelegate <NSObject>

-(void)didSelectFrame:(NSString*)tag;

@end

@interface SelectFrameViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UIActionSheetDelegate,GADInterstitialDelegate>
{
    IBOutlet UICollectionView *collectionViewFrames;
    
    IBOutlet UIScrollView *scrViewTitles;
    
    IBOutlet GADBannerView *adBanner;
    
    GADInterstitial *adBannerFullScreen;
    
    AppDelegate *appDel;
    
    int startIndex,count;
    
    IAPHelper *inAppPurchase;
}

@property (nonatomic,retain) id<SelectFrameDelegate> delegate;

@property (nonatomic,retain) NSString *strFrameTitle;

-(IBAction)cancelAction:(id)sender;

@end
