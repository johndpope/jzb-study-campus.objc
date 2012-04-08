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
- (NSString *) _persistentIDFromFileName:(NSString *)fileName;

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
        
        _mapDataFolder = [[mapDataDir absoluteURL] retain];
    }
    
    return _mapDataFolder;
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark General PUBLIC methods
//---------------------------------------------------------------------------------------------------------------------
- (NSArray *) listMapHeaders {
    
    NSLog(@"PersistenceManager - listMapHeaders");
    
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
                map.persistentID = [self _persistentIDFromFileName:item];
                [mapList addObject:map];
            }
        }
    }
    
    return mapList;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) loadMapData:(MEMap *)map {
    
    NSLog(@"PersistenceManager - loadMapData");
    
    if(!map.persistentID) {
        _lastError = [NSError errorWithDomain:@"Map doesn't have a persistence ID" code:1000 userInfo:nil];
        return false;
    }
    
    if(![self _loadMapData:map]) {
        NSLog(@"Error loading content of Map Data (%@) : %@", map.name, _lastError);
        return false;
    }
    
    map.dataRead = true;
    return true;
    
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) saveMap:(MEMap *)map {
    
    NSLog(@"PersistenceManager - saveMap");
    
    if(!map.persistentID) {
        map.persistentID = [self _calcPersistentID];
    }
    
    if(![self _saveMapHeader:map]) {
        NSLog(@"Error saving content of Map Header (%@) : %@", map.name, _lastError);
        return false;
    }
    
    if(![self _saveMapData:map]) {
        NSLog(@"Error saving content of Map Data (%@) : %@", map.name, _lastError);
        return false;
    }
    
    return true;
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) removeMap:(MEMap *)map {
    
    NSLog(@"PersistenceManager - removeMap");
        
    if(map.persistentID == nil) {
        
        // No fue persistido, luego no hay que borrar nada
        return true;
        
    } else {
        
        NSString *fullFilePath;
        NSURL *mapFileURL;
        
        NSError *errorHeader = nil;
        NSError *errorData = nil;
        BOOL allOK = true;
        
        // Lo elimina del alamacen
        NSFileManager *fileMngr = [NSFileManager defaultManager];
        
        // Borra el fichero de cabecera
        fullFilePath = [NSString stringWithFormat:@"%@/%@%@", self.mapDataFolder, map.persistentID, EXT_MAP_HEADER];
        mapFileURL = [NSURL URLWithString:fullFilePath];
        allOK &= [fileMngr removeItemAtURL:mapFileURL error:&errorHeader];
        
        // Borra el fichero de datos
        fullFilePath = [NSString stringWithFormat:@"%@/%@%@", self.mapDataFolder, map.persistentID, EXT_MAP_DATA];
        mapFileURL = [NSURL URLWithString:fullFilePath];
        allOK &= [fileMngr removeItemAtURL:mapFileURL error:&errorData];
        
        // Si algo fallo se apunta el error
        if(!allOK) {
            _lastError = errorHeader ? errorHeader : errorData;
            NSLog(@"Error removing content of Map Data (%@) : %@", map.name, _lastError);
        }
        
        return allOK;   
    }
}



//*********************************************************************************************************************
#pragma mark -
#pragma mark PRIVATE methods
//---------------------------------------------------------------------------------------------------------------------
- (MEMap *) _loadMapFromHeader:(NSString *)mapHeaderFileName {
    
    @try {
        NSString *fullFileURL = [NSString stringWithFormat:@"%@/%@", self.mapDataFolder, mapHeaderFileName];
        NSURL *mapHeaderFileURL = [NSURL URLWithString:fullFileURL];
        
        NSDictionary *mapHeaderDict = [NSDictionary dictionaryWithContentsOfURL:mapHeaderFileURL];
        if(mapHeaderDict) {
            MEMap *map = [MEMap map];
            [map readHeader:mapHeaderDict];
            return map;
        } else {
            _lastError = [NSError errorWithDomain:@"Error loading map header" code:1000 userInfo:nil];
            return nil;
        }
    }
    @catch (NSException *exception) {
        _lastError = [NSError errorWithDomain:exception.name code:100 userInfo:exception.userInfo];
        return nil;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (BOOL) _loadMapData:(MEMap *)map {
    
    @try {
        
        NSString *fullFileURL = [NSString stringWithFormat:@"%@/%@%@", self.mapDataFolder, map.persistentID, EXT_MAP_DATA];
        NSURL *mapDataFileURL = [NSURL URLWithString:fullFileURL];
        
        NSDictionary *mapDataDict = [NSDictionary dictionaryWithContentsOfURL:mapDataFileURL];
        if(mapDataDict) {
            [map readData:mapDataDict];
        } else {
            _lastError = [NSError errorWithDomain:@"Error loading map data" code:1000 userInfo:nil];
            return false;
        }
        
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
        
        NSString *fullFileURL = [NSString stringWithFormat:@"%@/%@%@", self.mapDataFolder, map.persistentID, EXT_MAP_HEADER];
        NSURL *mapHeaderFileURL = [NSURL URLWithString:fullFileURL];
        
        if(![mapHeaderDict writeToURL:mapHeaderFileURL atomically:YES]) {
            _lastError = [NSError errorWithDomain:@"Error writing map header" code:1000 userInfo:nil];
            return false;
        }
        
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
        
        NSString *fullFileURL = [NSString stringWithFormat:@"%@/%@%@", self.mapDataFolder, map.persistentID, EXT_MAP_DATA];
        NSURL *mapDataFileURL = [NSURL URLWithString:fullFileURL];
        
        if(![mapDataDict writeToURL:mapDataFileURL atomically:YES]) {
            _lastError = [NSError errorWithDomain:@"Error writing map data" code:1000 userInfo:nil];
            return false;
        }
        
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
- (NSString *) _persistentIDFromFileName:(NSString *)fileName {
    
    NSString * pID = [fileName subStrFrom:0 to:[fileName length]-[EXT_MAP_HEADER length]];
    return pID;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSString *) _calcPersistentID {
    NSUInteger nCounter = [self _getNextIdCounter];
    NSString * pID = [NSString stringWithFormat:@"map-%u-%u", time(0L),nCounter];
    return pID;
}


@end