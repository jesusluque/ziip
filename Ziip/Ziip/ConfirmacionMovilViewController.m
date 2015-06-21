//
//  ConfirmacionMovilViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 9/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ConfirmacionMovilViewController.h"

@interface ConfirmacionMovilViewController ()

@end

@implementation ConfirmacionMovilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)enviar {
    
    NSString *errores=@"";
    if ([self.codigo.text isEqualToString:@""]) {
        [self.codigo becomeFirstResponder];
        errores = [[NSString alloc] initWithFormat:@"%@\n%@", errores, @"El código es obligatorio."];
    }
    
    
    if (![errores isEqualToString:@""]) {

        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
        
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",errores, dict_tipo, nil];
        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        [self.confirmacionViewController configuraPantalla:confirmacion];
        [self.view addSubview:self.confirmacionViewController.view];

    } else {
        
        NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"codigo", nil];
        NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.codigo.text, nil];

        [self.r send:@"confirmacionMovil" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:YES];
    }
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"confirmacionMovil"]) {
        if ([[datos objectForKey:@"status"]isEqualToString:@"ok"]) {
            
            if (self.proceso_registro) {

                [self performSegueWithIdentifier:@"segue_principal" sender: self];
            } else {
                NSLog(@"Gurado telefono: %@",self.telefono);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:self.telefono forKey:@"telefono"];
                [defaults synchronize];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            
            
        } else  {
            UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.confirmacionViewController.view.frame = frame;
            self.confirmacionViewController.delegate = self;
            
            NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
            
            NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
            NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",[datos objectForKey:@"mensaje"], dict_tipo, nil];
            NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
            [self.confirmacionViewController configuraPantalla:confirmacion];
            [self.view addSubview:self.confirmacionViewController.view];

            
        }
        
    }
}


-(void) cierraConfirmacion {
    
    [self.confirmacionViewController.view removeFromSuperview];
}


-(void) respuestaUsuario:(bool)respuesta {
    
}

@end
