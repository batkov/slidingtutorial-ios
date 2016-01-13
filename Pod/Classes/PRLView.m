//
//  PRLView.m
//  Parallax
//
//  Created by VLADISLAV KIRIN on 10/9/15.
//  Copyright (c) 2015 Cleveroad Inc. All rights reserved.
//

#import "PRLView.h"
#import "PRLElementView.h"
#import <QuartzCore/QuartzCore.h>

@interface PRLView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *skipView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *arrayOfElements;
@property (nonatomic, strong) NSMutableArray *arrayOfBackgroundColors;
@property (nonatomic, strong) NSMutableArray *arrayOfPages;

@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) CGFloat lastScreenWidth;
@property (nonatomic, assign) CGFloat scaleCoefficient;

@property (nonatomic, assign) CGFloat doneOffsetX;
@property (nonatomic, assign) CGFloat doneOffsetY;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation PRLView

#pragma mark - Public

- (instancetype)initWithPageCount:(NSInteger)pageCount
                 scaleCoefficient:(CGFloat)scaleCoefficient;
{
    return [self initWithPageCount:pageCount
                  scaleCoefficient:scaleCoefficient
                    loggingEnabled:NO];
}

- (instancetype)initWithPageCount:(NSInteger)pageCount
                 scaleCoefficient:(CGFloat)scaleCoefficient
                   loggingEnabled:(BOOL)loggingEnabled;
{
    if (pageCount <= 0) {
        if (loggingEnabled) {
            NSLog(@"PRLView: Wrong page count %li. It should be at least 1", (long)pageCount);
        }
        return nil;
    }
    
    if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
        self.clipsToBounds = YES;
        self.loggingEnabled = loggingEnabled;
        self.arrayOfElements = [NSMutableArray new];
        self.arrayOfPages = [NSMutableArray new];
        self.arrayOfBackgroundColors = [NSMutableArray new];
        [self.arrayOfBackgroundColors addObject:[UIColor whiteColor]];
        self.lastScreenWidth = 0;
        self.scaleCoefficient = scaleCoefficient;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * pageCount, SCREEN_HEIGHT)];
        [self addSubview:self.scrollView];
        
        for (int i = 0; i < pageCount; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kHeightSkipView)];
            [self.arrayOfPages addObject:view];
            [self.scrollView addSubview:view];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return  self;
}

- (void)addElementWithName:(NSString *)elementName
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
       slippingCoefficient:(CGFloat)slippingCoefficient
                   pageNum:(NSInteger)pageNum;
{
    if (pageNum >= self.arrayOfPages.count || pageNum < 0) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Wrong page number %lu Range of pages should be from 0 to %u", (long)pageNum, self.arrayOfPages.count -1);
        }
        return;
    }
    
    PRLElementView *viewSlip = [[PRLElementView alloc] initWithImageName:elementName
                                                                 offsetX:offsetX
                                                                 offsetY:offsetY
                                                              pageNumber:pageNum
                                                     slippingCoefficient:slippingCoefficient
                                                        scaleCoefficient:self.scaleCoefficient
                                                          loggingEnabled:self.loggingEnabled];
    if (viewSlip) {
        [self.arrayOfPages[pageNum] addSubview:viewSlip];
        [self.arrayOfElements addObject:viewSlip];
    }
}

- (void)addElementWithTitle:(NSString *)title
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
        slippingCoefficient:(CGFloat)slippingCoefficient
                    pageNum:(NSInteger)pageNum;
{
    
    if (pageNum >= self.arrayOfPages.count || pageNum < 0) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Wrong page number %lu Range of pages should be from 0 to %u", (long)pageNum, self.arrayOfPages.count -1);
        }
        return;
    }
    
    PRLElementView *viewSlip = [[PRLElementView alloc] initWithTitle:title
                                                             offsetX:offsetX
                                                             offsetY:offsetY
                                                          pageNumber:pageNum
                                                 slippingCoefficient:slippingCoefficient
                                                    scaleCoefficient:self.scaleCoefficient
                                                      loggingEnabled:self.loggingEnabled];
    if (viewSlip) {
        [self.arrayOfPages[pageNum] addSubview:viewSlip];
        [self.arrayOfElements addObject:viewSlip];
    }
}

- (void)addDoneWithTitle:(NSString *)title
                 offsetX:(CGFloat)offsetX
                 offsetY:(CGFloat)offsetY {
    if (self.doneButton) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Done button already added. Changing offset and text");
        }
    } else {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 140, 60)];
        [button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1].CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        self.doneButton = button;
        [self addSubview:self.doneButton];
    }
    self.doneOffsetX = offsetX;
    self.doneOffsetY = offsetY;
    [self.doneButton setTitle:title forState:UIControlStateNormal];
    self.doneButton.center = CGPointMake(SCREEN_WIDTH / 2 + offsetX, SCREEN_HEIGHT / 2 + offsetY);
}

- (void)addBackgroundColor:(UIColor *)color;
{
    [self.arrayOfBackgroundColors insertObject:color atIndex:self.arrayOfBackgroundColors.count -1];
}

- (void)prepareForShow;
{
    [self createSkipView];
    [self updateDoneButtonVisibility];
    if (self.arrayOfBackgroundColors.count -1 < self.arrayOfPages.count) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Wrong count of background colors. Should be %lu instead of %u", (unsigned long)self.arrayOfPages.count, self.arrayOfBackgroundColors.count -1);
            NSLog(@"PRLView: The missing colors will be replaced by white");
        }
        while (self.arrayOfBackgroundColors.count < self.arrayOfPages.count) {
            [self.arrayOfBackgroundColors addObject:[UIColor whiteColor]];
        }
    }
    
    UIColor *mixedColor = [self colorWithFirstColor:self.arrayOfBackgroundColors[0]
                                        secondColor:self.arrayOfBackgroundColors[1]
                                             offset:0];
    [self.scrollView setBackgroundColor:mixedColor];
}

- (void)createSkipView;
{
    UIView *skipView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kHeightSkipView, SCREEN_WIDTH, kHeightSkipView)];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH *2, 1)];
    [lineView setBackgroundColor:[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1]];
    [skipView addSubview:lineView];
    
    UIPageControl *pageControl = [UIPageControl new];
    pageControl.numberOfPages = [self.arrayOfPages count];
    pageControl.center = CGPointMake(SCREEN_WIDTH / 2, kHeightSkipView /2);
    [skipView addSubview:pageControl];
    self.pageControl = pageControl;
    
    self.skipView = skipView;
    NSString *skipTitle = nil;
    if ([self.delegate respondsToSelector:@selector(skipButtonTitleForView:)]) {
        skipTitle = [self.delegate skipButtonTitleForView:self];
    }
    if (!skipTitle) {
        skipTitle = @"Skip";
    }
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 70, 40)];
    [button setTitle:skipTitle forState:UIControlStateNormal];
    [button addTarget:self action:@selector(skipPressed:) forControlEvents:UIControlEventTouchUpInside];
    [skipView addSubview:button];
    [self addSubview:skipView];
}

- (void) updateDoneButtonVisibility;
{
    if (!self.doneButton) {
        return;
    }
    self.doneButton.alpha = [self lastPageVisibility];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    CGFloat contentOffset = self.scrollView.contentOffset.x;
    for (PRLElementView *view in self.arrayOfElements) {
        CGFloat offset = (self.lastContentOffset - contentOffset) * view.slippingCoefficient;
        [view setFrame:CGRectMake(view.frame.origin.x + offset, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    }
    
    self.lastContentOffset = contentOffset;
    NSInteger pageNum =  [self getCurrentPageNumber];
    
    UIColor *mixedColor = [self colorWithFirstColor:self.arrayOfBackgroundColors[pageNum]
                                        secondColor:self.arrayOfBackgroundColors[pageNum +1]
                                             offset:scrollView.contentOffset.x];
    [scrollView setBackgroundColor:mixedColor];
    
    self.pageControl.currentPage = lround(self.scrollView.contentOffset.x / (self.scrollView.contentSize.width / self.pageControl.numberOfPages));
    [self updateDoneButtonVisibility];
}

#pragma mark - Private

- (NSInteger) getCurrentPageNumber;
{
    NSInteger pageNum =  floorf(self.scrollView.contentOffset.x / SCREEN_WIDTH);
    if (pageNum < 0) {
        pageNum = 0;
    }
    if (pageNum > self.arrayOfBackgroundColors.count - 2) {
        pageNum = self.arrayOfBackgroundColors.count - 2;
    }
    return pageNum;
}

- (CGFloat) lastPageVisibility;
{
    NSInteger lastPageIndex = self.arrayOfBackgroundColors.count - 2;
    CGFloat pageNum = (self.scrollView.contentOffset.x / SCREEN_WIDTH);
    if (pageNum > lastPageIndex - 1 && pageNum <= lastPageIndex + 1) {
        return 1.f - fabs(lastPageIndex - pageNum);
    }
    return 0;
}

- (UIColor *)colorWithFirstColor:(UIColor *)firstColor
                     secondColor:(UIColor *)secondColor
                          offset:(CGFloat)offset;
{
    CGFloat red1, green1, blue1, alpha1;
    CGFloat red2, green2, blue2, alpha2;
    [firstColor  getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [secondColor getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    CGFloat redDelta = red2 - red1;
    CGFloat greenDelta = green2 - green1;
    CGFloat blueDelta = blue2 - blue1;
    
    offset = fmod(offset, SCREEN_WIDTH);
    CGFloat resultRed = redDelta * (offset / SCREEN_WIDTH) + red1;
    CGFloat resultGreen = greenDelta * (offset / SCREEN_WIDTH) + green1;
    CGFloat resultBlue = blueDelta * (offset / SCREEN_WIDTH) + blue1;
    
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:1];
}

- (void)deviceOrientationChanged:(NSNotification *)notification;
{
    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat screenHeight = SCREEN_HEIGHT;
    if (self.loggingEnabled) {
        BOOL isDeviceLandscape = UIDeviceOrientationIsPortrait([notification.object orientation]);
        BOOL isStatusLandscape = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
        NSLog(@"PRLView: DetectedOrientationChange: %@", isDeviceLandscape ? @"Portrait" : @"Landscape");
        NSLog(@"PRLView: Current StatusBarOrientation: %@", isStatusLandscape ? @"Portrait" : @"Landscape");
        NSLog(@"PRLView: screenWidth: %.0f, screenHeight: %.0f", screenWidth, screenHeight);
    }
    if (self.lastScreenWidth == 0) { //first launch setup
        self.lastScreenWidth = screenWidth;
    }
    self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    NSInteger currentPageNum = self.scrollView.contentOffset.x / self.lastScreenWidth;
    [self setBackgroundColor:self.scrollView.backgroundColor];
    [self.scrollView setContentOffset:CGPointMake(0, 0)]; //fix problem with inapropriate elements transtion
    [self.scrollView setFrame:[UIScreen mainScreen].bounds];
    [self.scrollView setContentSize:CGSizeMake(screenWidth * self.arrayOfPages.count, screenHeight)];
    
    //-- resizing all tutorial pages
    for (int i = 0; i < self.arrayOfPages.count; i++) {
        UIView *view = self.arrayOfPages[i];
        [view setFrame:CGRectMake(screenWidth * i, 0, screenWidth, screenHeight)];
    }
    
    //-- removing element views and put in a new coords
    for (int i = 0; i < self.arrayOfElements.count; i++) {
        PRLElementView *view = self.arrayOfElements[i];
        [view removeFromSuperview];
        
        PRLElementView *viewSlip = nil;
        if (view.type == PRLElementTypeImage) {
            viewSlip = [[PRLElementView alloc] initWithImageName:view.imageName
                                                         offsetX:view.offsetX
                                                         offsetY:view.offsetY
                                                      pageNumber:view.pageNumber
                                             slippingCoefficient:view.slippingCoefficient
                                                scaleCoefficient:self.scaleCoefficient
                                                  loggingEnabled:self.loggingEnabled];
        } else if (view.type == PRLElementTypeText) {
            viewSlip = [[PRLElementView alloc] initWithTitle:view.title
                                                     offsetX:view.offsetX
                                                     offsetY:view.offsetY
                                                  pageNumber:view.pageNumber
                                         slippingCoefficient:view.slippingCoefficient
                                            scaleCoefficient:self.scaleCoefficient
                                              loggingEnabled:self.loggingEnabled];
        }
        
        if (viewSlip) {
            [self.arrayOfPages[viewSlip.pageNumber] addSubview:viewSlip];
            [self.arrayOfElements replaceObjectAtIndex:i withObject:viewSlip];
        }
    }
    [self.skipView removeFromSuperview];
    [self.skipView setFrame:CGRectMake(0, screenHeight - kHeightSkipView, screenWidth, kHeightSkipView)];
    [self addSubview:self.skipView];
    //---
    
    //--- scrolling to current page selected
    [self.scrollView setContentOffset:CGPointMake(screenWidth * currentPageNum, 0)];
    self.lastScreenWidth = screenWidth;
    self.doneButton.center = CGPointMake(screenWidth / 2 + self.doneOffsetX, screenHeight / 2 + self.doneOffsetY);
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)skipPressed:(id)sender;
{
    [self callDelegateSkipPressed];
}

- (void)donePressed:(id)sender;
{
    [self callDelegateDonePressed];
}

- (void)callDelegateSkipPressed;
{
    if ([self.delegate respondsToSelector:@selector(skipTutorialTappedOnView:)]) {
        [self.delegate skipTutorialTappedOnView:self];
    }
}

- (void)callDelegateDonePressed;
{
    if ([self.delegate respondsToSelector:@selector(doneTutorialTappedOnView:)]) {
        [self.delegate doneTutorialTappedOnView:self];
    }
}

@end
