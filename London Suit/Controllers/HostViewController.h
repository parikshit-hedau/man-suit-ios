//
//  HostViewController.h
//  London Suit
//
//  Created by Parikshit Hedau on 16/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "ViewPagerController.h"
#import "SelectFrameViewController.h"
#import "GADBannerView.h"

#import "GADInterstitial.h"

@interface HostViewController : ViewPagerController <ViewPagerDataSource, ViewPagerDelegate,GADInterstitialDelegate>
{
    NSArray *arrTitles;
    IBOutlet GADBannerView *adBanner;
    
    GADInterstitial *adBannerFullScreen;
}

@end
