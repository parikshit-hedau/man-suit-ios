//
//  SelectFrameViewController.m
//  London Suit
//
//  Created by Parikshit Hedau on 07/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "SelectFrameViewController.h"

#import "FrameCell.h"

@interface SelectFrameViewController ()

@end

@implementation SelectFrameViewController

@synthesize delegate;

@synthesize strFrameTitle;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    lblTitle.text = @"Select Frame";
    
    lblTitle.textColor = [UIColor whiteColor];
    
    lblTitle.font = [UIFont boldSystemFontOfSize:22.0];
    
    lblTitle.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = lblTitle;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Do any additional setup after loading the view from its nib.
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnCancel setFrame:CGRectMake(8, 9, 25, 25)];
    
    [btnCancel setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    
    [btnCancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchDown];
    
    [self.navigationController.navigationBar addSubview:btnCancel];
    
    [self loadBannerAd];
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"save_screen_count"];
    i++;
    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"save_screen_count"];
    
    [self loadAdBannerFullScreen];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        //collectionViewFrames.frame = CGRectMake(0, 46, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    else{
        
        //collectionViewFrames.frame = CGRectMake(0, 46, 320, 460);
    }
    
    if ([self.strFrameTitle isEqualToString:@"Wedding"]) {
        
        startIndex = 0;
        
        count = 6;
    }
    else if ([self.strFrameTitle isEqualToString:@"Party"]) {
        
        startIndex = 0;
        
        count = 6;
    }
    else if ([self.strFrameTitle isEqualToString:@"Casuals"]) {
        
        startIndex = 0;
        
        count = 10;
    }
    else if ([self.strFrameTitle isEqualToString:@"Formal"]) {
        
        startIndex = 0;
        
        count = 6;
    }
    else{
        
        NSLog(@"Semi formal");
        
        startIndex = 0;
        
        count = 6;
    }
    
    [collectionViewFrames registerNib:[UINib nibWithNibName:@"FrameCell" bundle:nil] forCellWithReuseIdentifier:@"frameCell"];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FrameCell *cell = (FrameCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"frameCell" forIndexPath:indexPath];
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[appDel.arrFrames objectAtIndex:indexPath.row+startIndex]]];
    
    cell.imgViewFrame.image = img;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *tag = [appDel.arrFrames objectAtIndex:indexPath.row+startIndex];
    
    [self.delegate didSelectFrame:tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DIDSELECTFRAME" object:tag];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //[self loadInAppPurchase];
}

-(void)loadInAppPurchase{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Man Sit" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Purchase",@"Restore", nil];
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        
        NSLog(@"cancelled");
    }
    else if (buttonIndex == 0){
        
        NSLog(@"Purchase");
        
        [[InAppRageIAPHelper sharedHelper] buyProductIdentifier:@"com.oceans.demoID"];
    }
    else{
        
        NSLog(@"Restore");
        
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
