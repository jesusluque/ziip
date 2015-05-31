//
//  CelestinoViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "CelestinoViewController.h"
#import "MensajesCell.h"


@interface CelestinoViewController ()

@end

@implementation CelestinoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.listaMensajes = [[NSMutableArray alloc] initWithObjects: nil];
    
    [self.listaMensajes addObject:@"Trabajo con vosotros y creo que deberíais conoceros mejor."];
    [self.listaMensajes addObject:@"Os he visto muchas veces, se que haceis buena pareja."];
    [self.listaMensajes addObject:@"Nos conocemos los tres y creo que os gustáis."];
    [self.listaMensajes addObject:@"Os he visto a ambos en clase, creo que hacéis buena pareja."];    
    [self.myTableView reloadData];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.listaMensajes count];
}



- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *mensaje = [self.listaMensajes objectAtIndex:indexPath.row];
    
    static NSString *simpleTableIdentifier = @"MensajesCell";
    
    MensajesCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[MensajesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.mensaje.text = mensaje;
    return cell;
}


-(IBAction) enviar {
    
    bool error = NO;
    if ( [self.mensaje.text isEqualToString:@""]) {
        error = YES;
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
        
        
        
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",@"Debe escribir un mensaje personalizado", dict_tipo, nil];
        
        
        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        
        [self.confirmacionViewController configuraPantalla:confirmacion];
        
        [self.view addSubview:self.confirmacionViewController.view];
        
        
    }
    if (!error) {
        NSIndexPath *indexPath = self.myTableView.indexPathForSelectedRow;
        
        if (! indexPath) {
            error = YES;
            UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.confirmacionViewController.view.frame = frame;
            self.confirmacionViewController.delegate = self;
            
            NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
            
            NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
            NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",@"Debe  seleccionar un mensaje", dict_tipo, nil];
            NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
            [self.confirmacionViewController configuraPantalla:confirmacion];
            [self.view addSubview:self.confirmacionViewController.view];
        }
        
        if (!error) {
            
            
            NSString *mensaje_anonimo =  [self.listaMensajes objectAtIndex:indexPath.row];
            NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"telefono1",@"email1",@"telefono2",@"email2",@"mensaje_anonimo",@"mensaje", nil];
            NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.telefono1,self.email1,self.telefono2,self.email2,mensaje_anonimo,self.mensaje.text, nil];
            [self.r send:@"sendCelestino" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:NO];
        }
    }
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"sendCelestino"]) {
        
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
    
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores;
        if ([[datos objectForKey:@"status"]isEqualToString:@"ok"]) {
            valores = [[NSArray alloc] initWithObjects:@"Mensaje enviado correctamente",@"Su mensaje se ha enviado correctamente", dict_tipo, nil];
            
        } else  {
            valores = [[NSArray alloc] initWithObjects:@"Mensaje no enviado", [datos objectForKey:@"motivo_error"], dict_tipo, nil];
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
