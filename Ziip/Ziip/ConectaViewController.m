//
//  ConectaViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ConectaViewController.h"

@interface ConectaViewController ()

@end

@implementation ConectaViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction) enviar {
    

    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"telefono",@"email", nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.telefono,self.email, nil];
    [self.r send:@"sendConecta" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:NO];
}


-(void) recibeDatos:(NSDictionary *)datos {
    
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
            valores = [[NSArray alloc] initWithObjects:@"Invitacion enviada correctamente",@"Su invitacion se ha enviado correctamente", dict_tipo, nil];
            
        } else  {
            valores = [[NSArray alloc] initWithObjects:@"Invitacion no enviada", [datos objectForKey:@"motivo_error"], dict_tipo, nil];
        }
        
        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        
        [self.confirmacionViewController configuraPantalla:confirmacion];
        
        [self.view addSubview:self.confirmacionViewController.view];
        
    }
}


-(void) cierraConfirmacion {
    
    [self.confirmacionViewController.view removeFromSuperview];
}


-(void) respuestaUsuario:(bool)respuesta {
    
}

@end