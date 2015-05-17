//
//  ChatMessage.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ChatMessage : NSManagedObject


@property(nonatomic, retain) NSNumber *idMessage;
@property(nonatomic, retain) NSNumber *serverId;
@property (nonatomic, retain) NSData *smallPicture;
@property(nonatomic, retain) NSNumber *tipo;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSNumber *from;
@property(nonatomic, retain) NSNumber *to;
@property(nonatomic, retain) NSDate *fecha;
@property(nonatomic, retain) NSDate *fechaLeido;

@end