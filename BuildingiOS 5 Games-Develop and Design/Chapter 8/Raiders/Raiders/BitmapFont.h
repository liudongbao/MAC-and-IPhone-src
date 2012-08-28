//
//  BitmapFont.h
//  Raiders
//
//  Created by James Sugrue on 3/10/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitmapFont : NSObject {
    NSMutableDictionary *fontDictionary;
}

- (id)initWithFontImageNamed:(NSString *)image controlFile:(NSString *)controlFile;

- (void)parseFontFile:(NSString *)fileName imageFileName:(NSString *)imageFileName;

- (NSArray *)drawTextAtPoint:(NSString *)text point:(CGPoint)point;

@end
