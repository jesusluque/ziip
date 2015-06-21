//
//  ConectaViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ConectaViewController.h"

@implementation ConectaViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *contacto;
    if ([self.telefono isEqualToString:@""]) {
        contacto=self.email;
        
    } else {
        contacto=self.telefono;
    }
    if ( !self.contacto_nombre) {
        self.contacto_nombre=@"";
    }
    
    NSString *mensajeA = [[NSString alloc] initWithFormat:@"Invita a tu amigo %@ %@ a usar Ziip", self.contacto_nombre,contacto];
    self.mensajeA.text = mensajeA;
}


-(IBAction) enviar {
    

    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"nombre1",@"telefono",@"email", nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.contacto_nombre, self.telefono,self.email, nil];
    [self.r send:@"sendConecta" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:YES];
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    NSLog(@"%@",datos);
    if ([[datos objectForKey:@"resource"] isEqualToString:@"sendConecta"]) {
        
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
        
        
        
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores;
        if ([[datos objectForKey:@"status"]isEqualToString:@"ok"]) {
            valores = [[NSArray alloc] initWithObjects:@"Invitación enviada correctamente",@"Su invitación se ha enviado correctamente", dict_tipo, nil];
            
        } else  {
            valores = [[NSArray alloc] initWithObjects:@"Invitación no enviada", [datos objectForKey:@"motivo_error"], dict_tipo, nil];
        }
        
        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        
        [self.confirmacionViewController configuraPantalla:confirmacion];
        [self.view addSubview:self.confirmacionViewController.view];
    }
}


-(void) cierraConfirmacion {
    
    [self.confirmacionViewController.view removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void) respuestaUsuario:(bool)respuesta {
    
}

@end
