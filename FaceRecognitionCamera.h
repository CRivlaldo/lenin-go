//
//  FaceRecognitionCamera.h
//  Lenin GO
//
//  Created by Vladimir Vlasov on 31.07.16.
//  Copyright © 2016 Sofatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FaceRecognitionProtocol <NSObject>

- (void)didRecognizeFace;
- (void)didNotRecognizeFace;

@end

@interface FaceRecognitionCamera : NSObject

@property id<FaceRecognitionProtocol> delegate;

- (id)initWithImageView:(UIImageView*)imageView;
- (void)start;

@end
