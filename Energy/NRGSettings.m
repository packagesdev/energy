/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NRGSettings.h"

#import "ScreenSaverModule.h"
#import "ScreenSaverModules.h"

NSString * const NRGUserDefaultsLimitedPowerModuleNameKey=@"limitedPowerModuleName";

NSString * const NRGUserDefaultsLimitedPowerModuleStyleIDKey=@"limitedPowerModuleStyleID";

NSString * const NRGUserDefaultsUnlimitedPowerModuleNameKey=@"unlimitedPowerModuleName";

NSString * const NRGUserDefaultsUnlimitedPowerModuleStyleIDKey=@"unlimitedPowerModuleStyleID";

@implementation NRGSettings

- (id)initWithDictionaryRepresentation:(NSDictionary *)inDictionary
{
	self=[super init];
	
	if (self!=nil)
	{
		NSString * tString=inDictionary[NRGUserDefaultsLimitedPowerModuleNameKey];
		
		if (tString==nil)
		{
			[self resetSettings];
		}
		else
		{
			_limitedPowerModuleName=inDictionary[NRGUserDefaultsLimitedPowerModuleNameKey];
			_limitedPowerModuleStyleID=inDictionary[NRGUserDefaultsLimitedPowerModuleStyleIDKey];
			
            _unlimitedPowerModuleName=inDictionary[NRGUserDefaultsUnlimitedPowerModuleNameKey];
			_unlimitedPowerModuleStyleID=inDictionary[NRGUserDefaultsUnlimitedPowerModuleStyleIDKey];
		}
		
		return self;
	}
	
	return nil;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary * tMutableDictionary=[NSMutableDictionary dictionary];
	
	if (tMutableDictionary!=nil)
	{
		if (self.limitedPowerModuleName!=nil)
            tMutableDictionary[NRGUserDefaultsLimitedPowerModuleNameKey]=self.limitedPowerModuleName;
		
		if (self.limitedPowerModuleStyleID!=nil)
			tMutableDictionary[NRGUserDefaultsLimitedPowerModuleStyleIDKey]=self.limitedPowerModuleStyleID;
		
        if (self.unlimitedPowerModuleName!=nil)
            tMutableDictionary[NRGUserDefaultsUnlimitedPowerModuleNameKey]=self.unlimitedPowerModuleName;
		
		if (self.unlimitedPowerModuleStyleID!=nil)
			tMutableDictionary[NRGUserDefaultsUnlimitedPowerModuleStyleIDKey]=self.unlimitedPowerModuleStyleID;
	}
	
	return [tMutableDictionary copy];
}

#pragma mark -

- (void)resetSettings
{
	self.limitedPowerModuleName=[[ScreenSaverModules sharedInstance] basicModuleName];	// "Computer Name" at the time of this writing
	self.limitedPowerModuleStyleID=nil;
	
	
    self.unlimitedPowerModuleName=[ScreenSaverModule defaultModuleName];				// "Flurry" sometimes
	self.unlimitedPowerModuleStyleID=nil;
}

@end
