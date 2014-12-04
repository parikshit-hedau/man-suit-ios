//
//  AppDelegate.h
//  London Suit
//
//  Created by Parikshit Hedau on 06/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

#import "IAPHelper.h"
#import "InAppRageIAPHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,retain) NSMutableArray *arrFrames;

@end

