//
//  PublicidadViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 25/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "PublicidadViewController.h"
#import "Define.h"
#import "Reachability.h"
#import "JSONKit.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface PublicidadViewController ()

@end

@implementation PublicidadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) inicializa {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0,0 , self.view.frame.size.width, 50)];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //[self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.tiempo_recarga_publi=@(60);
    self.tiempo_recarga_server= @(3600);
    //self.r = [[ZiipRequest alloc] init];
    //self.r.delegate = self;
    self.imageCache = [[ImageCache alloc]init];
    
    NSArray *objs_iad = [[NSArray alloc] initWithObjects:@"1",@(100), nil];
    NSArray *keys_iad = [[NSArray alloc] initWithObjects:@"tipo",@"peso", nil];
    NSDictionary *iad = [[NSDictionary alloc] initWithObjects:objs_iad forKeys:keys_iad];
    self.listadoPublicidad = [[NSMutableArray alloc] initWithObjects:iad, nil];
    
    [self solicitaInfoServer];
}


-(void) cambiaPublicidad: ( UIView *) vista {
    

    //seleccionamos la publicidad.
    NSDictionary *publi = [self seleccionaPublicidad];
    
    //tenemos que quitar la publicidad previa
    for (UIView *subvista in [vista subviews]){
        [subvista removeFromSuperview];
    }

    if ([[publi objectForKey:@"tipo"]  intValue] == 1) {
        //Si es iad
        
        [vista addSubview:self.adView];
        
        
    } else {
        //si es propia
        NSArray *items = [[publi objectForKey:@"imagen"] componentsSeparatedByString:@"."];
        
        [self impresion:[publi objectForKey:@"id"]];
        
        
        NSString *url_img_publicidad = [[NSString alloc] initWithFormat:@"%@_%d.%@",[items objectAtIndex:0], (int)vista.frame.size.width,[items objectAtIndex:1] ];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [self.imageCache getCachedImagePubli:url_img_publicidad];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect frame = CGRectMake(0,0,vista.frame.size.width,50);
                UIButton *boton = [UIButton buttonWithType:UIButtonTypeCustom];
                boton.frame = frame;
                [boton setImage:img forState:UIControlStateNormal];
                boton.tag = [[publi objectForKey:@"id"] intValue];
                [boton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
                
                [vista addSubview:boton];
                
                
            });
        });
    }
}


- (void) impresion :(NSNumber *)id_publi{
    
    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"id", nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:id_publi, nil];
    [self send:@"setImpresion" tipo_peticion:@"GET" withParams:parametros andValues:valores enviarToken:NO];
}


- (void) click :(UIButton*)sender{
    
    NSPredicate *publiPredicate = [NSPredicate predicateWithFormat:@"id = %@ ", @(sender.tag) ];
    NSArray *filtered = [self.listadoPublicidad filteredArrayUsingPredicate:publiPredicate];
    NSDictionary *publi = [filtered objectAtIndex:0];
    
    
    

    
    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"id", nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:@(sender.tag), nil];
    [self send:@"setClick" tipo_peticion:@"GET" withParams:parametros andValues:valores enviarToken:NO];
    
    NSURL *url = [NSURL URLWithString:[publi objectForKey:@"url"]];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}


- (NSDictionary *) seleccionaPublicidad {
    
    int numero = arc4random_uniform(101);
    
    int i = 0;
    NSDictionary *publi_seleccionada;
    for (NSDictionary *publi  in self.listadoPublicidad ) {
        i=i+[[publi objectForKey:@"peso"]intValue];
        if (i >= numero){
            publi_seleccionada=publi;
            break;
        }
        
    }
    return publi_seleccionada;
}


- (void) solicitaInfoServer {
    
    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"latitud",@"lontigud", nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:@(self.location.coordinate.latitude),@(self.location.coordinate.longitude), nil];
    [self send:@"getPublicidad" tipo_peticion:@"GET" withParams:parametros andValues:valores enviarToken:NO];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    
    MKMapPoint start = MKMapPointForCoordinate(newLocation.coordinate);
    MKMapPoint end = MKMapPointForCoordinate(self.location.coordinate);
    
    double distancia = MKMetersBetweenMapPoints(start,end) ;
    
    
    if (distancia > 1000) {
        self.location = newLocation;
        [self solicitaInfoServer];
    }
    
    
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"getPublicidad"]) {
        self.tiempo_recarga_publi = [datos objectForKey:@"tiempo_recarga_banner"];
        self.tiempo_recarga_server = [datos objectForKey:@"tiempo_recarga_server"];

        self.listadoPublicidad = [datos objectForKey:@"anuncios"];
        [NSTimer scheduledTimerWithTimeInterval:[self.tiempo_recarga_server doubleValue ] target:self selector:@selector(solicitaInfoServer) userInfo:nil repeats:NO];
        
    }
}


- (void) send:(NSString *)action tipo_peticion:(NSString* )tipo_peticion withParams:(NSMutableArray *)parametros andValues:(NSMutableArray *)valores enviarToken:(bool)enviarToken {
    
    Reachability* internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus =  [internetReachable currentReachabilityStatus];
    
    if (internetStatus != NotReachable){
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *completeUrl = [[[NSString alloc] initWithFormat:@"%@%@",PUBLICIDAD_URL,action]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (parametros == nil) {
            parametros = [[NSMutableArray alloc] init];
            valores = [[NSMutableArray alloc] init];
            
        }
        if ([parametros count] ==[valores count]) {

            if ([action rangeOfString:@"status"].location != NSNotFound) {
                if ([defaults objectForKey:@"fechaUltimoMensaje"]) {
                    [parametros addObject:@"lastMessage"];
                    [valores addObject:[defaults objectForKey:@"fechaUltimoMensaje"]];
                }
            }
            
            NSString *parametros_procesados = [self procesa_parametros:parametros conValores:valores ];
            NSMutableURLRequest *request;
            if ([tipo_peticion isEqualToString:@"GET"]) {
                completeUrl = [[[NSString alloc] initWithFormat:@"%@?%@",completeUrl,parametros_procesados]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString:completeUrl]];
            } else {
                request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString:completeUrl]];
                [request setHTTPBody:[parametros_procesados dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [request setHTTPMethod:tipo_peticion];
            
            [request setValue:[NSString stringWithFormat:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"] forHTTPHeaderField:@"Accept"];
            
            if (enviarToken){
                
                if ([defaults objectForKey:@"api_auth_token"]){
                    [request setValue:[defaults objectForKey:@"api_auth_token"] forHTTPHeaderField:@"X-Auth-Token"];
                    
                }
            }
            [self showLoading];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                [self hideLoading];
                //NSString *str_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //NSLog(@"str_Data: %@",str_data);
                if (error == nil) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

                    [self recibeDatos:result];
                } else {

                    [self muestra_fallo_red];
                }
            }];
            
        }
    } else {
        //no hay CONEXION_URL
        [self muestra_fallo_red];
    }
}


- (NSString *) procesa_parametros: (NSArray *) parametros conValores: (NSArray *) valores {
    
    NSString *cadena=[[NSString alloc]init];
    NSUInteger i;
    unsigned long numItems=parametros.count;
    
    if (numItems >0) {
        cadena = [NSString stringWithFormat:@"%@=%@",[parametros objectAtIndex:0],[valores objectAtIndex:0]];
    }
    for (i=1;i<numItems; i++) {
        cadena = [NSString stringWithFormat:@"%@&%@=%@",cadena,[parametros objectAtIndex:i],[valores objectAtIndex:i]];
    }
    return [cadena stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}



-(void) showLoading{
}

-(void) hideLoading{
}

-(void) muestra_fallo_red{
}
-(void) no_autorizado{
}
-(void) muestra_error{
}

@end
