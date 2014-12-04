//
//  HostViewController.m
//  London Suit
//
//  Created by Parikshit Hedau on 16/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "HostViewController.h"

@interface HostViewController ()

@end

@implementation HostViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    //self.title = @"Select Frame";
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    lblTitle.text = @"Select Frame";
    
    lblTitle.textColor = [UIColor whiteColor];
    
    lblTitle.font = [UIFont boldSystemFontOfSize:22.0];
    
    lblTitle.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = lblTitle;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Do any additional setup after loading the view from its nib.
    
    arrTitles = [[NSArray alloc] init];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnCancel setFrame:CGRectMake(8, 9, 25, 25)];
    
    [btnCancel setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    
    [btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.navigationBar addSubview:btnCancel];
    
    //UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    
    //[barButtonCancel setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    
    //self.navigationItem.leftBarButtonItem = barButtonCancel;
        
    [self loadBannerAd];
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"save_screen_count"];
    i++;
    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"save_screen_count"];
    
    [self loadAdBannerFullScreen];
}

-(void)loadBannerAd{
    
    adBanner.adUnitID = @"ca-app-pub-6136639102894471/6317775942";
    adBanner.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Enable test ads on simulators.
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [adBanner loadRequest:request];
}

-(void)loadAdBannerFullScreen{
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"save_screen_count"];
    
    if (i>=3) {
    
        adBannerFullScreen  = [[GADInterstitial alloc] init];
        adBannerFullScreen.delegate = self;
        adBannerFullScreen.adUnitID = @"ca-app-pub-6136639102894471/7794509143";
        
        GADRequest *request = [GADRequest request];
        // Enable test ads on simulators.
        request.testDevices = @[ GAD_SIMULATOR_ID ];
        [adBannerFullScreen loadRequest:request];
    }
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"save_screen_count"];
    
    if (i>=3) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"save_screen_count"];
        
        [adBannerFullScreen presentFromRootViewController:self];
        
        adBannerFullScreen.delegate = nil;
    }
}

-(IBAction)cancelAction:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self reloadList];
}

-(void)reloadList{
    
    //arrTitles = [[NSArray alloc] initWithObjects:@"Wedding",@"Party",@"Casuals",@"Formal",@"Semi-formal", nil];
    
    arrTitles = [[NSArray alloc] initWithObjects:@"Party", nil];
    
    [self reloadData];
}

#pragma mark - ViewPagerDataSource

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    
    return arrTitles.count;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    
    label.text = [arrTitles objectAtIndex:index];
    
    //label.text = [NSString stringWithFormat:@"Tab #%i", index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:205.0/255.0 green:86.0/255.0 blue:82.0/255.0 alpha:1.0];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    NSLog(@"Index %lu", (unsigned long)index);
    
    SelectFrameViewController  *cvc = [[SelectFrameViewController alloc]initWithNibName:@"SelectFrameViewController" bundle:nil];
        
    cvc.strFrameTitle = [arrTitles objectAtIndex:index];;
    
    /*
     for(int k=0; k<4; k++) {
     if (k == 0) {
     cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"eventsView"];
     } else if(k == 1) {
     cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"announcementView"];
     } else if(k == 2) {
     cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"legalUpdatesView"];
     } else if(k == 3) {
     cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"newsLetterTableView"];
     }
     }
    */
    
    return cvc;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 0.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0 : 96.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor redColor] colorWithAlphaComponent:0.64];
        case ViewPagerTabsView:
            return [[UIColor lightGrayColor] colorWithAlphaComponent:0.32];
        case ViewPagerContent:
            return [[UIColor darkGrayColor] colorWithAlphaComponent:0.32];
        default:
            return color;
    }
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
