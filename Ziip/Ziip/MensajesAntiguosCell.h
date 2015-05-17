//
//  MensajesAntiguosCell.h
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import <UIKit/UIKIT.h>
#import <Foundation/Foundation.h>



@class MensajesAntiguosCell;
@protocol MensajesAntiguosCellDelegate <NSObject>

- (void)mostrarMasMensajes;

@end


@interface MensajesAntiguosCell : UITableViewCell

@property (weak) id <MensajesAntiguosCellDelegate> delegate;

- (IBAction) cargarMensajesAntiguos;

@end

