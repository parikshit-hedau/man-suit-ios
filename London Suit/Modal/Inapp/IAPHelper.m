//
//  IAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"
#import "AppDelegate.h"

@implementation IAPHelper
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize request = _request;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = [productIdentifiers retain];
        
        // Check for previously purchased products
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }
        self.purchasedProducts = purchasedProducts;
                        
    }
    return self;
}

- (void)requestProducts {
    
    self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] autorelease];
    _request.delegate = self;
    [_request start];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Received products results...");   
    self.products = response.products;
    self.request = nil;    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];    
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // TODO: Record the transaction on the server side...    
}

- (void)provideContent:(NSString *)productIdentifier {
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    
//    if ([appDelegate.userDetail isKindOfClass:[NSMutableDictionary class]]) {
//        NSLog(@"NSMutableDictionary");
//    }else{
//        NSLog(@"NSDictionary");
//    }
//    
//    NSLog(@"Toggling flag for: %@", productIdentifier);
//    
//    if ([productIdentifier isEqualToString:@"com.italkfastpro.1"])
//    {
//        NSLog(@"001");
//        
//        
//        int credit = [[appDelegate.userDetail objectForKey:@"credit"]intValue];
//        NSLog(@"credit %d",credit);
//        credit = credit + 1;
//        NSLog(@"credit %d",credit);
//        [appDelegate.userDetail setObject:[NSString stringWithFormat:@"%d",credit] forKey:@"credit"];
//        [appDelegate showAlertWithMessage:@"You can download more videos now"];
//        [appDelegate updateCredit:credit];
//        
//        NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
//        [appDefaults setObject:appDelegate.userDetail forKey:@"userDetail"];
//        [appDefaults synchronize];
//        
//    }
//    else if([productIdentifier isEqualToString:@"com.italkfastpro.3"]){
//        NSLog(@"002");
//        
//        int credit = [[appDelegate.userDetail objectForKey:@"credit"]intValue];
//        credit = credit + 3;
//        [appDelegate.userDetail setObject:[NSString stringWithFormat:@"%d",credit] forKey:@"credit"];
//       
//        [appDelegate showAlertWithMessage:@"You can download more videos now"];
//        [appDelegate updateCredit:credit];
//
//        
//        NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
//        [appDefaults setObject:appDelegate.userDetail forKey:@"userDetail"];
//        [appDefaults synchronize];
//        
//    }
//    else if([productIdentifier isEqualToString:@"com.italkfastpro.5"]){
//        NSLog(@"003");
//        
//        int credit = [[appDelegate.userDetail objectForKey:@"credit"]intValue];
//        credit = credit + 5;
//        [appDelegate.userDetail setObject:[NSString stringWithFormat:@"%d",credit] forKey:@"credit"];
//        
//        [appDelegate showAlertWithMessage:@"You can download more videos now"];
//        [appDelegate updateCredit:credit];
//
//        
//        NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
//        [appDefaults setObject:appDelegate.userDetail forKey:@"userDetail"];
//        [appDefaults synchronize];
//        
//        
//    }
//   
    
   // appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
      
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...");
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...");
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iTalkFast" message:transaction.error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",Nil, nil];
        [alertView show];
        [alertView release];
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)buyProductIdentifier:(NSString *)productIdentifier {
    
    NSLog(@"Buying %@...", productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)dealloc
{
    [_productIdentifiers release];
    _productIdentifiers = nil;
    [_products release];
    _products = nil;
    [_purchasedProducts release];
    _purchasedProducts = nil;
    [_request release];
    _request = nil;
    [super dealloc];
}

@end
