//
//  PointListViewController.m
//  iTravelPoint-iOS
//
//  Created by Jose Zarzuela on 22/12/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#define __PointListViewController__IMPL__
#import <CoreLocation/CoreLocation.h>
#import "PointListViewController.h"
#import "PointListViewCell.h"
#import "MPoint.h"
#import "MIcon.h"





//*********************************************************************************************************************
#pragma mark -
#pragma mark Private Enumerations & definitions
//*********************************************************************************************************************
#define MIN_GPS_DISTANCE_PRECISION   +50
#define LOCATION_TIMER_INTERVAL      60.0


//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//*********************************************************************************************************************
@interface PointListViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UITableView        *pointsTable;

@property (strong, nonatomic) UIView                    *tableAccesoryView;

@property (strong, nonatomic) NSIndexPath               *prevSelIndexPath;

@property (strong, nonatomic) CLLocationManager         *locationManager;
@property (strong, nonatomic) NSTimer                   *timer;

@property (strong, nonatomic) NSNumberFormatter         *distanceFormatterMeters;
@property (strong, nonatomic) NSNumberFormatter         *distanceFormatterKm;

@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//*********************************************************************************************************************
@implementation PointListViewController


@synthesize dataSource = _dataSource;


//=====================================================================================================================
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------



//=====================================================================================================================
#pragma mark -
#pragma mark Public methods
//---------------------------------------------------------------------------------------------------------------------
- (id) pointListWillChange {
    
    // "Recuerda" el ID del primer punto visible en la tabla
    NSArray *visibleRows = self.pointsTable.indexPathsForVisibleRows;
    NSIndexPath *index = visibleRows.count<=0 ? nil : [visibleRows objectAtIndex:0];
    if(index) {
        MPoint *point = (MPoint *)[self.dataSource.pointList objectAtIndex:[index indexAtPosition:1]];
        return point.objectID;
    } else {
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) pointListDidChange:(id)prevInfo {

    // Actualiza el valor de indice del elemento seleccionado acorde a los cambios
    NSUInteger index = [self.dataSource.pointList indexOfObject:self.dataSource.selectedPoint];
    if(index!=NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        self.prevSelIndexPath = indexPath;
    } else {
        self.prevSelIndexPath = nil;
        self.dataSource.selectedPoint = nil;
    }
    
    // Recarga la informacion
    [self.pointsTable reloadData];

    // Calcula el ID del punto que debe quedar visible
    MPointID *pointToShowID = self.dataSource.selectedPoint ? self.dataSource.selectedPoint.objectID : (MPointID *)prevInfo;

    // Muestra la fila previa si existe aun
    [self scrollToShowPoint:pointToShowID selectRow:FALSE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) startMultiplePointSelection {
    
    [self.pointsTable beginUpdates];
    
    // Elimina las marcas previas que pudiesen haber quedado en las celdas visibles antes de poner la tabla en edicion
    for (NSIndexPath *path in [self.pointsTable indexPathsForVisibleRows]) {
        PointListViewCell *cell = (PointListViewCell *)[self.pointsTable cellForRowAtIndexPath:path];
        cell.checked = FALSE;
    }

    // Mientras esta editando elimina no hay elemento seleccionado
    [self setSelectedPointAndPath:nil];
    
    // Pone la tabla en edicion de forma animada
    [self.pointsTable setEditing:TRUE animated:TRUE];
    
    [self.pointsTable endUpdates];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) doneMultiplePointSelection {
    [self.pointsTable setEditing:FALSE animated:TRUE];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) refreshSelectedPoint {
    
    [self.pointsTable reloadData];
    
    NSUInteger index = [self.dataSource.pointList indexOfObject:self.dataSource.selectedPoint];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if(![self.prevSelIndexPath isEqual:indexPath] && (self.prevSelIndexPath!=nil || index!=NSNotFound)) {
        [self tableView:self.pointsTable willSelectRowAtIndexPath:(index!=NSNotFound?indexPath:self.prevSelIndexPath)];
    }

    if(self.dataSource.selectedPoint) {
        
        [self scrollToShowPoint:self.dataSource.selectedPoint.objectID selectRow:TRUE];
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UIViewController> superclass methods
//---------------------------------------------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib
    self.tableAccesoryView = [self createTableAccesoryView];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // En metros
    self.locationManager.distanceFilter = MIN_GPS_DISTANCE_PRECISION; // En metros

    // Formateador para las distancias de los puntos
    self.distanceFormatterMeters = [[NSNumberFormatter alloc] init];
    [self.distanceFormatterMeters setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.distanceFormatterMeters setMaximumFractionDigits:0];
    [self.distanceFormatterMeters setRoundingMode:NSNumberFormatterRoundHalfUp];
    [self.distanceFormatterMeters setPositiveFormat:@"#,##0 m"];
    
    self.distanceFormatterKm = [[NSNumberFormatter alloc] init];
    [self.distanceFormatterKm setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.distanceFormatterKm setMaximumFractionDigits:2];
    [self.distanceFormatterKm setRoundingMode:NSNumberFormatterRoundHalfUp];
    [self.distanceFormatterKm setPositiveFormat:@"#,##0.# Km"];

}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.locationManager startUpdatingLocation];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self refreshSelectedPoint];
}

//---------------------------------------------------------------------------------------------------------------------
- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self.locationManager stopUpdatingLocation];
    [self.timer invalidate];
    self.timer = nil;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




//=====================================================================================================================
#pragma mark -
#pragma mark <IBAction> outlet methods
//---------------------------------------------------------------------------------------------------------------------
- (void)cellBtnOpenInAction:(UIButton *)sender {
    
    if(self.dataSource.selectedPoint) {
        [self.dataSource openInExternalApp:self.dataSource.selectedPoint];
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void)cellBtnEditAction:(UIButton *)sender {
    
    if(self.dataSource.selectedPoint) {
        [self.dataSource editPoint:self.dataSource.selectedPoint];
    }
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDelegate> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Inhibe que las filas se puedan borrar pasando el dedo
    return UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(tableView.isEditing || ![indexPath isEqual:self.prevSelIndexPath]) {
        return 76;//76;
    } else {
        return 102;//112;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if(tableView.isEditing) {
        
        MPoint *itemToShow = (MPoint *)[self.dataSource.pointList objectAtIndex:[indexPath indexAtPosition:1]];
        if([self.dataSource.checkedPoints containsObject:itemToShow.objectID]) {
            [self.dataSource.checkedPoints removeObject:itemToShow.objectID];
        } else {
            [self.dataSource.checkedPoints addObject:itemToShow.objectID];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        
        [tableView beginUpdates];
        
        BOOL sameIndexPath = [indexPath compare:self.prevSelIndexPath]==NSOrderedSame;
        
        if(!self.prevSelIndexPath || sameIndexPath) {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView reloadRowsAtIndexPaths:@[indexPath,self.prevSelIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        [self setSelectedPointAndPath:sameIndexPath ? nil : indexPath];
        
        [tableView endUpdates];
    }

    return nil;
    
}



//=====================================================================================================================
#pragma mark -
#pragma mark <UITableViewDataSource> protocol methods
//---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.pointList.count;
}

//---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myViewCellID = @"myViewCellID";

    PointListViewCell *cell = (PointListViewCell *)[tableView dequeueReusableCellWithIdentifier:myViewCellID];
    if (cell == nil) {
        cell = [[PointListViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    MPoint *itemToShow = (MPoint *)[self.dataSource.pointList objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.textLabel.text = itemToShow.name;
    cell.detailTextLabel.text = itemToShow.viewStringDistance;
    cell.imageView.image = itemToShow.icon.image;

    if(tableView.isEditing) {

        cell.checked = [self.dataSource.checkedPoints containsObject:itemToShow.objectID];

    } else {
        
        if([indexPath isEqual:self.prevSelIndexPath]) {
            cell.accessoryView = self.createTableAccesoryView;
        } else {
            cell.accessoryView = nil;
        }
        
    }
    
    return cell;
}


// =====================================================================================================================
#pragma mark -
#pragma mark <CLLocationManagerDelegate> protocol methods
// ---------------------------------------------------------------------------------------------------------------------
// Our location updates are sent here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    // Actualiza la información si ha habido un cambio importante de posicion
    CLLocationDistance dist = [newLocation distanceFromLocation:oldLocation];
    if(!oldLocation || dist>=MIN_GPS_DISTANCE_PRECISION) {
        [self updatePointsDistanceWithLocation:newLocation];
    }
    
    // Si la precision ya es buena, para el uso del GPS y estableciendo 2 minutos para activarlo de nuevo
    if(newLocation && newLocation.horizontalAccuracy<=MIN_GPS_DISTANCE_PRECISION) {
        [self.locationManager stopUpdatingLocation];
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_TIMER_INTERVAL
                                                      target:self selector:@selector(locationTimerFired:)
                                                    userInfo:nil
                                                     repeats:FALSE];
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// Any errors are sent here
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [self updatePointsDistanceWithLocation:nil];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void) locationTimerFired:(NSTimer *)sender {

    [self.locationManager startUpdatingLocation];
}



//=====================================================================================================================
#pragma mark -
#pragma mark Private methods
//---------------------------------------------------------------------------------------------------------------------
- (UIView *) createTableAccesoryView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 42, 90)];
    
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeInfoLight];
    btnEdit.frame = CGRectMake(0, 0, 42, 42);
    btnEdit.imageView.contentMode = UIViewContentModeCenter;
    [btnEdit addTarget:self action:@selector(cellBtnEditAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnEdit];
    
    UIButton *btnOpenIn = [UIButton buttonWithType:UIButtonTypeSystem];
    btnOpenIn.frame = CGRectMake(0, 48, 42, 42);
    [btnOpenIn setImage:[UIImage imageNamed:@"tbar-share"] forState:UIControlStateNormal];
    btnOpenIn.imageView.contentMode = UIViewContentModeCenter;
    [btnOpenIn addTarget:self action:@selector(cellBtnOpenInAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnOpenIn];
    
    return view;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) scrollToShowPoint:(MPointID *)pointToShowID selectRow:(BOOL)selectRow {
    
    for(int n=0;n<self.dataSource.pointList.count;n++) {

        MPoint *point = self.dataSource.pointList[n];
        
        if([point.objectID isEqual:pointToShowID]) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n inSection:0];
            
            if(![self.pointsTable.indexPathsForVisibleRows containsObject:indexPath]) {
                [self.pointsTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
            }
            
            if(selectRow) {
                [self.pointsTable selectRowAtIndexPath:indexPath animated:FALSE scrollPosition:UITableViewScrollPositionNone];
            }
            
            break;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (void) setSelectedPointAndPath:(NSIndexPath *)indexPath {
    
    self.prevSelIndexPath = indexPath;
    
    if(!indexPath) {
        self.dataSource.selectedPoint = nil;
    } else {
        MPoint *selectedPoint = (MPoint *)[self.dataSource.pointList objectAtIndex:[self.prevSelIndexPath indexAtPosition:1]];
        self.dataSource.selectedPoint = selectedPoint;
    }

}

//---------------------------------------------------------------------------------------------------------------------
- (void) updatePointsDistanceWithLocation:(CLLocation *)location {
    
    // Actualiza la distancia a visualizar del punto con respecto a la nueva localizacion
    for(MPoint *point in self.dataSource.pointList) {
        
        if(!location) {
            point.viewDistance = 0;
            point.viewStringDistance = nil;
        } else {
            CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
            point.viewDistance = [location distanceFromLocation:pointLocation];
            if(point.viewDistance<10000) {
                NSNumber *number = [NSNumber numberWithDouble:point.viewDistance];
                point.viewStringDistance = [self.distanceFormatterMeters stringFromNumber:number];
            } else {
                NSNumber *number = [NSNumber numberWithDouble:point.viewDistance/1000.0];
                point.viewStringDistance = [self.distanceFormatterKm stringFromNumber:number];
            }
        }
        
    }
    
    // Reordena los puntos con la nueva informacion
    [self.dataSource resortPoints];
    
    // Actualiza la informacion en la tabla
    [self.pointsTable reloadData];

}

@end
