//
//  PublicidadViewController.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 25/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZiipRequest.h"
#import "ImageCache.h"
#import "Define.h"
#import <CoreLocation/CoreLocation.h>
#import "iAd/ADBannerView.h"

@interface PublicidadViewController : UIViewController <ZiipRequestDelegate,CLLocationManagerDelegate,ADBannerViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *publicidad;
//@property (nonatomic, retain) ZiipRequest *r;
@property (nonatomic,retain) ImageCache *imageCache;
@property (nonatomic,retain) NSMutableArray *listadoPublicidad;
@property (nonatomic,retain) NSNumber *tiempo_recarga_publi;
@property (nonatomic,retain) NSNumber *tiempo_recarga_server;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation * location;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;
@property (nonatomic, retain)ADBannerView *adView;

-(void) inicializa;
-(void) cambiaPublicidad: (UIView *) vista;

@end
