//
//  ConfirmacionViewController.m
//  d3
//
//  Created by Manuel Rodriguez Morales on 3/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ConfirmacionViewController.h"



@implementation ConfirmacionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

}



-(IBAction)cancelar:(id)sender {
    
    [self.delegate respuestaUsuario:NO];
}


-(IBAction)aceptar:(id)sender {
    
    [self.delegate respuestaUsuario:YES];
}


-(IBAction)cerrar:(id)sender {
    
    [self.delegate cierraConfirmacion];
}


/*
- (void) configuraPantalla:(NSDictionary *) confirmacion{
    
    self.titulo.text = [confirmacion objectForKey:@"cabecera"];
    self.mensaje.text = [confirmacion objectForKey:@"texto"];
    NSDictionary *tipo = [confirmacion objectForKey:@"tipo"];
    if ([[tipo objectForKey:@"id"] integerValue]==1) {
        self.btnCancelar.hidden = NO;
        self.btnAceptar.hidden = NO;
        self.btnCerrar.hidden = YES;
    } else { //Es notificacion
        self.btnCerrar.hidden = NO;
        self.btnCancelar.hidden = YES;
        self.btnAceptar.hidden = YES;
    }
}
*/


@end
