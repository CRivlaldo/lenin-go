//
//  ViewController.swift
//  Lening GO
//
//  Created by Vladimir Vlasov on 31.07.16.
//  Copyright © 2016 Sofatech. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, FaceRecognitionProtocol {
    
    @IBOutlet weak var cameraView: UIImageView!
    var camera:FaceRecognitionCamera!
    let audioPath = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")
    var player:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath!))
        }
        catch {
            print("Something bad happened. Try catching specific errors to narrow things down")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        camera = FaceRecognitionCamera(imageView: cameraView)
        camera.delegate = self
        camera.start()
    }
    
    func didRecognizeFace() {
        player.play()
    }
    
    func didNotRecognizeFace() {
        player.pause()
    }
    
//    let captureSession = AVCaptureSession()
//    let stillImageOutput = AVCaptureStillImageOutput()
//    var error: NSError?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
//        
//        if let captureDevice = devices.first as? AVCaptureDevice  {
//            do {
//                try self.captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
//            }
//            catch {
//                return;//!!handle error
//            }
//            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
//            captureSession.startRunning()
//            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
//            if captureSession.canAddOutput(stillImageOutput) {
//                captureSession.addOutput(stillImageOutput)
//            }
//            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
//                previewLayer.bounds = view.bounds
//                previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
//                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
//                let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
//                cameraPreview.layer.addSublayer(previewLayer)
////                cameraPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(ViewController.saveToCamera(_:))))
//                view.addSubview(cameraPreview)
//            }
//        }
//    }
//    
////    func saveToCamera(sender: UITapGestureRecognizer) {
////        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
////            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
////                (imageDataSampleBuffer, error) -> Void in
////                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
////                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
////            }
////        }
////    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

