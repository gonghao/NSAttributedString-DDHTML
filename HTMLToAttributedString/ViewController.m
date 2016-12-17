//
//  ViewController.m
//  HTMLToAttributedString
//
//  Created by Derek Bowen (Work) on 12/5/12.
//  Copyright (c) 2012 Deloitte Digital. All rights reserved.
//

#import "ViewController.h"
#import "NSAttributedString+DDHTML.h"

@interface ViewController () <DDHTMLImageLoader>

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSMapTable<NSString *, NSTextAttachment *> *textAttachmentDict;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    NSAttributedString *attrString = [NSAttributedString attributedStringFromHTML:@"<font face=\"Avenir-Heavy\" color=\"#FF0000\">This</font> <shadow>is</shadow> <b>Happy bold, <u>underlined</u>, <stroke width=\"2.0\" color=\"#00FF00\">awesomeness </stroke><a href=\"https://www.google.com\">link</a>!</b> <br/> <i>And some italic on the next line.</i><img src=\"car.png\" width=\"50\" height=\"50\" /><br><center><font size=\"20\" color=\"#0000FF\">I'm in CENTER.</font></center>"
                                                                       normalFont:[UIFont systemFontOfSize:12]
                                                                         boldFont:[UIFont boldSystemFontOfSize:12]
                                                                       italicFont:[UIFont italicSystemFontOfSize:12.0]
                                                                      imageLoader:self
                                      ];
    self.label.attributedText = attrString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)ddhtml_imageForSource:(NSString *)imageSource withSize:(CGSize)imageSize
{
  UIGraphicsBeginImageContext(imageSize);
  CGContextRef context = UIGraphicsGetCurrentContext();
  [[UIColor darkGrayColor] setFill];
  CGContextFillRect(context, (CGRect){CGPointZero, imageSize});
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSTextAttachment *textAttachment = [self.textAttachmentDict objectForKey:[self keyForImageSource:imageSource size:imageSize]];
//    textAttachment.image = [UIImage imageNamed:imageSource];

    NSMutableAttributedString *text = [self.label.attributedText mutableCopy];
    [text enumerateAttribute:NSAttachmentAttributeName
                     inRange:NSMakeRange(0, [text length])
                     options:nil
                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                    if (value == textAttachment) {
                      NSTextAttachment *attach = [[NSTextAttachment alloc] init];
                      attach.image = [UIImage imageNamed:imageSource];
                      attach.bounds = textAttachment.bounds;
//                      textAttachment.image = [UIImage imageNamed:imageSource];
                      [text replaceCharactersInRange:range
                                withAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
                    }
                  }];

    self.label.attributedText = text;
  });
  return image;
}

- (void)ddhtml_didImageInsertInTextAttachment:(NSTextAttachment *)textAttachment
                               forImageSource:(NSString *)imageSource
                                     withSize:(CGSize)imageSize
{
  if (!_textAttachmentDict) {
    _textAttachmentDict = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                valueOptions:NSMapTableWeakMemory];
  }

  [self.textAttachmentDict setObject:textAttachment forKey:[self keyForImageSource:imageSource size:imageSize]];
}

- (NSString *)keyForImageSource:(NSString *)imageSource size:(CGSize)imageSize
{
  return [[NSString alloc] initWithFormat:@"%@#[%.0fx%.0f]", imageSource, imageSize.width, imageSize.height];
}

@end
