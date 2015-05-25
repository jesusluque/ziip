//
//  PublicidadViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 25/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "PublicidadViewController.h"

@interface PublicidadViewController ()

@end

@implementation PublicidadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.r = [[ZiipRequest alloc] init];
    self.r.delegate = self;
    self.imageCache = [[ImageCache alloc]init];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) inicializa {
    //Inicializamos lo necesario, es al arrancar la app.
    //hacemos petición de carga de publicidad.
    //Ponemos un cron, si la app esta online, hacemos peticion de carga de publicidad, cada X horas
    
}


-(void) cambiaPublicidad: ( UIView *) vista{
    //Dada una vista, ponemos la publicidad
    //se llama cada X tiempo para cada vista desde el base
    
    
}
@end
