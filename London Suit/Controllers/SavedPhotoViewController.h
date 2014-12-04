//
//  SavedPhotoViewController.h
//  London Suit
//
//  Created by Parikshit Hedau on 09/10/14.
//  Copyright (c) 2014 Parikshit Hedau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedPhotoViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate>
{
    IBOutlet UICollectionView *collectionViewFrames;
    
    NSMutableArray *arrSavedPhotos;    
}

-(IBAction)backAction:(id)sender;

-(IBAction)editAction:(id)sender;

@end
