//
//  BitmapFont.m
//  Raiders
//
//  Created by James Sugrue on 3/10/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "BitmapFont.h"
#import "Sprite.h"

@interface BitmapFont (private)

- (UIImage *)getSubImageFromRect:(CGRect)rect fullImage:(UIImage *)fullImage;

@end

@implementation BitmapFont

- (id)initWithFontImageNamed:(NSString *)image controlFile:(NSString *)controlFile {
    self = [self init];
	if (self != nil) {
        [self parseFontFile:controlFile imageFileName:image];
    }
    
    return self;
}

#pragma mark - Parse Control File

- (void)parseFontFile:(NSString *)fileName imageFileName:(NSString *)imageFileName {
    //open file and retrieve lines of text
    NSString *contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"fnt"] encoding:NSASCIIStringEncoding error:nil];
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
    
    UIImage *image = [UIImage imageNamed:imageFileName];
    
    for (NSString *line in lines) {
        if ([line hasPrefix:@"char"]) {
            
            NSMutableArray *values = [NSMutableArray array];
            
            if (line.length < 20) continue;
            
            for (int i=0; i < [line length]; i++) {
                if ([line characterAtIndex:i] == [@"=" characterAtIndex:0]) {
                    int idx = i + 1;
                    while ([line characterAtIndex:idx] != [@" " characterAtIndex:0]) {
                        idx++;
                    }
                    
                    [values addObject:[line substringWithRange:NSMakeRange(i + 1, idx - i - 1)]];
                     i = idx;
                }
            }
            
            NSString *charId = [values objectAtIndex:0];
            int x = [[values objectAtIndex:1] intValue];
            int y = [[values objectAtIndex:2] intValue];
            int width = [[values objectAtIndex:3] intValue];
            int height= [[values objectAtIndex:4] intValue];
            
            if (width == 0 && height == 0) continue;
            
            UIImage *fontImage = [self getSubImageFromRect:CGRectMake(x, y, width, height) fullImage:image];
            
            if (fontDictionary == nil)
                fontDictionary = [NSMutableDictionary dictionary];
            
            Sprite *sprite = [[Sprite alloc] initWithImage:fontImage];
            
            [fontDictionary setObject:sprite forKey:charId];
        }        
    }
} 

- (NSArray *)drawTextAtPoint:(NSString *)text point:(CGPoint)point {
    
    NSMutableArray *temp = [NSMutableArray array];
    int offset = 0;
    
    for (int i = 0; i < text.length; i++) {
        NSString *character = [text substringWithRange:NSMakeRange(i, 1)];
        
        int lhs = [character characterAtIndex:0];
        int rhs = [text characterAtIndex:i];
        if ([character isEqualToString:@" "]) {
            offset += 20;
            continue;
        }
        if (lhs == rhs) {
            Sprite *sprite = [fontDictionary objectForKey:[NSString stringWithFormat:@"%d", rhs]];
            Sprite *copy = [sprite copy];
            CGPoint pointWithOffset = CGPointMake(point.x + offset, point.y);
            [copy drawAtPosition:pointWithOffset];
            [temp addObject:copy];
            offset += sprite.width * 0.75;
        }
    }
    
    return [temp copy];
}

             
- (UIImage *)getSubImageFromRect:(CGRect)rect fullImage:(UIImage *)fullImage {
 
    //UIGraphicsBeginImageContext(rect.size);
    int x = 16, y = 16;
    
    if (rect.size.width > 16)
        x = 32;
    if (rect.size.height > 16)
        y = 32;
    
    UIGraphicsBeginImageContext(CGSizeMake(x, y));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, fullImage.size.width, fullImage.size.height);
    
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width * 0.75, rect.size.height * 0.75));
    CGContextScaleCTM(context, 0.75f, 0.75f);
    [fullImage drawInRect:drawRect];
    
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}
             

@end
