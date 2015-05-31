//
//  AnonimoViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "SeleccionaContactoViewController.h"
#import "ContactosViewController.h"
#import "MensajeAnonimoViewController.h"
#import "ConectaViewController.h"
#import "CelestinoViewController.h"


@interface SeleccionaContactoViewController ()

@end

@implementation SeleccionaContactoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) enviar {
    
    if ([self.telefono.text isEqualToString:@""] && [self.telefono.text isEqualToString:@""]) {
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
        
        
        
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores = [[NSArray alloc] initWithObjects:@"Error",@"Debe introducir un telefono o un email, o bien elegir un contacto de la agenda", dict_tipo, nil];

        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        
        [self.confirmacionViewController configuraPantalla:confirmacion];
        
        [self.view addSubview:self.confirmacionViewController.view];
        
        
    } else {
        if ([self.accion isEqualToString:@"anonimo"]){
            [self performSegueWithIdentifier:@"mensaje_anonimo_segue" sender:nil];
        } else if ([self.accion isEqualToString:@"conecta"]){
            [self performSegueWithIdentifier:@"conecta_segue" sender:nil];
        
        }else if ([self.accion isEqualToString:@"celestino"]){
            [self performSegueWithIdentifier:@"celestino_segue" sender:nil];
        }else if ([self.accion isEqualToString:@"celestino2"]){
            [self performSegueWithIdentifier:@"celestino2_segue" sender:nil];
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"contactos_segue"]) {
        ContactosViewController *accionViewController = (ContactosViewController *)[segue destinationViewController];
        accionViewController.accion = self.accion;
        if ([self.accion isEqualToString:@"celestino2"]) {
            accionViewController.telefono1 = self.telefono1;
            accionViewController.email1 = self.email1;
            accionViewController.contacto1_nombre = self.contacto1_nombre;
        }
    } else if ([[segue identifier] isEqualToString:@"mensaje_anonimo_segue"]) {
        MensajeAnonimoViewController *accionViewController = (MensajeAnonimoViewController *)[segue destinationViewController];
        accionViewController.telefono = self.telefono.text;
        accionViewController.email = self.email.text;
    } else if ([[segue identifier] isEqualToString:@"conecta_segue"]) {
        ConectaViewController *accionViewController = (ConectaViewController *)[segue destinationViewController];
        accionViewController.telefono = self.telefono.text;
        accionViewController.email = self.email.text;
    } else if ([[segue identifier] isEqualToString:@"celestino_segue"]) {
        SeleccionaContactoViewController *accionViewController = (SeleccionaContactoViewController *)[segue destinationViewController];
        accionViewController.telefono1 = self.telefono.text;
        accionViewController.email1 = self.email.text;
        accionViewController.accion=@"celestino2";
    } else if ([[segue identifier] isEqualToString:@"celestino2_segue"]) {
        CelestinoViewController *accionViewController = (CelestinoViewController *)[segue destinationViewController];
        accionViewController.telefono1 = self.telefono1;
        accionViewController.email1 = self.email1;
        accionViewController.contacto1_nombre = self.contacto1_nombre;
        accionViewController.telefono2 = self.telefono.text;
        accionViewController.email2 = self.email.text;
    }
    
}


-(void) cierraConfirmacion {
    
    [self.confirmacionViewController.view removeFromSuperview];
}


-(void) respuestaUsuario:(bool)respuesta {
    
}
@end
