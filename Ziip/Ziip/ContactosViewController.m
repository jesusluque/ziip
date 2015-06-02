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
    self.listaPersonas= [[NSMutableArray alloc] initWithObjects: nil];
    
    [self recargaContactos];
    
    //self.listaItems = [[NSArray alloc] initWithObjects:@"Ana",@"Carmen",@"Luis",@"Nacho",@"Sonia", nil];
}


- (void)recargaContactos {
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil) {
        NSLog(@"Succesful.");
        
        //2
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        //3
        NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++) {
            Person *person = [[Person alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            //4
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                                  kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            person.firstName = firstName; person.lastName = lastName;
            person.fullName = fullName;
            
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(phones); j++) {
                NSString *telefono = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                if (j == 0) {
                    person.phone = telefono;
                }
            }

            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            
            
            for (j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if (j == 0) {
                    person.homeEmail = email;
                   
                }
                else if (j==1) person.workEmail = email; 
            }
            
            //7 
            [self.listaPersonas addObject:person];
        }
        
        //8
        CFRelease(addressBook);
    } else { 
        //9
        NSLog(@"Error reading Address Book");
    }
    
}



-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self recargaContactos];
}


-(void) actualizaListado:(ABAddressBookRef)addressBook {
    
   
    [self.myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"contando: %@",self.listaPersonas);
    return [self.listaPersonas count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Person *person = [self.listaPersonas objectAtIndex:indexPath.row];
    
    NSLog(@"%@",person);
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    ContactosCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[ContactosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
   cell.nombre.text = person.fullName;
    return cell;
}


-(void)  tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.contactoSeleccionado =  [self.listaPersonas objectAtIndex:indexPath.row];
    if ([self.accion isEqualToString:@"anonimo"]) {
        [self performSegueWithIdentifier:@"mensaje_anonimo_segue" sender:nil];
    } else if ([self.accion isEqualToString:@"conecta"]) {
        [self performSegueWithIdentifier:@"conecta_segue" sender:nil];
    } else if ([self.accion isEqualToString:@"celestino_segue"]) {
        [self performSegueWithIdentifier:@"celestino_segue" sender:nil];
    }else if ([self.accion isEqualToString:@"celestino2_segue"]) {
        [self performSegueWithIdentifier:@"celestino2_segue" sender:nil];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"mensaje_anonimo_segue"]) {
        MensajeAnonimoViewController *accionesContactosViewController = (MensajeAnonimoViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono = self.contactoSeleccionado.phone;
        accionesContactosViewController.email = self.contactoSeleccionado.homeEmail;
        accionesContactosViewController.contacto_nombre = self.contactoSeleccionado.fullName;
    } else if ([[segue identifier] isEqualToString:@"conecta_segue"]) {
        ConectaViewController *accionesContactosViewController = (ConectaViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono = self.contactoSeleccionado.phone;
        accionesContactosViewController.email = self.contactoSeleccionado.homeEmail;
        accionesContactosViewController.contacto_nombre = self.contactoSeleccionado.fullName;
    } else if ([[segue identifier] isEqualToString:@"celestino_segue"]) {
        SeleccionaContactoViewController *accionesContactosViewController = (SeleccionaContactoViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono1 = self.contactoSeleccionado.phone;
        accionesContactosViewController.email1 = self.contactoSeleccionado.homeEmail;
        accionesContactosViewController.contacto1_nombre = self.contactoSeleccionado.fullName;
        accionesContactosViewController.accion = @"celestino2";
        
    } else if ([[segue identifier] isEqualToString:@"celestino2_segue"]) {
        CelestinoViewController *accionesContactosViewController = (CelestinoViewController *)[segue destinationViewController];
        accionesContactosViewController.telefono1 = self.telefono1;
        accionesContactosViewController.email1 = self.email1;
        accionesContactosViewController.contacto1_nombre = self.contacto1_nombre;
        accionesContactosViewController.telefono2 = self.contactoSeleccionado.phone;
        accionesContactosViewController.email2 = self.contactoSeleccionado.homeEmail;
        accionesContactosViewController.contacto2_nombre = self.contactoSeleccionado.fullName;

    }
    
    
}



@end
