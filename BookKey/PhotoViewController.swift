//
//  PhotoViewController.swift
//  BookKey
//
//  Created by Sam Hopkins on 5/3/19.
//  Copyright © 2019 Sam Hopkins. All rights reserved.
//

import UIKit
import TesseractOCR

class PhotoViewController: UIViewController, G8TesseractDelegate {

    var takenPhoto:UIImage?
    
    //@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var translatedText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.charWhitelist = "0123456789ISBN-"
            tesseract.maximumRecognitionTime = 5.0
            
            if let availableImage = takenPhoto {
                
                //let blackAndWhite = convertToGrayScale(image: availableImage)
                
                tesseract.image = availableImage.g8_blackAndWhite()
                tesseract.recognize()
                
                translatedText.text = tesseract.recognizedText
            }
        }
        
        
        

        // Do any additional setup after loading the view.
    }
    
    func progressImageRecognition (for tesseract: G8Tesseract!) {
        print ("Recognition Progess \(tesseract.progress) %")
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {
        
        // Create image rectangle with current image width/height
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)
        
        // Grayscale color space
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        
        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        
        // Create a new UIImage object
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
