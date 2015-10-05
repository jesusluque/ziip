//
//  DetalleRecientesViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "DetalleRecientesViewController.h"

@interface DetalleRecientesViewController ()

@end

@implementation DetalleRecientesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void) pintaReciente {
    
    NSString *imagenTipo = @"";
    if ([[self.reciente objectForKey:@"tipo" ] isEqualToString:@"1"]) {
        self.tipoAccion.text = @"Mensaje";
        imagenTipo=@"jicanonimoA.png";
        
    } else if ([[self.reciente objectForKey:@"tipo" ] isEqualToString:@"2"]) {
        self.tipoAccion.text = @"Conecta";
        imagenTipo=@"jicconectaA.png";
        
    } else if ([[self.reciente objectForKey:@"tipo" ] isEqualToString:@"3"]) {
        self.tipoAccion.text = @"Celestina";
        imagenTipo=@"jiccelestinaA.png";
    }
    
    [self.imgTipoAccion setImage:[UIImage imageNamed:imagenTipo]];
    self.contacto_contacto.text = [self.reciente objectForKey:@"contacto1_contacto"];
    self.contacto_nombre.text = [self.reciente objectForKey:@"contacto1_nombre"];
    self.contacto2_contacto.text = [self.reciente objectForKey:@"contacto2_contacto"];
    self.contacto2_nombre.text = [self.reciente objectForKey:@"contacto2_nombre"];
    self.mensaje_personalizado.text = [self.reciente objectForKey:@"mensaje"];
    self.mensaje.text = [self.reciente objectForKey:@"mensaje_anonimo"];}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self pintaReciente];
    // Do any additional setup after loading the view.
}

@end
