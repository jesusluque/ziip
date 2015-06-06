//
//  Person.h
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 10/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *telefono;
@property (nonatomic, strong) NSMutableArray *listaTelefonos;
@property (nonatomic, strong) NSMutableArray *listaEmails;


@end
