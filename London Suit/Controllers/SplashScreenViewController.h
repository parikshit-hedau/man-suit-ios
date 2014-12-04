//
//  SplashScreenViewController.h
//  London Suit
//
//  Created by Parikshit Hedau on 08/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashScreenViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *web_View;
    
    IBOutlet UIImageView *imgView;
}
@end
