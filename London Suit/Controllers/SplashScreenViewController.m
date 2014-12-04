//
//  SplashScreenViewController.m
//  London Suit
//
//  Created by Parikshit Hedau on 08/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "SplashScreenViewController.h"

#import "HomeViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loader" ofType:@"gif"];
//    
//    NSData *dataImg = [NSData dataWithContentsOfFile:filePath];
//    
//    [webView loadData:dataImg MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    
    
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    
//    NSString *htmlString = @"<html><body><img src=\"file://%@\"></body></html>";
//    
//    [webView loadHTMLString:htmlString baseURL:baseURL];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if ([UIScreen mainScreen].bounds.size.height == 568) {
            
            NSLog(@"iphone5");
            
            imgView.image = [UIImage imageNamed:@"640x1136"];
        }
        else{
            
            NSLog(@"iphone4");
            
            imgView.image = [UIImage imageNamed:@"640x960"];
        }
    }
    else{
        
        NSLog(@"ipad");
        
        imgView.image = [UIImage imageNamed:@"1536x2048"];
    }
    
    imgView.frame = [UIScreen mainScreen].bounds;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loader" ofType:@"gif"];
    
    [web_View loadHTMLString:[NSString stringWithFormat:@"<html><body><img src=\"file://%@\" width=220px height=19px ></body></html>",path] baseURL:nil];
    
    web_View.delegate = self;
    
    web_View.opaque = NO;
    web_View.backgroundColor = [UIColor clearColor];
    
    web_View.hidden = YES;
    
    //[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(pushToHome) userInfo:nil repeats:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSLog(@"loaded");
    
    [UIView animateWithDuration:0.6 animations:^{
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            imgView.frame = CGRectMake(imgView.frame.origin.x, -200, imgView.frame.size.width, imgView.frame.size.height);
        }
        else{
            
            imgView.frame = CGRectMake(imgView.frame.origin.x, -100, imgView.frame.size.width, imgView.frame.size.height);
        }
        
    } completion:^(BOOL finished) {
        
        webView.center = self.view.center;
        
        web_View.hidden = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(pushToHome) userInfo:nil repeats:NO];
    }];
}

-(void)pushToHome{
    
    HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    
    [self.navigationController pushViewController:homeViewController animated:YES];
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
