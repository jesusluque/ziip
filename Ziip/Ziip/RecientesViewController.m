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
    
    
    AppDelegate *delegado = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = delegado.managedObjectContext;
    self.arrayRecientes = [CoreDataHelper searchObjectsForEntity:@"Recientes" withPredicate:nil andSortKey:@"id" andSortAscending:false andContext:self.managedObjectContext];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}


-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    self.arrayRecientes = [CoreDataHelper searchObjectsForEntity:@"Recientes" withPredicate:nil andSortKey:@"id" andSortAscending:false andContext:self.managedObjectContext];
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
    Recientes *item = [self.arrayRecientes objectAtIndex:indexPath.row];
    cell.contactoNombre.text = item.contacto_nombre;
    cell.contacto2Nombre.text = item.contacto2_nombre;
    cell.fecha.text = [NSDateFormatter  localizedStringFromDate:item.fecha   dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

    
    NSString *imagenTipo = @"";
    if ([item.accion isEqualToString:@"1"]) {
        imagenTipo=@"jicanonimoA.png";
    } else if ([item.accion isEqualToString:@"2"]) {
        imagenTipo=@"jicconectaA.png";
    } else if ([item.accion isEqualToString:@"3"]) {
        imagenTipo=@"jiccelestinaA.png";
    }
    [cell.imageView setImage:[UIImage imageNamed:imagenTipo]];
    
    return cell;
}


-(void)  tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.recienteSeleccionado =  [self.arrayRecientes objectAtIndex:indexPath.row];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detalle_recientes_segue"]) {
        DetalleRecientesViewController *accionesContactosViewController = (DetalleRecientesViewController *)[segue destinationViewController];
        accionesContactosViewController.reciente = self.recienteSeleccionado;
        [accionesContactosViewController pintaReciente];
    }
}



@end
