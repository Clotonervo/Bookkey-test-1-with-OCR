//
//  ViewController.swift
//  BookKey
//
//  Created by Sam Hopkins on 5/3/19.
//  Copyright © 2019 Sam Hopkins. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!   //! means we can initialise this later
    
    var captureDevice:AVCaptureDevice!
    var takePhoto = false
    
    @IBOutlet weak var previewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = availableDevices.first
        beginSession()
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        previewView.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
        
        /*
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        previewView.frame = self.view.layer.frame
        */

        
        
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.h0pkins3.testqueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }
    
    /*@IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }*/
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            takePhoto = false
            let image = self.getImageFromSampleBuffer(buffer: sampleBuffer)
            if image != nil {
                
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"PhotoVC") as! PhotoViewController
                photoVC.takenPhoto = image
                
                DispatchQueue.main.async {
                    self.present(photoVC, animated: true, completion: {
                        self.stopCaptureSession()
                    })
                }
            }
        }
    }

    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        if pixelBuffer != nil {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer!), height: CVPixelBufferGetHeight(pixelBuffer!))
            let image = context.createCGImage(ciImage, from: imageRect)
            if image != nil {
                return UIImage(cgImage: image!, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        return nil
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        let inputs = captureSession.inputs as? [AVCaptureDeviceInput]
        if inputs != nil {
            for input in inputs! {
                self.captureSession.removeInput(input)
            }
        }
    }
    
}

