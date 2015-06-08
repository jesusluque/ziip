//
//  ZiipBase.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 6/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ZiipBase.h"
#import "SVProgressHUD.h"


@implementation ZiipBase

-(void) viewDidLoad {
    
    [super viewDidLoad];
    self.r = [[ZiipRequest alloc] init];
    self.r.delegate = self;
    self.imageCache = [[ImageCache alloc]init];
    self.miDelegado = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = self.miDelegado.managedObjectContext;
    
    [self cambiaPublicidad];
}


-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"En el view did appear");
    [self cambiaPublicidad];
}


- (void)recibeDatos:(NSDictionary *)datos {

}

-(void) cambiaPublicidad {
    
    [self.miDelegado.publicidadViewController cambiaPublicidad:self.publicidad];
    
    [NSTimer scheduledTimerWithTimeInterval:[self.miDelegado.publicidadViewController.tiempo_recarga_publi doubleValue ] target:self selector:@selector(cambiaPublicidad) userInfo:nil repeats:NO];
}


- (void)no_autorizado {
    
    NSLog(@"no autorizado");
}


- (void)muestra_fallo_red {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDate *ultimo_error= appDelegate.lastConnectionError;
    NSDate *now = [[NSDate alloc] init];
    if (ultimo_error == nil){
        appDelegate.lastConnectionError = now;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ziip"
                                                            message:@"Conexion no disponible."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        
    } else {
        
        ultimo_error = [ultimo_error dateByAddingTimeInterval:5];
        
        if ([ultimo_error compare:now] == NSOrderedAscending) {
            appDelegate.lastConnectionError = now;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ziip"
                                                                message:@"Conexion no disponible."
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }
}


- (void)muestra_error {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDate *ultimo_error= appDelegate.lastConnectionError;
    NSDate *now = [[NSDate alloc] init];
    if (ultimo_error == nil){
        appDelegate.lastConnectionError = now;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ziip"
                                                            message:@"Ha ocurrido un error, cierra la aplicacion y vuelve a probar."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        
        ultimo_error = [ultimo_error dateByAddingTimeInterval:5];
        
        if ([ultimo_error compare:now] == NSOrderedAscending) {
            appDelegate.lastConnectionError = now;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ziip"
                                                                message:@"Ha ocurrido un error, cierra la aplicacion y vuelve a probar."
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }
}

- (void)showLoading {
    
    [SVProgressHUD showWithStatus:@"Cargando"];
}


- (void)hideLoading {
    
    [SVProgressHUD dismiss];
}







@end
