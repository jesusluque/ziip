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
    if ([self.reciente.accion isEqualToString:@"anonimo"]) {
        self.tipoAccion.text = @"Anonimo";
        imagenTipo=@"jicanonimoA.png";
        
    } else if ([self.reciente.accion isEqualToString:@"conecta"]) {
        self.tipoAccion.text = @"Conecta";
        imagenTipo=@"jicconectaA.png";
        
    } else if ([self.reciente.accion isEqualToString:@"celestino"]) {
        self.tipoAccion.text = @"Celestina";
        imagenTipo=@"jiccelestinaA.png";
    }
    
    [self.imgTipoAccion setImage:[UIImage imageNamed:imagenTipo]];
    

    self.contacto_contacto.text = self.reciente.contacto_contacto;
    self.contacto_nombre.text = self.reciente.contacto_nombre;
    self.contacto2_contacto.text = self.reciente.contacto2_contacto;
    self.contacto2_nombre.text = self.reciente.contacto2_nombre;
    
    self.mensaje_personalizado.text = self.reciente.mensaje;
    self.mensaje.text = self.reciente.mensaje_anonimo;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self pintaReciente];
    // Do any additional setup after loading the view.
}

@end
