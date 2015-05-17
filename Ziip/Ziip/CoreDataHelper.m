


#import "CoreDataHelper.h"


@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end



@implementation CoreDataHelper

#pragma mark - Retrieve objects



//************************************************************************************************************************************
//retorna los distintos
+(NSArray *) searchDistictObjectForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext andKey:(NSString*)key{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    request.entity = entity;
  
    request.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:key]];
    request.returnsDistinctResults = YES;
    request.resultType = NSDictionaryResultType;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    
    NSError *error = nil;
    NSArray *distincResults = [managedObjectContext executeFetchRequest:request error:&error];

    return distincResults;

}


+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext andLimit:(int) limit {
    

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
	if (limit!=0){
        [request setFetchLimit:limit];
    }
	// Execute the fetch request
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	// If the returned array was nil then there was an error
	if (mutableFetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
	
	// Return the results
	return mutableFetchResults;
}



//obtengo los objecto con el uso de los predicados
// Fetch objects with a predicate
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
	
	// Execute the fetch request
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	// If the returned array was nil then there was an error
	if (mutableFetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
	
	// Return the results
	return mutableFetchResults;
}

//obtengo el resultado sin uso de predicados
// Fetch objects without a predicate
+(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self searchObjectsForEntity:entityName withPredicate:nil andSortKey:sortKey andSortAscending:sortAscending andContext:managedObjectContext];
}

#pragma mark - Count objects

// Get a count for an entity with a predicate
+(NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setIncludesPropertyValues:NO];
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// Execute the count request
	NSError *error = nil;
	NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	
	// If the count returned NSNotFound there was an error
	if (count == NSNotFound)
		NSLog(@"Couldn't get count for entity %@", entityName);
	
	// Return the results
	return count;
}

// Get a count for an entity without a predicate
+(NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self countForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

#pragma mark - Delete Objects

// Delete all objects for a given entity
+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
	
	// Delete the objects returned if the results weren't nil
	if (fetchResults != nil) {
		for (NSManagedObject *manObj in fetchResults) {
			[managedObjectContext deleteObject:manObj];
		}
	} else {
		NSLog(@"Couldn't delete objects for entity %@", entityName);
		return NO;
	}
	
	return YES;	
}

+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self deleteAllObjectsForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

@end