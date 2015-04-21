//
//  AppDelegate.m
//  OFTest
//
//  Created by Kevin Coleman on 4/21/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "AppDelegate.h"
#import "LYRIdentityManager.h"
#import <LayerKit/LayerKit.h>
#import "OFRootViewController.h"

@interface AppDelegate ()

@property (nonatomic) LYRClient *client;
@property (nonatomic) LYRIdentityManager *manager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"9ec30af8-5591-11e4-af9e-f7a201004a3b"];
    self.manager = [LYRIdentityManager managerWithLayerAppID:appID];
    
    self.client = [LYRClient clientWithAppID:appID];
    [self.client connectWithCompletion:^(BOOL success, NSError *error) {
        if (self.client.authenticatedUserID) {
            [self presentOFViewController];
        } else {
            if (success) {
                NSLog(@"Layer Client Connected");
                [self requestAuthenticationNonce];
            } else {
                NSLog(@"Layer Client failed to connect with error: %@", error);
            }
        }
    }];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)requestAuthenticationNonce
{
    [self.client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (nonce) {
            [self requestIdentityTokenWithNonce:nonce];
        } else if (error) {
            NSLog(@"Failed requesting authentication nonce with error: %@", error);
        }
    }];
}

- (void)requestIdentityTokenWithNonce:(NSString *)nonce
{
    [self.manager identityTokenForUserIdentifier:@"test" nonce:nonce completion:^(NSString *identityToken, NSError *error) {
        if (identityToken) {
            [self authenticateWithIdentityToken:identityToken];
        } else if (error) {
            NSLog(@"Failed requesting identity token with error: %@", error);
        }
    }];
}

- (void)authenticateWithIdentityToken:(NSString *)identityToken
{
    [self.client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
        if (authenticatedUserID) {
            NSLog(@"Authenticated as %@", authenticatedUserID);
            [self presentOFViewController];
        } else if (error) {
            NSLog(@"Failed authentication with error: %@", error);
        }
    }];
}

- (void)presentOFViewController
{
    OFRootViewController *rootViewController = [OFRootViewController new];
    rootViewController.client = self.client;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

@end
