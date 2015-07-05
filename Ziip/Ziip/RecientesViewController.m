//
//  RecientesViewController.m
//  Ziip
//
//  Created by Manuel Rodriguez Morales on 24/5/15.
//  Copyright (c) 2015 Manuel Rodriguez Morales. All rights reserved.
//

#import "RecientesViewController.h"
#import "CoreDataHelper.h"
#import "RecientesTableViewCell.h"



@interface RecientesViewController ()

@end

@implementation RecientesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrayRecientes = [[NSMutableArray alloc] initWithObjects: nil];
    [self recargaRecientes];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

-(void) recargaRecientes {
    
    NSMutableArray *parametros = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *valores = [[NSMutableArray alloc] initWithObjects: nil];
    [self.r send:@"getRecientes" tipo_peticion:@"GET" withParams:parametros andValues:valores enviarToken:YES];
}


- (void) recibeDatos:(NSDictionary *)datos {
    
    if ([[datos objectForKey:@"resource"] isEqualToString:@"getRecientes"]) {
        
        self.arrayRecientes = [datos objectForKey:@"recientes"];
        [self.myTableView reloadData];
    }
}



-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self recargaRecientes];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.arrayRecientes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RecientesTableViewCell";
    RecientesTableViewCell *cell = (RecientesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for (id currentObject in nibObjects) {
            if ([currentObject isKindOfClass:[RecientesTableViewCell class]]) {
                cell = (RecientesTableViewCell *)currentObject;
            }
        }
    }
    NSDictionary *item = [self.arrayRecientes objectAtIndex:indexPath.row];

    
    
    NSString *contacto1 = [[NSString alloc] initWithFormat:@"%@ %@",[item objectForKey:@"contacto1_nombre"],[item objectForKey:@"contacto1_contacto"]];
    NSString *contacto2 = [[NSString alloc] initWithFormat:@"%@ %@",[item objectForKey:@"contacto2_nombre"],[item objectForKey:@"contacto2_contacto"]];
    

    cell.contactoNombre.text = contacto1;
    cell.contacto2Nombre.text = contacto2;
    cell.fecha.text = [NSDateFormatter  localizedStringFromDate:[item objectForKey:@"fecha"]   dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];

    
    NSString *imagenTipo = @"";
    if ([[item objectForKey:@"tipo"] isEqualToString:@"1"]) {
        imagenTipo=@"jicanonimoA.png";
    } else if ([[item objectForKey:@"tipo"] isEqualToString:@"2"]) {
        imagenTipo=@"jicconectaA.png";
    } else if ([[item objectForKey:@"tipo"] isEqualToString:@"3"]) {
        imagenTipo=@"jiccelestinaA.png";
    }
    [cell.imageView setImage:[UIImage imageNamed:imagenTipo]];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detalle_recientes_segue"]) {
        NSDictionary * recienteSeleccionado =  [self.arrayRecientes objectAtIndex:self.myTableView.indexPathForSelectedRow.row];
        DetalleRecientesViewController *accionesContactosViewController = (DetalleRecientesViewController *)[segue destinationViewController];
        accionesContactosViewController.reciente = recienteSeleccionado;
        [accionesContactosViewController pintaReciente];
    }
}



@end
