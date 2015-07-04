//
//  AppDelegate.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "PublicidadViewController.h"
#import "ListaChatsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self crearDirectorioCache];
    
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {

        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else {

        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    }
    self.publicidadViewController = [[PublicidadViewController alloc] init];
    [self.publicidadViewController inicializa];

    if ([self canChangeBadge]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    //[[UILabel appearance] setFont:[UIFont fontWithName:@"Futura Medium" size:14.0]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];

    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {

        [self.locationManager requestWhenInUseAuthorization];
    }

    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    
    return YES;
}



- (bool)canChangeBadge; {
    
    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        
        UIUserNotificationSettings* notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        return notificationSettings.types == UIUserNotificationTypeBadge;
    } else {
        return YES;
    }
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newToken forKey:@"pushToken"];
    [defaults synchronize];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"AppDelegate/didRegisterForRemoteNotificationsWithDeviceToken - Failed to get token, error: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //NSLog(@"Did become active");
    
    [self.locationManager startUpdatingLocation];
    
    if ([self canChangeBadge]) {
        
        application.applicationIconBadgeNumber = 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [application setApplicationIconBadgeNumber:0];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)crearDirectorioCache {
    
    [self crearDirectorio:@"usuarios"];
    [self crearDirectorio:@"uploads"];
    [self crearDirectorio:@"uploads/publicidad"];
    
}


- (void)crearDirectorio:(NSString *)urlFile {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@", docDir, urlFile];
    bool fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pngFilePath];
    
    if (!fileExists) {
        
        NSString *pngUserDir = [NSString stringWithFormat:@"%@/%@", docDir, urlFile];
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:pngUserDir withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Create directory  %@ error: %@", pngUserDir, error);
        }
    }
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Ziip" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}



- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Ziip.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}


- (void)saveContext {
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"AppDelegate/saveContext - Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // *********************************************************************************************************
    // esta funcion hace que el servidor sepa donde estamos
    // cuando nos movemos  mas de X metros, envia nuestra posicion
    // *********************************************************************************************************
    //NSLog(@"Update location %f",newLocation.coordinate.longitude);
    self.longitudActual = newLocation.coordinate.longitude;
    self.latitudActual = newLocation.coordinate.latitude;
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"%@", userInfo);
    
    NSDictionary *current = [userInfo objectForKey:@"aps"];
    NSDictionary *alert = [current objectForKey:@"alert"];
    NSDictionary *args = [alert objectForKey:@"loc-args"];
    NSString *theAction = [args objectForKey:@"action"];;
    
    NSLog(@"current: %@", current);
    NSLog(@"alert: %@", alert);
    NSLog(@"args: %@", args);
    NSLog(@"theAction: %@", theAction);
    
    
    
    if ([theAction isEqualToString:@"newMessage"]) {
        if (application.applicationState == UIApplicationStateActive) {
            //Si esta activa
        } else {
            //No esta activa.
            NSDictionary *alert = [[userInfo objectForKey:@"aps" ]objectForKey:@"alert" ];
            NSString *from = [[alert objectForKey:@"loc-args"] objectForKey:@"from" ];

            NSLog(@"%@",from);
            
            NSMutableDictionary *contacto = [[NSMutableDictionary alloc]initWithObjectsAndKeys: from,@"id",nil];
            NSLog(@"%@",contacto);
            
            if (self.tabBarController !=nil) {
                NSArray *controllers = [self.tabBarController viewControllers];
                UINavigationController *navigation = [controllers objectAtIndex:3];
                NSArray *controllers_nav = [navigation viewControllers];
                ListaChatsViewController *lista_chats = [controllers_nav objectAtIndex:0];
                lista_chats.abrirChatUsuario=contacto;
                [self.tabBarController setSelectedIndex:3];
            }
            
        }

    }
}


@end
