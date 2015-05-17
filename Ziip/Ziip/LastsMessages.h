//
//  LatstsMessages.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LastsMessages : NSManagedObject

@property(nonatomic, retain) NSNumber *userId;
@property(nonatomic, retain) NSNumber *userType;
@property(nonatomic, retain) NSString *userName;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *img;
@property(nonatomic, retain) NSNumber *noRead;
@property(nonatomic, retain) NSDate *fecha;
@property(nonatomic, retain) NSNumber *tipo;
@property(nonatomic, retain) NSNumber *bloqueado;

@end
