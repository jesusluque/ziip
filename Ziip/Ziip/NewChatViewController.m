//
//  newChatViewController.m
//  ChatSocketIO
//
//  Created by Manuel Rodriguez Morales on 16/05/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "NewChatViewController.h"
#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation NewChatViewController

@synthesize usuarios;
@synthesize myTableView;
@synthesize delegate;
@synthesize imageCache;
@synthesize more;
@synthesize fromSearch;
@synthesize searchBar;


- (void)viewDidLoad {
    
	[super viewDidLoad];
	self.usuarios = [[NSMutableArray alloc] initWithObjects:nil];
	self.imageCache = [[ImageCache alloc]init];
	self.navigationItem.title = @"Select User";
	self.more = YES;
	self.fromSearch = NO;
	[self repinta];
}


#pragma mark - AbroadsterRequest Delegate -


- (void)recibeDatos:(NSArray *)datos {
    
	NSArray *lista_usuarios = [datos objectAtIndex:1];    
	if ([lista_usuarios count] < 20) {
		more = NO;
	} else {
		more = YES;
	}
	if (fromSearch) {
		self.usuarios = [[NSMutableArray alloc] initWithObjects:nil];
	}
	[self.usuarios addObjectsFromArray:lista_usuarios];
	[self recarga];
}


- (void)repinta {
    
	NSMutableArray *parametros = [[NSMutableArray alloc]initWithObjects:nil];
	NSMutableArray *valores = [[NSMutableArray alloc]initWithObjects:nil];
	NSString *key = @"";
    if ([self.searchBar.text length] > 0) {
		key = self.searchBar.text;
	}
	[parametros addObject:@"key"];
	[parametros addObject:@"inicio"];
	[valores addObject:key];
	[valores addObject:[NSString stringWithFormat:@"%lu", (unsigned long)usuarios.count]];
	[self.r sendPost:@"searchUserList" withParams:parametros andValues:valores];
}


- (void)recarga {
    
	[self.myTableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	return [self.usuarios count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserCell *cell;
	static NSString *CellIdentifier;
	CellIdentifier = @"selectUserCell";
	cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[UserCell class]]) {
				cell = (UserCell *)currentObject;
			}
		}
	}

    
    if ([usuarios count]>indexPath.row){
	if (more) {
		if (indexPath.row >= usuarios.count - 2) {
			self.fromSearch = NO;
			[self repinta];
		}
	}
		NSDictionary *usuario = [usuarios objectAtIndex:indexPath.row];
    cell.usuario.text = [[NSString alloc] initWithFormat:@"%@ %@ %@", [usuario objectForKey:@"name"], [usuario objectForKey:@"middle_name"], [usuario objectForKey:@"last_name"]];

    [cell.fotoUsuario setImage:[UIImage imageNamed:@"icoMale"]];
    if ([[usuario objectForKey:@"type"] isEqualToString:@"2"]) {
        cell.imgTipoUsuario.hidden = NO;
        [cell.imgTipoUsuario setImage:  [UIImage imageNamed:@"user_ribbon_professor"]];
        cell.texto.text = [[NSString alloc] initWithFormat:@"%@, %@ - Professor", [usuario objectForKey:@"dest_city_name"], [usuario objectForKey:@"dest_country_name"]];
    } else if ( [[usuario objectForKey:@"type"] isEqualToString:@"4"]) {
        cell.imgTipoUsuario.hidden = NO;
        [cell.imgTipoUsuario setImage:  [UIImage imageNamed:@"user_ribbon_staff"]];
        cell.texto.text = [[NSString alloc] initWithFormat:@"%@, %@ - Staff",  [usuario objectForKey:@"academic_provider_code"],[usuario objectForKey:@"dest_city_name"] ];
    } else if ( [[usuario objectForKey:@"type"] isEqualToString:@"5"]) {
        cell.imgTipoUsuario.hidden = NO;
        [cell.imgTipoUsuario setImage:  [UIImage imageNamed:@"user_ribbon_program_admin"]];
        cell.texto.text = [[NSString alloc] initWithFormat:@"%@ - Program Admin", [usuario objectForKey:@"academic_provider_code"]];
    } else {
        cell.imgTipoUsuario.hidden = YES;
        cell.texto.text = [[NSString alloc] initWithFormat:@"%@, %@ ", [usuario objectForKey:@"dest_city_name"], [usuario objectForKey:@"dest_country_name"]];
    }
    if ([[usuario objectForKey:@"image"]isEqualToString:@"img/users/default.png"]) {
		if ([[usuario objectForKey:@"gender"] intValue] == 1) {
			[cell.fotoUsuario setImage:[UIImage imageNamed:@"icoMale.png"]];
		} else {
			[cell.fotoUsuario setImage:[UIImage imageNamed:@"icoFemale.png"]];
		}
		[cell.fotoUsuario.layer setCornerRadius:5.0f];
		[cell.fotoUsuario.layer setMasksToBounds:YES];
	} else {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [imageCache getCachedImage:[usuario objectForKey:@"image"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                CGSize size = CGSizeMake(50, 50);
                UIGraphicsBeginImageContext(size);
                [img drawInRect:CGRectMake(0, 0, 50, 50)];
                UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [cell.fotoUsuario setImage:scaledImage];
                [cell.fotoUsuario.layer setCornerRadius:5.0f];
                [cell.fotoUsuario.layer setMasksToBounds:YES];
            });
        });
	}
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	NSDictionary *usuario = [usuarios objectAtIndex:indexPath.row];
	[self.delegate nuevaConversacion:usuario];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {

    [self.usuarios removeAllObjects];
	more = YES;
	self.fromSearch = YES;
	[self repinta];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
	[theSearchBar resignFirstResponder];
}


- (void)viewDidUnload {
    
	[self setTableView:nil];
	[super viewDidUnload];
}


@end
