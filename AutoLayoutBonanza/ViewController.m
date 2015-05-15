//
//  ViewController.m
//  AutoLayoutBonanza
//
//  Created by Matthew Hanlon on 1/7/15.
//  Copyright (c) 2015 Q.I. Software. All rights reserved.
//

#import "ViewController.h"

typedef enum : NSUInteger {
    ALBLayoutCompact,
    ALBLayoutStacked,
    ALBLayoutHorizontalStacked,
    ALBLayoutOverlay
} ALBLayoutType;

typedef enum : NSUInteger {
    ALBContentStandard,
    ALBContentTerse,
    ALBContentVerbose
} ALBContentType;

@interface ViewController ()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* headlineLabel;
@property (nonatomic, strong) UILabel* subheaderLabel;
@property (nonatomic, strong) UIButton* firstButton;
@property (nonatomic, strong) UIButton* secondButton;

@property (nonatomic, strong) UILabel* debugDescriptionLabel;

// Keeping track of our current layout and content state
@property (atomic) ALBLayoutType selectedLayoutType;
@property (atomic) ALBContentType selectedContentType;

- (void)_resetViewConstraints;
- (void)_layoutCompactViewWithViewDictionary:(NSDictionary*)viewDictionary;
- (void)_layoutStackedViewWithViewDictionary:(NSDictionary*)viewDictionary;
- (void)_layoutStackedHorizontalViewWithViewDictionary:(NSDictionary*)viewDictionary;
- (void)_layoutHeadlineOverlayWithViewDictionary:(NSDictionary*)viewDictionary;
- (void)_loadLabelContent;
- (void)_loadVerboseLabelContent;
- (void)_loadTerseLabelContent;
@end

@implementation ViewController

static UIFont *lightFont;
static UIFont *boldFont;

static UIColor *headlineLabelGray;
static UIColor *subheaderLabelGray;
static NSParagraphStyle *paragraphStyle;

+ (void)load
{
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    headlineLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up our image view...
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = [UIImage imageNamed:@"thrill.jpg"];
    
    // Set up our headline label
    self.headlineLabel = [[UILabel alloc] init];
    self.headlineLabel.numberOfLines = 0; // No limit on the number of lines we can have
    self.headlineLabel.backgroundColor = headlineLabelGray;
    
    // Set up our subheader label
    self.subheaderLabel = [[UILabel alloc] init];
    self.subheaderLabel.numberOfLines = 0; // No limit on the number of lines we can have
    self.subheaderLabel.backgroundColor = headlineLabelGray;
    
    // Load our label content
    [self _loadLabelContent];
    
    // Set up our first button
    self.firstButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.firstButton setTitle:@"Layout" forState:UIControlStateNormal];
    self.firstButton.backgroundColor = headlineLabelGray;
    [self.firstButton addTarget:self action:@selector(switchLayout:) forControlEvents:UIControlEventTouchUpInside];

    // Set up our second button
    self.secondButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.secondButton setTitle:@"Content" forState:UIControlStateNormal];
    self.secondButton.backgroundColor = headlineLabelGray;
    [self.secondButton addTarget:self action:@selector(switchContent:) forControlEvents:UIControlEventTouchUpInside];

    // Add our views to the content view and also set them up for being autolayouted
    for ( UIView *view in @[self.imageView, self.headlineLabel, self.subheaderLabel, self.firstButton, self.secondButton] )
    {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }

    // Set up some debugging views
    self.debugDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, ( self.view.frame.size.height - 20 ), 200.0, 20.0)];
    self.debugDescriptionLabel.alpha = 0.25;
    self.debugDescriptionLabel.backgroundColor = [UIColor yellowColor];
    self.debugDescriptionLabel.font = [UIFont fontWithName:@"Courier" size:11.0f];
    [self.view addSubview:self.debugDescriptionLabel];

    // Now we can set up our auto layout constraints
    
    // Our view dictionary is just a handy way of referring to our views in the visual format language for defining
    // constraints.
    self.viewDictionary = NSDictionaryOfVariableBindings( _imageView, _headlineLabel, _subheaderLabel, _firstButton, _secondButton );

    // Let's lay out our views.
    [self _layoutCompactViewWithViewDictionary:self.viewDictionary];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)switchLayout:(id)sender
{
    // Switch up our layout...
    switch ( self.selectedLayoutType )
    {
        case ALBLayoutCompact:
            [self _layoutStackedViewWithViewDictionary:self.viewDictionary];
            break;

        case ALBLayoutStacked:
            [self _layoutStackedHorizontalViewWithViewDictionary:self.viewDictionary];
            break;

        case ALBLayoutHorizontalStacked:
            [self _layoutHeadlineOverlayWithViewDictionary:self.viewDictionary];
            break;

        case ALBLayoutOverlay:
            [self _layoutCompactViewWithViewDictionary:self.viewDictionary];
            break;

        default:
            break;
    }
    self.debugDescriptionLabel.text = [NSString stringWithFormat:@"%@:%@", [self stringForLayoutType:self.selectedLayoutType], [self stringForContentType:self.selectedContentType]];
}

- (IBAction)switchContent:(id)sender
{
    // Switch up our content...
    switch ( self.selectedContentType )
    {
        case ALBContentStandard:
            [self _loadVerboseLabelContent];
            break;

        case ALBContentVerbose:
            [self _loadTerseLabelContent];
            break;

        case ALBContentTerse:
            [self _loadLabelContent];
            break;

        default:
            break;
    }
    self.debugDescriptionLabel.text = [NSString stringWithFormat:@"%@:%@", [self stringForLayoutType:self.selectedLayoutType], [self stringForContentType:self.selectedContentType]];
}


#pragma mark -- Class Extension Methods --
- (void)_resetViewConstraints
{
    NSArray* constraints = self.view.constraints;
    [self.view removeConstraints:constraints];
}


// TODO: Compact view is particularly gnarly -- Can you debug it to get the headers to show up?
- (void)_layoutCompactViewWithViewDictionary:(NSDictionary*)viewDictionary
{
    // Set our selected layout type appropriately to enable switching.
    self.selectedLayoutType = ALBLayoutCompact;
    
    // Clear out any existing constraints...
    [self _resetViewConstraints];
    
    // HORIZONTAL LAYOUT
    // Our image view will be 200 pixels wide from the upper left corner, so let's set the horizontal axis:
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView(200)]" options:0 metrics:nil views:viewDictionary]];
    
    // Let's have our headline fill the upper right corner, all the way down
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_headlineLabel]|" options:0 metrics:nil views:viewDictionary]];
    
    // Our subheader will live under the headline, so it'll get a similar treatment.
    // We're also making it the same width as the header label
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_subheaderLabel(_headlineLabel)]|" options:0 metrics:nil views:viewDictionary]];
    
    // Both buttons we'll pin beneath the image view, to the left
    // We'll also align them by the top, so the vertical layout of the _secondButton will be handled here.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_firstButton]-[_secondButton]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    
    // VERTICAL LAYOUT
    // Our image view will be 250 pixels high from the upper left corner and the button will live under it, with
    // a little bit of spacing
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(250)]-[_firstButton]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewDictionary]];
    
    // Let's have our headline fill the upper right corner with the subheader pinned to the bottom of the superview
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headlineLabel]-[_subheaderLabel]|" options:0 metrics:nil views:viewDictionary]];
}

- (void)_layoutStackedViewWithViewDictionary:(NSDictionary*)viewDictionary
{
    // Set our selected layout type appropriately to enable switching.
    self.selectedLayoutType = ALBLayoutStacked;

    // Clear out any existing constraints...
    [self _resetViewConstraints];
    
    // HORIZONTAL LAYOUT
    // NB.Check out the opening and closing '|' in our Horizontal cases, since we now stretch across the width of the view
    
    // Our image view will be the width of the screen:
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView(300)]|" options:0 metrics:nil views:viewDictionary]];
    
    // Same with our headline
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headlineLabel]|" options:0 metrics:nil views:viewDictionary]];
    
    // Subheader, too
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_subheaderLabel]|" options:0 metrics:nil views:viewDictionary]];
    
    // And the first button...
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_firstButton]|" options:0 metrics:nil views:viewDictionary]];

    // And the second button...
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_secondButton]|" options:0 metrics:nil views:viewDictionary]];
    
    // VERTICAL LAYOUT
    // Our image view will be 200 pixels high from the top, followed by the headline label, the subheader, then the buttons
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_imageView(200)][_headlineLabel][_subheaderLabel][_firstButton][_secondButton]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDictionary]];
    
//    // Let's have our headline fill the upper right corner with the subheader pinned to the bottom of the superview
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headlineLabel]-[_subheaderLabel]|" options:0 metrics:nil views:viewDictionary]];
}

- (void)_layoutStackedHorizontalViewWithViewDictionary:(NSDictionary*)viewDictionary
{
    // Set our selected layout type appropriately to enable switching.
    self.selectedLayoutType = ALBLayoutHorizontalStacked;

    // Clear out any existing constraints...
    [self _resetViewConstraints];

    // All of our views are in a line across the width of the screen
    // The <= will specify that the views should be less than or equal to that width so they can all fit on
    // the screen happily
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView(<=100)][_headlineLabel(<=50)][_subheaderLabel(<=50)][_firstButton]|" options:0 metrics:nil views:viewDictionary]];

    // Now we set up each view as having the run of the vertical space
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(200)]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headlineLabel]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_subheaderLabel]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_firstButton]-[_secondButton]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDictionary]];

}

// TODO: Overlay view isn't the prettiest -- Can you fix it so the headers and buttons appear more elegantly?
- (void)_layoutHeadlineOverlayWithViewDictionary:(NSDictionary*)viewDictionary
{
    // Set our selected layout type appropriately to enable switching.
    self.selectedLayoutType = ALBLayoutOverlay;
    
    // Clear out any existing constraints...
    [self _resetViewConstraints];

    // All of our views are in a line across the width of the screen
    // The <= will specify that the views should be less than or equal to that width so they can all fit on
    // the screen happily
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView(<=400)]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headlineLabel]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_subheaderLabel]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_firstButton]-[_secondButton]|" options:NSLayoutFormatAlignAllBottom | NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    
    // Now we set up each view as having the run of the vertical space
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(200)]-[_firstButton]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headlineLabel]-[_subheaderLabel]|" options:0 metrics:nil views:viewDictionary]];
}



- (void)_loadLabelContent
{
    self.selectedContentType = ALBContentStandard;
    [UIView animateWithDuration:0.2 animations:^{
        self.headlineLabel.text = @"This is a headline";
        self.subheaderLabel.text = @"This is a subheader.";
        [self.view layoutIfNeeded];
    }];
}

- (void)_loadVerboseLabelContent
{
    self.selectedContentType = ALBContentVerbose;
    [UIView animateWithDuration:0.2 animations:^{
        self.headlineLabel.text = @"Once upon a time, in a land far, far away, there lived...";
        self.subheaderLabel.text = @"A peasant who loved to eat chocolate-covered potato chips.";
        [self.view layoutIfNeeded];
    }];
}

- (void)_loadTerseLabelContent
{
    self.selectedContentType = ALBContentTerse;
    [UIView animateWithDuration:0.2 animations:^{
        self.headlineLabel.text = @"Headline";
        self.subheaderLabel.text = @"Subhead";
        [self.view layoutIfNeeded];
    }];
}


#pragma mark -- Debug Helpers --
- (NSString*)stringForLayoutType:(ALBLayoutType)layoutType
{
    switch ( layoutType )
    {
        case ALBLayoutCompact:
            return @"Compact";
            
        case ALBLayoutStacked:
            return @"Stacked";
            
        case ALBLayoutHorizontalStacked:
            return @"Horizontal Stacked";
            
        case ALBLayoutOverlay:
            return @"Overlay";
            
        default:
            break;
    }
    return @"";
}

- (NSString*)stringForContentType:(ALBContentType)contentType
{
    switch ( contentType )
    {
        case ALBContentStandard:
            return @"Standard";
            
        case ALBContentVerbose:
            return @"Verbose";
            
        case ALBContentTerse:
            return @"Terse";

        default:
            break;
    }
    return @"";
}


@end
