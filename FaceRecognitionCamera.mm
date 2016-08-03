//
//  FaceRecognitionCamera.m
//  Lenin GO
//
//  Created by Vladimir Vlasov on 31.07.16.
//  Copyright © 2016 Sofatech. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import "FaceRecognitionCamera.h"
#import <opencv2/highgui/cap_ios.h>

#define THRESHOLD 50.0

@interface FaceRecognitionCamera() <CvVideoCameraDelegate>

@property CvVideoCamera* videoCamera;
@property BOOL wasFaceRecognized;
@property int notRecognizedFacesNum;
@property int recognizedFacesNum;

@end

@implementation FaceRecognitionCamera

cv::CascadeClassifier faceDetector;
cv::Ptr<cv::FaceRecognizer> faceRecognizer;

- (id)initWithImageView:(UIImageView*)imageView
{
    self = [super init];
    
    if(self)
    {
        self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        self.videoCamera.rotateVideo = YES;
        self.videoCamera.defaultFPS = 10;
        self.videoCamera.delegate = self;
        
        //Path to the training parameters for frontal face detector
        NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        
        const CFIndex CASCADE_NAME_LEN = 2048;
        char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
        CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
        
        faceDetector.load(CASCADE_NAME);
        
        faceRecognizer = cv::createLBPHFaceRecognizer();
        [self trainFaceRecognizer];
    }
    
    return self;
}

- (void)trainFaceRecognizer
{
    cv::vector<cv::Mat> images;
    cv::vector<int> labels;
    
    for(int i = 1; i <= 10; i++)
    {
        NSString* fileName = [NSString stringWithFormat:@"%d", i];
        NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        images.push_back(cv::imread([path UTF8String], CV_LOAD_IMAGE_GRAYSCALE));
        labels.push_back((i - 1) / 5);
    }
    
    faceRecognizer->train(images, labels);
}

- (void)start
{
    [self.videoCamera start];
}

//+ (cv::FaceRecognizer*)faceRecognizerWithFile:(NSString *)path {
//    cv::FaceRecognizer *fr = [cv::FaceRecognizer new];
//    fr->_faceClassifier = cv::createLBPHFaceRecognizer();
//    fr->_faceClassifier->load(path.UTF8String);
//    return fr;
//}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(cv::Mat&)image
{
    int label = [self recognizedLabel:image];
    
    [self updateRecognitedLabelsNumber:label];
}

- (int)recognizedLabel:(cv::Mat&)image
{
    cv::vector<cv::Rect> faceRects;
    faceDetector.detectMultiScale(image, faceRects, 1.1, 2, 0, cv::Size(60, 60) );
    
    cv::Mat imageWithRects(image);
    
    cv::Mat greyImge;
    cvtColor(image, greyImge, CV_BGR2GRAY);
    
    int recognizedRectMaxWidth = -1;
    int recognizedLabel = -1;
    
    for(auto faceRect : faceRects)
    {
        cv::Mat croppedFace(greyImge, faceRect);
        
//        cv::Mat face;
//        cv::resize(croppedFace, face, cv::Size(100, 100));
        
        int label = -1;
        double confidence = 0;
        faceRecognizer->predict(croppedFace, label, confidence);
        
        int width = faceRect.size().width;
        
        if(label >= 0 && width > recognizedRectMaxWidth)
        {
            recognizedRectMaxWidth = width;
            recognizedLabel = label;
        }
        
        cv::rectangle(imageWithRects, faceRect.tl(), faceRect.br(), (label >= 0) ? cv::Scalar(255, 0, 0) : cv::Scalar(255, 255, 0));
        
        if(label >= 0)
        {
            char buffer[255];
            sprintf(buffer, "%d: %.1f", label, confidence);
            
            putText(imageWithRects, buffer, faceRect.tl(), cv::FONT_HERSHEY_SCRIPT_SIMPLEX, 1, cv::Scalar::all(255), 2, 4);
        }
    }
    
    image = imageWithRects;
    
    return recognizedLabel;
}

#endif

- (void)updateRecognitedLabelsNumber:(int)label
{
    if(label == 0)
    {
        ++self.recognizedFacesNum;
    }
    else
    {
        ++self.notRecognizedFacesNum;
    }
    
    if(self.notRecognizedFacesNum + self.recognizedFacesNum >= 20)
    {
        BOOL newWasRecognized = (self.recognizedFacesNum >= self.notRecognizedFacesNum);
        
        if(self.wasFaceRecognized != newWasRecognized)
        {
            self.wasFaceRecognized = newWasRecognized;
            if(self.delegate)
            {
                if(self.wasFaceRecognized)
                {
                    [self.delegate didRecognizeFace];
                }
                else
                {
                    [self.delegate didNotRecognizeFace];
                }
            }
        }
        
        self.recognizedFacesNum = 0;
        self.notRecognizedFacesNum = 0;
    }
}

@end
