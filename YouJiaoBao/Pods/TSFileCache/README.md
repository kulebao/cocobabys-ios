TSFileCache
========
`TSFileCache` is a simple generic class used to cache some sort of files on the disk - files that will be used later as e.g. icons in the cells of the table view, etc.


Donate
=========
If you like it... :)

<a href="https://flattr.com/submit/auto?user_id=tomkowz&url=http%3A%2F%2Fgithub.com%2Ftomkowz%2FTSFileCache" target="_blank"><img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a>


How it works?
=========
You create instance of a class by one of two designed initializers. You can create cache that uses some directory with method `cacheForURL:` but you can also (and I recommend that option) you method `cacheInTemporaryDirectoryWithRelativeURL:` which uses directory inside sandbox's temporary directory which is managed by system so you can forget about cleaning this directory.

#### `+cacheForURL:`
    NSURL *directoryURL = [NSURL fileURLWithPath:...];
	TSFileCache *cache = [TSFileCache cacheForURL:directoryURL];
	
#### `+cacheInTemporaryDirectoryWithRelativeURL:`
	NSURL *url = [NSURL URLWithString:@"/Cache"];
	TSFileCache *cache = [TSFileCache cacheInTemporaryDirectoryWithRelativeURL:url];

After instance is created you have to call `prepare:` method. It prepares directory to work with files. If directory exists it do nothing, but if directory doesn't exists it try to create and return error if false (It's recommend to pass NSError object to the method parameter).

##### `-prepare:`
    TSFileCache *cache = [TSFileCache cacheInTemporaryDirectoryWithRelativeURL:[NSURL URLWithString:@"/Cache"]];
    
    NSError *error = nil;
	[cache prepare:&error];
	if (error) {
		/// do something here
	}

Instance may be set as singleton via `setSharedInstance:` method and get by `sharedInstance`. You have to now that `sharedInstance` method does not create any instance of `TSFileCache` class - it simply return instance that has been set earlier by `setSharedInstance`, otherwise nil.

#### `+setSharedInstance:`
    TSFileCache *cache = [TSFileCache cacheInTemporaryDirectoryWithRelativeURL:[NSURL URLWithString:@"/Cache/Icons"]];
    [TSFileCache setSharedInstance:cache]; /// set

#### `+sharedInstance`
	TSFileCache fileCache = [TSFileCache sharedInstance];

When instance is configured use `storeData:forKey:` to store data on disk, key is used as filename. If file for key exists file will be overwritten.
To read data for key use `dataForKey:` method. If file for key doesn't exists nil will be returned.

#### `-storeData:forKey:`
    UIImage *image = [UIImage imageNamed:@"image.png"];
    NSData *data = UIImagePNGRepresentation(image);
    [cache storeData:data forKey:@"key"];    
    
#### `-dataForKey:`
    NSData *data = [cache dataForKey:@"key"];
    

If you want to check if key is set and if file for this key is cached already use `existsDataForKey:` method instead of `dataForKey:`. The reason for that is that you may don't know how big is the cached file and it might take a lot of time to read this file. Instead there is only simply check if file exists.

#### `-storeDataForUndefinedKey:`
    NSString *key = [cache storeDataForUndefinedKey:data];

You can also use method `-storeDataForUndefinedKey:` to store data if you don't know key with which data should be stored. The key will be generated and returned by method. Key is unique.

#### `-removeDataForKey:`
    [cache removeDataForKey:key];
    
To remove cached file call `removeDataForKey`.

    
#### `-existsDataForKey:`
	BOOL exists = [cache existsDataForKey:@"key"];

`TSFileCache` works also as a dictionary so you can do something like this:

	NSData *data = ...;
	_cache[key] = data; /// instead of [_cache storeData:data forKey:key];
	id readData = _cache[key]; /// instead of [_cache dataForKey:key];
	
If you want to subclass `TSFileCache` and want to use this mechanism with other type than *NSData* you have to create the same methods but with other types - Check example.

`TSFileCache` is using `NSCache` internally so when data is read first time value for this key is stored in `NSCache` and next time if data is still in the cache it will be used rather than reading again from the disk. System controlls `NSCache` instance and data can be removed from the cache anytime, and if you want to read again this data which was cached and now it is not `TSFileCache` will read this data from the disk and caches it again.

If you want to clear directory when files are cached use `clear` method. Directory will be still there but it will be empty.

#### `-clear`
    [cache clear];

I also added some macro which may be helpful during subclassing because probably some method will be not necessary to be available in the subclass. I use this macro with `TSImageCache` example in this repo. This macro is using `__attribute__(unavailable(...))` and prevents before calling method which should not be called on the subclass of `TSFileCache`. Macro is defined as `__TSFileCacheUnavailable__` and here is simple use of this:

    + (instancetype)cacheInTemporaryDirectoryWithRelativeURL:(NSURL *)relativeURL __TSFileCacheUnavailable__;
    
#### `-allKeys`
	NSArray *keys = [cache allKeys];
	
Use `allKeys` method to get all keys inside cache directory.

#### `-attributesOfFileForKey:error:`
    NSDictionary *attributes = [_fileCache attributesOfFileForKey:key error:nil];

Use this method to get attributes of cached files.
    
  
CocoaPods
=========
Class is available via the [CocoaPods](http://cocoapods.org).

    pod 'TSFileCache', '~> 1.0.4'
    
Logs
=====
**1.0.4**:

- `cache` is now exposed as `readonly` property. Was private ivar. It has been exposed because of performance issues. Sometimes is better to store e.g. UIImage in cache instead of NSData and convert this NSData every time to UIImage. Please familiarize at *TSImageCache* example.


**1.0.3**:

- added `-removeDataForKey:` method.


**1.0.2**:

- implemented `-storeDataForUndefinedKey:` method.

- `-prepare:` method returns BOOL, earlier was void. It's because static code analyse warnings.

- implemented `-allKeys` method.

- implemented `-attributesOfFileForKey:error:`.


**1.0.1**:

- implemented subscripting. *TSFileCache* instance works as dictionary. instance[@"key"]; id data = instance[@"key"];

- added `existsDataForKey:` method to obtain if value for specified key exists. Added because of performance.

- `directoryURL` property is not exposed as readonly (was hidden, but it may be useful to know path to directory with cached files),

**1.0**:

- *TSFileCache* released.    

License
======

TSFileCache is available under the Apache 2.0 license.

Copyright © 2014 Tomasz Szulc

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
