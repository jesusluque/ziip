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

@interface PublicidadViewController : UIViewController <ZiipRequestDelegate>

@property (nonatomic, retain) IBOutlet UIView *publicidad;
@property (nonatomic, retain) ZiipRequest *r;
@property (nonatomic,retain) ImageCache *imageCache;
@property (nonatomic,retain) NSMutableArray *listadoPublicidad;

-(void) inicializa;
-(void) cambiaPublicidad: (UIView *) vista;

@end
