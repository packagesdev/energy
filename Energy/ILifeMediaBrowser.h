
#import <Foundation/Foundation.h>

@interface ILPluginManager : NSObject

+ (id)sharedPluginManager;

- (NSArray *)allPlugins;

- (id)pluginForIdentifier:(NSString *)inIdentifier forceLoad:(BOOL)inForceLoad;

@end

@interface ILMediaManager : NSObject

- (BOOL)canLoadData;

- (NSString *)pluginIdentifier;

@end
