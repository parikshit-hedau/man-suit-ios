//
//  PhotoEditingViewController.m
//  London Suit
//
//  Created by Parikshit Hedau on 08/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

/*
man suit ios:
banner: ca-app-pub-6136639102894471/6317775942
interstitial: ca-app-pub-6136639102894471/7794509143
*/

#import "PhotoEditingViewController.h"

@interface PhotoEditingViewController ()

@end

@implementation PhotoEditingViewController

@synthesize imgSelected,strSelectedFrameTag;

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
       
    imgView.image = self.imgSelected;
    
    //imgView.frame = CGRectMake(0, 0, self.imgSelected.size.width, self.imgSelected.size.height);
    
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//    [viewEditing addGestureRecognizer:pinchRecognizer];
//    
//    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
//    [viewEditing addGestureRecognizer:rotationRecognizer];
//
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//    [panRecognizer setMinimumNumberOfTouches:1];
//    [panRecognizer setMaximumNumberOfTouches:1];
//    [viewEditing addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    imgViewOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 200, 320, 200)];
    
    NSString *tag = [appDel.arrFrames objectAtIndex:0];
    
    if (self.strSelectedFrameTag) {
        
        tag = self.strSelectedFrameTag;
    }
    
    imgViewOverlay.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpeg",tag]];
    
    imgViewOverlay.tag = [tag intValue];
    
    [self.view addSubview:imgViewOverlay];
    
    imgViewOverlay.hidden = YES;
    
    //[imgViewOverlay setContentMode:UIViewContentModeScaleAspectFit];
    
    //imgViewOverlay.hidden = YES;
    
    //imgViewOverlay.image = [UIImage imageNamed:@"suit.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectFrameWithTag:) name:@"DIDSELECTFRAME" object:nil];
    
    [self loadBannerAd];
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"frame_click_count"];
    i++;
    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"frame_click_count"];
    
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
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"frame_click_count"];
    
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
    
    int i = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"frame_click_count"];
    
    if (i>=3) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"frame_click_count"];
        
        [adBannerFullScreen presentFromRootViewController:self];
        
        adBannerFullScreen.delegate = nil;
    }
}

#pragma mark -

-(void)didSelectFrameWithTag:(NSNotification*)notification{
    
    [self didSelectFrame:notification.object];
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSLog(@"viewEditing frame = %@",NSStringFromCGRect(viewEditing.frame));
    
    NSLog(@"imgView frame = %@",NSStringFromCGRect(imgView.frame));
}

-(IBAction)backAction:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tapAction{
    
    if (!viewMenuUpper.tag) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            viewMenuUpper.alpha = 0.0;
            viewMenuBottom.alpha = 0.0;
            adBanner.frame = CGRectMake(adBanner.frame.origin.x, [UIScreen mainScreen].bounds.size.height - adBanner.frame.size.height, adBanner.frame.size.width, adBanner.frame.size.height);
        }];
        
        viewMenuUpper.tag = 1;
    }
    else{
        
        [UIView animateWithDuration:0.2 animations:^{
            
            viewMenuUpper.alpha = 1.0;
            viewMenuBottom.alpha = 1.0;
            adBanner.frame = CGRectMake(adBanner.frame.origin.x, [UIScreen mainScreen].bounds.size.height - adBanner.frame.size.height - viewMenuBottom.frame.size.height, adBanner.frame.size.width, adBanner.frame.size.height);
        }];
        
        viewMenuUpper.tag = 0;
    }
}

-(IBAction)saveAction:(id)sender{
    
    UIImage *img = self.imgSelected;
    
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    //[[[UIAlertView alloc] initWithTitle:@"Man Suit" message:@"Save to?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Library",@"Device", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        
        return;
    }
    else if (buttonIndex == 1){
        
        UIImage *img = self.imgSelected;
        
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    else{
        
        UIImage *img = self.imgSelected;
        
        NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
        
        NSString *strDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = @"";
        
        NSMutableArray *arrSavedPhotos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"savedPhotos"] mutableCopy];
        
        if (arrSavedPhotos.count) {
            
            filePath = [strDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.jpg",(unsigned long)arrSavedPhotos.count]];
            
            [imgData writeToFile:filePath atomically:NO];
        }
        else{
            
            arrSavedPhotos = [[NSMutableArray alloc] init];
            
            filePath = [strDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.jpg",(unsigned long)arrSavedPhotos.count]];
            
            [imgData writeToFile:filePath atomically:NO];
        }
        
        [arrSavedPhotos addObject:filePath];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrSavedPhotos forKey:@"savedPhotos"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[[UIAlertView alloc] initWithTitle:@"Man Suit" message:@"Photo saved to document directory" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"error= %@",error);
    
    [[[UIAlertView alloc] initWithTitle:@"Man Suit" message:@"Photo is saved into library" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)showSuccessAlert{
    
    [[[UIAlertView alloc] initWithTitle:@"Man Suit" message:@"Photo saved to library" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}

-(UIImage *)getImageFromContext{
    
    UIImage *imgFrame = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpeg",(int)imgViewOverlay.tag]];
    
    CGSize size = CGSizeMake(viewEditing.frame.size.width, viewEditing.frame.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [viewEditing.layer renderInContext:context];
    
    UIGraphicsPushContext(context);
    
    [imgFrame drawInRect:CGRectMake(0, viewEditing.frame.size.height-200, 320, 200)];
    
    UIGraphicsPopContext();
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

-(IBAction)resetAction:(id)sender{
    
    imgView.transform = viewEditing.transform;
    
    imgView.frame = viewEditing.bounds;
}

-(IBAction)selectFrameAction:(id)sender{
    
    HostViewController *selectFrameViewController = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:selectFrameViewController];
    
    nav.navigationBar.barTintColor = [UIColor colorWithRed:198.0/255.0 green:156.0/255.0 blue:109.0/255.0 alpha:0.5];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)didSelectFrame:(NSString*)tag{
    
    int frameTag = [tag intValue];
    
    imgViewOverlay.tag = frameTag;
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpeg",tag]];
    
    imgViewOverlay.image = img;
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
    
    [self resetAction:nil];
    
    self.imgSelected = img;
    
    imgView.image = self.imgSelected;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)shareAction:(id)sender{
    
    NSLog(@"Share");
    
    UIImage *img = self.imgSelected;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Hello World", img] applicationActivities:nil];
    
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        
        [popController presentPopoverFromRect:CGRectMake(self.view.center.x, self.view.center.y,0,0) inView:self.view permittedArrowDirections:(UIPopoverArrowDirectionDown) animated:YES];
    }
    else{
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = imgView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [imgView setTransform:newTransform];
    
    lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = imgView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [imgView setTransform:newTransform];
    
    lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:viewEditing];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [imgView center].x;
        firstY = [imgView center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [imgView setCenter:translatedPoint];
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
