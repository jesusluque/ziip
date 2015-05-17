//
//  UserCell.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

@synthesize usuario;
@synthesize hora;
@synthesize fotoUsuario;
@synthesize texto;
@synthesize numMensajes;
@synthesize imgTipoUsuario;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
