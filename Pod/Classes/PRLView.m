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


@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval timeUntilScroll;

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
        self.autoscrollTime = 4;
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
        [self setupTimer];
    }
    return  self;
}

- (void)setupTimer;
{
    self.timeUntilScroll = self.autoscrollTime;
    __weak typeof(self) selff = self;
    NSTimeInterval delta = 0.1;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delta * NSEC_PER_SEC, DISPATCH_TIMER_STRICT);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            selff.timeUntilScroll -= delta;
            [selff riseTimerIfNeeded];
        });
    });
    dispatch_resume(timer);
    self.timer = timer;
}

- (void)riseTimerIfNeeded;
{
    if (self.autoscrollTime == 0) {
        return;
    }
    if (self.timeUntilScroll > 0) {
        return;
    }
    NSLog(@"PRLView: Autoscroll timer risen");
    NSUInteger newIndex = [self getCurrentPageNumber] + 1;
    NSInteger lastPageIndex = [self getPagesCount] - 1;
    if (newIndex > lastPageIndex) {
        newIndex = 0;
    }
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * newIndex, 0)
                             animated:YES];
    [self resetTimer];
}

- (void)resetTimer {
    self.timeUntilScroll = self.autoscrollTime;
}

- (void)addElementWithName:(NSString *)elementName
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
       slippingCoefficient:(CGFloat)slippingCoefficient
                   pageNum:(NSInteger)pageNum;
{
    [self addElementWithName:elementName
                     offsetX:offsetX
                     offsetY:offsetY
        xSlippingCoefficient:slippingCoefficient
        ySlippingCoefficient:0
                     pageNum:pageNum];
}

- (void)addElementWithName:(NSString *)elementName
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
      xSlippingCoefficient:(CGFloat)xSlippingCoefficient
      ySlippingCoefficient:(CGFloat)ySlippingCoefficient
                   pageNum:(NSInteger)pageNum;
{
    if (pageNum >= self.arrayOfPages.count || pageNum < 0) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Wrong page number %lu Range of pages should be from 0 to %li", (long)pageNum, (long) ([self getPagesCount]));
        }
        return;
    }
    
    PRLElementView *viewSlip = [[PRLElementView alloc] initWithImageName:elementName
                                                                 offsetX:offsetX
                                                                 offsetY:offsetY
                                                              pageNumber:pageNum
                                                    xSlippingCoefficient:xSlippingCoefficient
                                                    ySlippingCoefficient:ySlippingCoefficient
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
    [self addElementWithTitle:title
                         font:nil
                      offsetX:offsetX
                      offsetY:offsetY
          slippingCoefficient:slippingCoefficient
                      pageNum:pageNum];
}

- (void)addElementWithTitle:(NSString *)title
                       font:(UIFont *)font
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
        slippingCoefficient:(CGFloat)slippingCoefficient
                    pageNum:(NSInteger)pageNum; {
    [self addElementWithTitle:title
                         font:font
                      offsetX:offsetX
                      offsetY:offsetY
         xSlippingCoefficient:slippingCoefficient
         ySlippingCoefficient:0
                      pageNum:pageNum];
}

- (void)addElementWithTitle:(NSString *)title
                       font:(UIFont *)font
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
       xSlippingCoefficient:(CGFloat)xSlippingCoefficient
       ySlippingCoefficient:(CGFloat)ySlippingCoefficient
                    pageNum:(NSInteger)pageNum;
{
    
    if (pageNum >= self.arrayOfPages.count || pageNum < 0) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Wrong page number %lu Range of pages should be from 0 to %li", (long)pageNum, (long) ([self getPagesCount]));
        }
        return;
    }
    
    PRLElementView *viewSlip = [[PRLElementView alloc] initWithTitle:title
                                                                font:font ? :LABEL_FONT
                                                             offsetX:offsetX
                                                             offsetY:offsetY
                                                          pageNumber:pageNum
                                                xSlippingCoefficient:xSlippingCoefficient
                                                ySlippingCoefficient:ySlippingCoefficient
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
    [self.arrayOfBackgroundColors insertObject:color atIndex:[self getPagesCount]];
}

- (void)prepareForShow;
{
    [self createSkipView];
    [self updateDoneButtonVisibility];
    if ([self getPagesCount] < self.arrayOfPages.count) {
        if (self.loggingEnabled) {
            NSLog(@"PRLView: Wrong count of background colors. Should be %lu instead of %li", (unsigned long)self.arrayOfPages.count, (long) (self.arrayOfPages.count -1));
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
    NSString *skipTitle = @"Skip";
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 100, 40)];
    [button setTitle:skipTitle forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(slideView:customizeSkipButton:)]) {
        [self.delegate slideView:self customizeSkipButton:button];
    }
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
        CGFloat offsetDiff = (self.lastContentOffset - contentOffset);
        CGFloat xOffset = offsetDiff * view.xSlippingCoefficient;
        CGFloat yOffset = offsetDiff * view.ySlippingCoefficient;
        [view setFrame:CGRectMake(view.frame.origin.x + xOffset, view.frame.origin.y + yOffset, view.frame.size.width, view.frame.size.height)];
    }
    
    self.lastContentOffset = contentOffset;
    NSInteger pageNum =  [self getCurrentPageNumber];
    
    UIColor *mixedColor = [self colorWithFirstColor:self.arrayOfBackgroundColors[pageNum]
                                        secondColor:self.arrayOfBackgroundColors[pageNum +1]
                                             offset:scrollView.contentOffset.x];
    [scrollView setBackgroundColor:mixedColor];
    
    self.pageControl.currentPage = lround(self.scrollView.contentOffset.x / (self.scrollView.contentSize.width / self.pageControl.numberOfPages));
    [self updateDoneButtonVisibility];
    [self resetTimer];
}

#pragma mark - Private

- (NSInteger) getCurrentPageNumber;
{
    NSInteger pageNum =  floorf(self.scrollView.contentOffset.x / SCREEN_WIDTH);
    if (pageNum < 0) {
        pageNum = 0;
    }
    NSInteger lastPageIndex = [self getPagesCount] - 1;
    if (pageNum > lastPageIndex) {
        pageNum = lastPageIndex;
    }
    return pageNum;
}

- (NSInteger) getPagesCount;
{
    return self.arrayOfBackgroundColors.count - 1;
}

- (CGFloat) lastPageVisibility;
{
    NSInteger lastPageIndex = [self getPagesCount] - 1;
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

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat screenHeight = SCREEN_HEIGHT;
    if (self.loggingEnabled) {
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
                                            xSlippingCoefficient:view.xSlippingCoefficient
                                            ySlippingCoefficient:view.ySlippingCoefficient
                                                scaleCoefficient:self.scaleCoefficient
                                                  loggingEnabled:self.loggingEnabled];
        } else if (view.type == PRLElementTypeText) {
            viewSlip = [[PRLElementView alloc] initWithTitle:view.title
                                                        font:view.font
                                                     offsetX:view.offsetX
                                                     offsetY:view.offsetY
                                                  pageNumber:view.pageNumber
                                        xSlippingCoefficient:view.xSlippingCoefficient
                                        ySlippingCoefficient:view.ySlippingCoefficient
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
