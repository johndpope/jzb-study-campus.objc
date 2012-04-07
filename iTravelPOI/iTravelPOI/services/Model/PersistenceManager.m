//
//  PersistenceManager.m
//  iTravelPOI
//
//  Created by JZarzuela on 07/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersistenceManager.h"
#import "JavaStringCat.h"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE CONSTANTS and C-Methods definitions
//---------------------------------------------------------------------------------------------------------------------
#define MAPDATA_SUBFOLDER @"mapData"
#define EXT_MAP_HEADER    @".mapHeader"
#define EXT_MAP_DATA      @".mapData"



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface PersistenceManager()

@property (nonatomic, retain) NSURL *mapDataFolder;

- (NSString *) _calcPersistentID;
- (BOOL)       _saveMapHeader:(MEMap *)map;
- (BOOL)       _saveMapData:(MEMap *)map;
- (MEMap *)    _loadMapFromHeader:(NSString *)mapHeaderFileName;
- (BOOL)       _loadMapData:(MEMap *)map;


@end



//*********************************************************************************************************************
#pragma mark -
#pragma mark Implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation PersistenceManager


@synthesize lastError = _lastError;
@synthesize mapDataFolder = _mapDataFolder;



//*********************************************************************************************************************
#pragma mark -
#pragma mark Initialization & finalization
//---------------------------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_mapDataFolder release];
    
    [super dealloc];
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark CLASS methods
//---------------------------------------------------------------------------------------------------------------------
+ (PersistenceManager *)sharedInstance {
    
	static PersistenceManager *_globalPersistenceManagerInstance = nil;
	static dispatch_once_t _predicate;
	dispatch_once(&_predicate, ^{
        NSLog(@"PersistenceManager - Creating sharedInstance");
        _globalPersistenceManagerInstance = [[self alloc] init];
    });
	return _globalPersistenceManagerInstance;
}

//---------------------------------------------------------------------------------------------------------------------
+ (void) privateClassMethod {
    
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------
- (NSURL *) mapDataFolder {
    
    if(!_mapDataFolder) {
        
        // Limpia el error anterior
        _lastError = nil;
        
        NSFileManager *fileMngr = [NSFileManager defaultManager];
        
        NSURL *appDocDir = [[fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSURL *mapDataDir = [NSURL URLWithString:MAPDATA_SUBFOLDER relativeToURL:appDocDir];
        
        // Comprueba si existe. Si no existe crea la carpeta
        if(![fileMngr fileExistsAtPath:[mapDataDir path]]){
            if(![fileMngr createDirectoryAtURL:mapDataDir withIntermediateDirectories:true attributes:nil error:&_lastError]) {
                NSLog(@"Error creating Map Data subfolder (%@) : %@", mapDataDir, _lastError);
                return nil;
            }
        }
        
        _mapDataFolder = mapDataDir;
    }
    
    return _mapDataFolder;
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) listMapHeaders {
    
    // Limpia el error anterior
    _lastError = nil;
    
    // Chequea que hay una carpeta donde estan almacenados los datos de los mapas
    if(!self.mapDataFolder) {
        return nil;
    }
    
    // Lee el contenido del directorio
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *files = [fileMngr contentsOfDirectoryAtPath:[self.mapDataFolder path] error:&_lastError];
    if(!files) {
        NSLog(@"Error reading content of Map Data subfolder: %@", _lastError);
        return nil;
    }
    
    // Filtra los ficheros de cabecera y carga el mapa asociado
    NSMutableArray *mapList = [NSMutableArray array];
    for(NSString *item in files) {
        if([item hasSuffix:EXT_MAP_HEADER]) {
            MEMap *map = [self _loadMapFromHeader:item];
            if(!map) {
                NSLog(@"Error reading content of Map Header (%@) : %@", item, _lastError);
                return nil;
            } else {
                map.persistentID = @"hola";
                [mapList addObject:map];
            }
        }
    }
    
    return mapList;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) loadMapData:(MEMap *)map {
    
    if(!map.persistentID) {
        _lastError = [NSError errorWithDomain:@"Map doesn't have a persistence ID" code:1000 userInfo:nil];
        return false;
    }
    
    if(![self _loadMapData:map]) {
        NSLog(@"Error loading content of Map Data (%@) : %@", map.name, _lastError);
        return false;
    }
    
    return true;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) saveMap:(MEMap *)map {
    
    if(!map.persistentID) {
        map.persistentID = [self _calcPersistentID];
    }
    
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
    [map writeHeader:headerDict];
    if(![self _saveMapHeader:map]) {
        NSLog(@"Error saving content of Map Header (%@) : %@", map.name, _lastError);
        return false;
    }
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [map writeData:dataDict];
    if(![self _saveMapData:map]) {
        NSLog(@"Error saving content of Map Data (%@) : %@", map.name, _lastError);
        return false;
    }
    
    return true;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) removeMap:(MEMap *)map {
    return false;   
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) _loadMapFromHeader:(NSString *)mapHeaderFileName {
    
    @try {
        NSDictionary *mapHeaderDict = [NSDictionary dictionaryWithContentsOfFile:mapHeaderFileName];
        MEMap *map = [MEMap map];
        [map readHeader:mapHeaderDict];
        
        return map;
    }
    @catch (NSException *exception) {
        _lastError = [NSError errorWithDomain:exception.name code:100 userInfo:exception.userInfo];
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _loadMapData:(MEMap *)map {
    
    @try {
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@", map.persistentID, EXT_MAP_DATA];
        NSURL *mapDataFileURL = [NSURL URLWithString:fileName relativeToURL:self.mapDataFolder];

        NSDictionary *mapDataDict = [NSDictionary dictionaryWithContentsOfURL:mapDataFileURL];
        [map readData:mapDataDict];
        
        return true;
    }
    @catch (NSException *exception) {
        _lastError = [NSError errorWithDomain:exception.name code:100 userInfo:exception.userInfo];
        return false;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _saveMapHeader:(MEMap *)map {
    
    @try {
        
        NSMutableDictionary *mapHeaderDict = [NSMutableDictionary dictionary];
        [map writeHeader:mapHeaderDict];
         
        NSString *fileName = [NSString stringWithFormat:@"%@%@", map.persistentID, EXT_MAP_HEADER];
        NSURL *mapHeaderFileURL = [NSURL URLWithString:fileName relativeToURL:self.mapDataFolder];
        
        [mapHeaderDict writeToURL:mapHeaderFileURL atomically:YES];
        
        return true;
    }
    @catch (NSException *exception) {
        _lastError = [NSError errorWithDomain:exception.name code:100 userInfo:exception.userInfo];
        return false;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _saveMapData:(MEMap *)map {
    
    @try {
        
        NSMutableDictionary *mapDataDict = [NSMutableDictionary dictionary];
        [map writeData:mapDataDict];
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@", map.persistentID, EXT_MAP_DATA];
        NSURL *mapDataFileURL = [NSURL URLWithString:fileName relativeToURL:self.mapDataFolder];
        
        [mapDataDict writeToURL:mapDataFileURL atomically:YES];
        
        return true;
    }
    @catch (NSException *exception) {
        _lastError = [NSError errorWithDomain:exception.name code:100 userInfo:exception.userInfo];
        return false;
    }
    
}

//---------------------------------------------------------------------------------------------------------------------
- (NSUInteger) _getNextIdCounter {
    
    static NSUInteger s_idCounter = 0;
    
    if(s_idCounter==0) {
        srand((unsigned)time(0L));
        s_idCounter = (NSUInteger)rand()%1000;
    }
    return s_idCounter++;
}


//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _calcPersistentID {
    NSUInteger nCounter = [self _getNextIdCounter];
    NSString * pID = [NSString stringWithFormat:@"map-%u-%u", time(0L),nCounter];
    return pID;
}


@end