//
//  ConectaViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ConectaViewController.h"
#import "Recientes.h"

@implementation ConectaViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction) enviar {
    

    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"telefono",@"email", nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.telefono,self.email, nil];
    [self.r send:@"sendConecta" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:YES];
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
        Recientes *reciente = (Recientes *)[NSEntityDescription insertNewObjectForEntityForName:@"Recientes" inManagedObjectContext:self.managedObjectContext];
        
        NSString *contacto;
        if ([self.telefono isEqualToString:@""]) {
            contacto = self.email;
        }
        else {
            contacto = self.telefono ;
        }
        reciente.accion = @"anonimo";
        reciente.contacto_nombre = self.contacto_nombre;
        reciente.contacto_contacto = contacto;
        reciente.mensaje = @"";
        reciente.mensaje_anonimo = @"";
        reciente.fecha = [NSDate date];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new data with error: %@", [error domain]);
        }
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
