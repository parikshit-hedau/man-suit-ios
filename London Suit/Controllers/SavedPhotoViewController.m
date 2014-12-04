//
//  SavedPhotoViewController.m
//  London Suit
//
//  Created by Parikshit Hedau on 09/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import "SavedPhotoViewController.h"

#import "FrameCell.h"

@interface SavedPhotoViewController ()

@end

@implementation SavedPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    arrSavedPhotos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"savedPhotos"] mutableCopy];
    
    [collectionViewFrames registerNib:[UINib nibWithNibName:@"FrameCell" bundle:nil] forCellWithReuseIdentifier:@"frameCell"];
}

-(IBAction)backAction:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)editAction:(id)sender{
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return arrSavedPhotos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FrameCell *cell = (FrameCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"frameCell" forIndexPath:indexPath];
    
    UIImage *img = [UIImage imageWithContentsOfFile:[arrSavedPhotos objectAtIndex:indexPath.row]];
    
    cell.imgViewFrame.image = img;
    
    cell.imgViewFrame.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Share",@"Save to library", nil];
    
    sheet.tag = indexPath.row;
    
    [sheet showInView:self.view];
}

/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        NSLog(@"cancel");
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex){
        
        NSLog(@"delete");
        
        NSString *filePath = [arrSavedPhotos objectAtIndex:actionSheet.tag];
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [arrSavedPhotos removeObject:filePath];
        
        [collectionViewFrames reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrSavedPhotos forKey:@"savedPhotos"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(buttonIndex == 1){
        
        NSLog(@"Share");
        
        NSString *filePath = [arrSavedPhotos objectAtIndex:actionSheet.tag];
        
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                            initWithActivityItems:@[@"Hello World", img] applicationActivities:nil];
        
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
            
        };
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else{
        
        NSLog(@"save to library");
    }
}
*/

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        NSLog(@"cancel");
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex){
        
        NSLog(@"delete");
        
        NSString *filePath = [arrSavedPhotos objectAtIndex:actionSheet.tag];
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [arrSavedPhotos removeObject:filePath];
        
        [collectionViewFrames reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:arrSavedPhotos forKey:@"savedPhotos"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(buttonIndex == 1){
        
        NSLog(@"Share");
        
        NSString *filePath = [arrSavedPhotos objectAtIndex:actionSheet.tag];
        
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Hello World", img] applicationActivities:nil];
        
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
            
        };
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else{
        
        NSLog(@"save to library");
        
        NSString *filePath = [arrSavedPhotos objectAtIndex:actionSheet.tag];
        
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"error= %@",error);
    
    [[[UIAlertView alloc] initWithTitle:@"Man Suit" message:@"Photo is saved into library" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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
