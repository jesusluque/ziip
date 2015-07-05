//
//  ContactosViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ContactosViewController.h"
#import <AddressBook/AddressBook.h>
#import "ContactosCell.h"
#import "AccionesContactosViewController.h"
#import "MensajeAnonimoViewController.h"
#import "ConectaViewController.h"
#import "CelestinoViewController.h"
#import "SeleccionaContactoViewController.h"


@interface ContactosViewController ()

@end

@implementation ContactosViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.listaPersonas = [[NSMutableArray alloc] initWithObjects: nil];
    self.listaPersonasFinal = [NSArray alloc];
    [self recargaContactos];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView=NO;
    [self.view addGestureRecognizer:tap];
    
    //self.listaItems = [[NSArray alloc] initWithObjects:@"Ana",@"Carmen",@"Luis",@"Nacho",@"Sonia", nil];
    
}

- (void) dismissKeyboard {
    
    [self.buscador resignFirstResponder];
}

- (void)recargaContactos {
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            [self recargaContactos];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {


    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app

    }
    
    if (addressBook != nil) {

        
        //2
        //CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);

        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);

        //3
        self.listaPersonas  = [[NSMutableArray alloc] initWithObjects: nil];
        NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++) {

            Person *person = [[Person alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            //4
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                                  kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);

            NSString *fullName = @"";
            

            if (firstName != nil && firstName != (id)[NSNull null]) {
                fullName = [NSString stringWithFormat:@"%@ %@", fullName, firstName];
            }
            if (lastName != nil && lastName != (id)[NSNull null]) {
                fullName = [NSString stringWithFormat:@"%@ %@", fullName, lastName];
            }

            person.firstName = firstName;
            person.lastName = lastName;
            person.fullName = fullName;
            
            person.listaTelefonos = [[NSMutableArray alloc] initWithObjects:nil];
            person.listaEmails = [[NSMutableArray alloc] initWithObjects:nil];
            
            
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(phones); j++) {
                NSString *telefono = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                [person.listaTelefonos addObject:telefono];
            }

            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            for (j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                [person.listaEmails addObject:email];
            }
            [self.listaPersonas addObject:person];
        }
        CFRelease(addressBook);
    } else { 
        //9
        NSLog(@"Error reading Address Book");
    }
    
    self.listaPersonasFinal = self.listaPersonas;
     
    
}



-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self recargaContactos];
}


-(void) actualizaListado:(ABAddressBookRef)addressBook {
    
   
    [self.myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.listaPersonasFinal count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Person *person = [self.listaPersonasFinal objectAtIndex:indexPath.row];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    ContactosCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[ContactosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
   cell.nombre.text = person.fullName;
    return cell;
}


-(void)  tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Person *person = [self.listaPersonasFinal objectAtIndex:indexPath.row];
    NSMutableArray *lista_contactos = [[NSMutableArray alloc] initWithArray: person.listaTelefonos];
    [lista_contactos  addObjectsFromArray:person.listaEmails];
    
    if ([lista_contactos count]==1) {
        [self eleccionContacto: [lista_contactos objectAtIndex:0]];
    } else if ([lista_contactos count]==0) {
        
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.confirmacionViewController = (ConfirmacionViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"ConfirmacionViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.confirmacionViewController.view.frame = frame;
        self.confirmacionViewController.delegate = self;
        NSDictionary *dict_tipo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id", nil];
        NSArray *parametros = [[NSArray alloc] initWithObjects:@"cabecera",@"texto", @"tipo", nil];
        NSArray *valores= [[NSArray alloc] initWithObjects:@"Error",@"El contacto no tiene ningun email ni telefono", dict_tipo, nil];
        NSDictionary *confirmacion = [[NSDictionary alloc] initWithObjects:valores forKeys:parametros];
        [self.confirmacionViewController configuraPantalla:confirmacion];
        [self.view addSubview:self.confirmacionViewController.view];
        

    } else {
        UIStoryboard *myStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.detalleContactoViewController = (DetalleContactoViewController *)[myStoryBoard instantiateViewControllerWithIdentifier:@"DetalleContactoViewController"];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.detalleContactoViewController.view.frame = frame;
        self.detalleContactoViewController.delegate = self;
        
        self.detalleContactoViewController.listaContactos = lista_contactos;
        [self.detalleContactoViewController recargaTableView];
        [self.view addSubview:self.detalleContactoViewController.view];

    }
}


- (void)eleccionContacto:(NSString *)strContacto {
    
    
    NSIndexPath *indexPath = self.myTableView.indexPathForSelectedRow;
    
    self.contactoSeleccionado =  [self.listaPersonasFinal objectAtIndex:indexPath.row];
    self.contactoSeleccionado.email = @"";
    self.contactoSeleccionado.telefono= @"";
    
    for (NSString *telefono in self.contactoSeleccionado.listaTelefonos) {
        if ([telefono isEqualToString:strContacto]) {
            self.contactoSeleccionado.telefono = strContacto;
        }
    }
    for (NSString *email in self.contactoSeleccionado.listaEmails) {
        if ([email isEqualToString:strContacto]) {
            self.contactoSeleccionado.email = strContacto;
        }
    }

    if ([self.accion isEqualToString:@"anonimo"]) {
        [self performSegueWithIdentifier:@"mensaje_anonimo_segue" sender:nil];
    } else if ([self.accion isEqualToString:@"conecta"]) {
        [self performSegueWithIdentifier:@"conecta_segue" sender:nil];
    } else if ([self.accion isEqualToString:@"celestino"]) {
        [self performSegueWithIdentifier:@"celestino_segue" sender:nil];
    }else if ([self.accion isEqualToString:@"celestino2"]) {
        [self performSegueWithIdentifier:@"celestino2_segue" sender:nil];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"mensaje_anonimo_segue"]) {
        MensajeAnonimoViewController *accionesContactosViewController = (MensajeAnonimoViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono = self.contactoSeleccionado.telefono;
        accionesContactosViewController.email = self.contactoSeleccionado.email;
        accionesContactosViewController.contacto_nombre = self.contactoSeleccionado.fullName;
    } else if ([[segue identifier] isEqualToString:@"conecta_segue"]) {
        ConectaViewController *accionesContactosViewController = (ConectaViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono = self.contactoSeleccionado.telefono;
        accionesContactosViewController.email = self.contactoSeleccionado.email;
        accionesContactosViewController.contacto_nombre = self.contactoSeleccionado.fullName;
    } else if ([[segue identifier] isEqualToString:@"celestino_segue"]) {
        SeleccionaContactoViewController *accionesContactosViewController = (SeleccionaContactoViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono1 = self.contactoSeleccionado.telefono;
        accionesContactosViewController.email1 = self.contactoSeleccionado.email;
        accionesContactosViewController.contacto1_nombre = self.contactoSeleccionado.fullName;
        accionesContactosViewController.accion = @"celestino2";
        
    } else if ([[segue identifier] isEqualToString:@"celestino2_segue"]) {
        CelestinoViewController *accionesContactosViewController = (CelestinoViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono1 = self.telefono1;
        accionesContactosViewController.email1 = self.email1;
        accionesContactosViewController.contacto1_nombre = self.contacto1_nombre;
        accionesContactosViewController.telefono2 = self.contactoSeleccionado.telefono;
        accionesContactosViewController.email2 = self.contactoSeleccionado.email;
        accionesContactosViewController.contacto2_nombre = self.contactoSeleccionado.fullName;

    }
}


-(void) cierraConfirmacion {
    
    [self.confirmacionViewController.view removeFromSuperview];
}


-(void) respuestaUsuario:(bool)respuesta {
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self cargarLista: searchBar.text];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    self.listaPersonasFinal = self.listaPersonas;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.myTableView reloadData];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    
    [self cargarLista: searchBar.text];
    [searchBar resignFirstResponder];
}


- (void)cargarLista: (NSString *)key {
    
    NSString *keySearch = [[NSString alloc] initWithFormat:@"*%@*",key];
    if ([key isEqualToString:@""]) {
        self.listaPersonasFinal = self.listaPersonas;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName Like[cd] %@ ", keySearch];
        self.listaPersonasFinal = [self.listaPersonas filteredArrayUsingPredicate:predicate];
    }
    [self.myTableView reloadData];
}


-(IBAction) salirBuscar {

}

- (BOOL)disablesAutomaticKeyboardDismissal {
    
    return NO;
}


@end
