//
//  ContactosViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 2/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "ContactosViewController.h"
#import <AddressBook/AddressBook.h>

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
        NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
        {
            Person *person = [[Person alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            //4
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                                  kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            person.firstName = firstName; person.lastName = lastName;
            person.fullName = fullName;
            
            //email
            //5
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            
            //6
            NSUInteger j = 0;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
   cell.textLabel.text = person.fullName;
    return cell;
}

@end
