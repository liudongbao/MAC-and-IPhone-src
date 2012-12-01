//
//  ImageCache.h
//  IVBricker
//
//  Created by PJ Cabrera on 1/12/10.
//  Copyright 2010 PJ Cabrera. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCache : NSObject {

}

+ (UIImage*)loadImage:(NSString*)imageName;
+ (void)releaseCache;

@end
