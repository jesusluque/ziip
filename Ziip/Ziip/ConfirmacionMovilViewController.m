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
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:errores
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles: nil];
        
        [alertView show];
    } else {
        
        NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"codigo", nil];
        NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.codigo.text, nil];

        [self.r send:@"confirmacionMovil" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:YES];
    }
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"confirmacionMovil"]) {
        if ([[datos objectForKey:@"status"]isEqualToString:@"ok"]) {

            [self performSegueWithIdentifier:@"segue_principal" sender: self];
            
            
        } else  {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:[datos objectForKey:@"mensaje"]
                                      delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles: nil];
            [alertView show];
        }
        
    }
}

@end
