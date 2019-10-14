//
//  ViewController.swift
//  Image Classifier
//
//  Created by SRIDHAR Prashant 12/4/2018
//  Copyright © SRIDHAR Prashant. All rights reserved.
//

import UIKit
import CoreML
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var changePictureButton: UIButton!
    
    let model = VGG16()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onChangePictureButtonClicked(_ sender: UIButton!) {
        let actionSheet = UIAlertController(title: "Change Picture",
                                            message: "Please select your picture source",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo Gallery", style: .default, handler: { [unowned self] (action) in
           self.openPhotoGallery()
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [unowned self] (action) in
            self.openCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func openPhotoGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    fileprivate func classifyImage(_ image: UIImage) {
        let size = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(0.0))
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let scaledImage = scaledImage,
            let buffer = scaledImage.buffer(),
            let output = try? model.prediction(image: buffer) {
                let objectName: String = output.classLabel
                let possibility: Double = output.classLabelProbs[objectName]! * 100
                resultLabel.text = "\(objectName) with \(String.init(format: "%.2f", possibility))% accuracy"
        } else {
                resultLabel.text = "Sorry, Could not find anything!"
        }
        let utterance = AVSpeechUtterance(string:resultLabel.text!)
        utterance.voice = AVSpeechSynthesisVoice(language:"en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            resultLabel.text = "Predicting Image"
            classifyImage(image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

