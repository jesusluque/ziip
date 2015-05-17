//
//  UserCell.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell {
    
    UILabel *usuario;
    UIImageView *fotoUsuario;
    UIImageView *imgTipoUsuario;
    UILabel *texto;
    UILabel *hora;
    UILabel *numMensajes;
}

@property (nonatomic,retain) IBOutlet UIImageView *imgTipoUsuario;
@property (nonatomic,retain) IBOutlet UILabel *usuario;
@property (nonatomic,retain) IBOutlet UIImageView *fotoUsuario;
@property (nonatomic,retain) IBOutlet UILabel *texto;
@property (nonatomic,retain) IBOutlet UILabel *hora;
@property (nonatomic,retain) IBOutlet UILabel *numMensajes;

@end
