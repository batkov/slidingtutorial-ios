//
//  PRLElementView.h
//  Parallax
//
//  Created by VLADISLAV KIRIN on 10/5/15.
//  Copyright (c) 2015 Cleveroad Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

extern CGFloat const kHeightSkipView;
typedef NS_ENUM(NSInteger, PRLElementType) {
    PRLElementTypeImage,
    PRLElementTypeText,
};

@interface PRLElementView : UIView

@property (nonatomic, readonly) CGFloat slippingCoefficient;
@property (nonatomic, readonly) CGFloat offsetX;
@property (nonatomic, readonly) CGFloat offsetY;
@property (nonatomic, readonly) NSInteger pageNumber;
@property (nonatomic, readonly) NSString *imageName;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) PRLElementType type;

- (instancetype)initWithImageName:(NSString *)imageName
                          offsetX:(CGFloat)offsetX
                          offsetY:(CGFloat)offsetY
                       pageNumber:(NSInteger)pageNumber
              slippingCoefficient:(CGFloat)slippingCoefficient
                 scaleCoefficient:(CGFloat)scaleCoefficient
                   loggingEnabled:(BOOL)loggingEnabled;

- (instancetype)initWithTitle:(NSString *)title
                      offsetX:(CGFloat)offsetX
                      offsetY:(CGFloat)offsetY
                   pageNumber:(NSInteger)pageNumber
          slippingCoefficient:(CGFloat)slippingCoefficient
             scaleCoefficient:(CGFloat)scaleCoefficient
               loggingEnabled:(BOOL)loggingEnabled;

@end
