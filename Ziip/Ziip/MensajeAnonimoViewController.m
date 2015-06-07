//
//  MensajeAnonimoViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 30/5/15.
//  Copyright (c) 2015 mentopia. All rights reserved.
//

#import "MensajeAnonimoViewController.h"
#import "Recientes.h"
#import "CoreDataHelper.h"



@implementation MensajeAnonimoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[self scrollView] setContentSize:self.vistaCampos.frame.size];
    self.listaMensajes = [[NSMutableArray alloc] initWithObjects: nil];
    
    [self.listaMensajes addObject:@"Te conozco desde hace tiempo y quiero conocerte mejor."];
    [self.listaMensajes addObject:@"Nos conocemos desde hace poco, pero no puedo olvidarte."];
    [self.listaMensajes addObject:@"Trabajamos juntos, tenemos muchas cosas en común, charlemos."];
    [self.listaMensajes addObject:@"Nuestras miradas se han encontrado, nuestras palabras también podrían."];
    [self.listaMensajes addObject:@"Estudiamos juntos, y desde que te vi no te olvido."];
    [self.myTableView reloadData];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(scrollViewPulsado)];
    [tapRecognizer setCancelsTouchesInView:NO];
    [[self scrollView] addGestureRecognizer:tapRecognizer];
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
        NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",@"Debe  escribir un mensaje personalizado", dict_tipo, nil];
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
            NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:@"telefono",@"email",@"mensaje_anonimo",@"mensaje", nil];
            NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects:self.telefono,self.email,mensaje_anonimo,self.mensaje.text, nil];
            [self.r send:@"sendMensajeAnonimo" tipo_peticion:@"POST" withParams:parametros andValues:valores enviarToken:YES];
        }
    }
}


-(void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"sendMensajeAnonimo"]) {
        
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
        
        NSIndexPath *indexPath = self.myTableView.indexPathForSelectedRow;
        NSString *mensaje_anonimo =  [self.listaMensajes objectAtIndex:indexPath.row];
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
        reciente.mensaje = self.mensaje.text;
        reciente.mensaje_anonimo = mensaje_anonimo;
        reciente.fecha = [NSDate date];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to add new data with error: %@", [error domain]);
        }
    }
}


-(void) cierraConfirmacion {
    
    bool error = NO;
    if ( [self.mensaje.text isEqualToString:@""]) {
        error=YES;
    }
    if (!error) {
        NSIndexPath *indexPath = self.myTableView.indexPathForSelectedRow;
        if (! indexPath) {
             error=YES;
        }
    }
    [self.confirmacionViewController.view removeFromSuperview];
    if (!error) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


-(void) respuestaUsuario:(bool)respuesta {

}


-(void) textViewDidBeginEditing:(UITextView *)textView {
    
    [self performSelector:@selector(scrollToView:) withObject:self.btnEnviar afterDelay:0.1];
}


- (void)keyboardDidShow: (NSNotification *) notification{
    
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height + 10, 0.0);
    self.scrollView.contentInset = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    
    if(!CGRectContainsPoint(aRect, self.btnEnviar.frame.origin)){
        [self performSelector:@selector(scrollToView:) withObject:self.btnEnviar afterDelay:0.1];
    }
}


- (void) scrollToView:(UIView *)aView {
    
    [self.scrollView scrollRectToVisible:aView.frame animated:YES];
}


- (void)keyboardDidHide: (NSNotification *) notification{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}


- (void) scrollViewPulsado {
    
    [[self vistaCampos] endEditing:YES];
}



@end
