//
//  AppDelegate.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class PublicidadViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSDate *lastConnectionError;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic,retain) PublicidadViewController *publicidadViewController;
@property(nonatomic) double latitudActual;
@property(nonatomic) double longitudActual;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

