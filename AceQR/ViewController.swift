//
//  ViewController.swift
//  AceQR
//
//  Created by Roman Rakhlin on 29.04.2020.
//  Copyright © 2020 Roman Rakhlin. All rights reserved.
//

import UIKit
import EFQRCode
import Colorful
import SwiftyButton

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI Elements
    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var qrcodeTextField: UITextField! // QR code text field for links
    @IBOutlet weak var qrcodeImageView: UIImageView! // QR code image
    
    // Configure Buttons
    @IBOutlet weak var backgroundColorButton: PressableButton!
    @IBOutlet weak var foregroundColorButton: PressableButton!
    @IBOutlet weak var backgroundImageButton: PressableButton!
    @IBOutlet weak var centerImageButton: PressableButton!
    @IBOutlet weak var changeShapeButton: PressableButton!
    
    var qrcodeBackgroundColor: CGColor! = CGColor.white()
    var qrcodeForegroundColor: CGColor! = CGColor.black()
    var qrcodeBackgroundImage: UIImage!
    var qrcodeCenterImage: UIImage!
    var qrcodeShape: Int! = 0
    
    let imagePicker = UIImagePickerController()
    
    var isBackgroundImage = false
    var isCenterImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrcodeImageView.image = UIImage(named: "unknown")
        
        imagePicker.delegate = self
        
        colorPicker.isHidden = true
        colorPicker.set(color: UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1), colorSpace: .sRGB)
        
        qrcodeTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        if qrcodeTextField.text == "" {
            qrcodeImageView.image = UIImage(named: "unknown")
        } else {
            let image = qrCode(from: qrcodeTextField.text!, backgroundColor: qrcodeBackgroundColor, foregroundColor: qrcodeForegroundColor, watermark: qrcodeBackgroundImage, icon: qrcodeCenterImage, shape: qrcodeShape)
            qrcodeImageView.image = image
        }
    }
    
    func qrCode(from string: String, backgroundColor: CGColor, foregroundColor: CGColor, watermark: UIImage?, icon: UIImage?, shape: Int) -> UIImage? {
        let tryImage = EFQRCode.generate(
            content: string,
//            size: EFIntSize(width: 100, height: 100),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            watermark: watermark?.cgImage,
//            watermarkMode: EFWatermarkMode(rawValue: 5)!, // from 0 to 11, it's like zoom. normal is 0
//            inputCorrectionLevel: EFInputCorrectionLevel(rawValue: 1)!, // 3 appears squere on the right bottom, uder 3 qr codes without that squere
            icon: icon?.cgImage,
            iconSize: EFIntSize(size: CGSize(width: 200, height: 200)),
//            allowTransparent: true
            pointShape: EFPointShape(rawValue: qrcodeShape)! // default = 0, round = 1, stars = 2
//            mode: EFQRCodeMode.binarization(threshold: 0.5), // from 0.1 to 0.9; 0 it's just white image, 1 image don't appear
//            mode: EFQRCodeMode.grayscale, // all qrcode becames white n black type
//            magnification: EFIntSize(size: CGSize(width: 1000, height: 1000)),
//            foregroundPointOffset: CGFloat(bitPattern: 1)
        )
        
        return UIImage(cgImage: tryImage!)
    }
    
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
        }
        
        return nil
    }
    
    // MARK: - Choose background color of QR code button
    
    @IBAction func backgroundColorButtonTapped(_ sender: Any) {
        if qrcodeTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "You have to create QR code before adding color", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            colorPicker.fadeIn(0.2, onCompletion: nil)
            
            let doneButton = UIButton()
            doneButton.frame = CGRect(x: colorPicker.frame.size.width - 100, y: 10, width: 100, height: 50)
            doneButton.setTitleColor(.link, for: .normal)
            doneButton.setTitle("Done", for: .normal)
            doneButton.addTarget(self, action: #selector(doneButtonForBackgroundTapped), for: .touchUpInside)
            colorPicker.addSubview(doneButton)
            
            let cancelButton = UIButton()
            cancelButton.frame = CGRect(x: 0, y: 10, width: 100, height: 50)
            cancelButton.setTitleColor(.link, for: .normal)
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.addTarget(self, action: #selector(cancelButtonForBackgroundTapped), for: .touchUpInside)
            colorPicker.addSubview(cancelButton)
        }
    }
    
    @objc func doneButtonForBackgroundTapped(sender: UIButton!) {
        qrcodeBackgroundColor = colorPicker.color.cgColor
        colorPicker.fadeOut(0.2, onCompletion: nil)
        
        let image = self.qrCode(from: self.qrcodeTextField.text!, backgroundColor: self.qrcodeBackgroundColor, foregroundColor: self.qrcodeForegroundColor, watermark: self.qrcodeBackgroundImage, icon: self.qrcodeCenterImage, shape: self.qrcodeShape)
        self.qrcodeImageView.image = image
    }
    
    @objc func cancelButtonForBackgroundTapped(sender: UIButton!) {
        qrcodeBackgroundColor = colorPicker.color.cgColor
        colorPicker.fadeOut(0.2, onCompletion: nil)
    }
    
    
    // MARK: - Choose foreground color of QR code button
    
    @IBAction func foregroundColorButtonTapped(_ sender: Any) {
        if qrcodeTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "You have to create QR code before adding color", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            colorPicker.fadeIn(0.2, onCompletion: nil)
            
            let doneButton = UIButton()
            doneButton.frame = CGRect(x: colorPicker.frame.size.width - 100, y: 10, width: 100, height: 50)
            doneButton.setTitleColor(.link, for: .normal)
            doneButton.setTitle("Done", for: .normal)
            doneButton.addTarget(self, action: #selector(doneButtonForForegroundTapped), for: .touchUpInside)
            colorPicker.addSubview(doneButton)
            
            let cancelButton = UIButton()
            cancelButton.frame = CGRect(x: 0, y: 10, width: 100, height: 50)
            cancelButton.setTitleColor(.link, for: .normal)
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.addTarget(self, action: #selector(cancelButtonForForegroundTapped), for: .touchUpInside)
            colorPicker.addSubview(cancelButton)
        }
    }
    
    @objc func doneButtonForForegroundTapped(sender: UIButton!) {
        qrcodeForegroundColor = colorPicker.color.cgColor
        colorPicker.fadeOut(0.2, onCompletion: nil)
        
        let image = self.qrCode(from: self.qrcodeTextField.text!, backgroundColor: self.qrcodeBackgroundColor, foregroundColor: self.qrcodeForegroundColor, watermark: self.qrcodeBackgroundImage, icon: self.qrcodeCenterImage, shape: self.qrcodeShape)
        self.qrcodeImageView.image = image
    }
    
    @objc func cancelButtonForForegroundTapped(sender: UIButton!) {
        qrcodeBackgroundColor = colorPicker.color.cgColor
        colorPicker.fadeOut(0.2, onCompletion: nil)
    }
    
    
    // MARK: - Choose background image of QR code button
    
    @IBAction func backgroundImageButtonTapped(_ sender: UIButton) {
        if qrcodeTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "You have to create QR code before adding images", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            isBackgroundImage = true
            qrcodeCenterImage = nil
//            imagePicker.allowsEditing = false
//            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Choose center image of QR code button
    
    @IBAction func centerImageButtonTapped(_ sender: UIButton) {
        if qrcodeTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "You have to create QR code before adding images", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            isCenterImage = true
            qrcodeBackgroundImage = nil
//            imagePicker.allowsEditing = false
//            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Change Shape of QR code Button
    
    @IBAction func changeShapeButtonTapped(_ sender: Any) {
        if qrcodeTextField.text == "" {
            let alert = UIAlertController(title: "Error", message: "You have to create QR code before editing shape", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if qrcodeShape == 0 {
                qrcodeShape = 1
                changeShapeButton.setTitle("Default Shape", for: .normal)
                let image = self.qrCode(from: self.qrcodeTextField.text!, backgroundColor: self.qrcodeBackgroundColor, foregroundColor: self.qrcodeForegroundColor, watermark: self.qrcodeBackgroundImage, icon: self.qrcodeCenterImage, shape: self.qrcodeShape)
                self.qrcodeImageView.image = image
            } else if qrcodeShape == 1 {
                qrcodeShape = 0
                changeShapeButton.setTitle("Round Shape", for: .normal)
                let image = self.qrCode(from: self.qrcodeTextField.text!, backgroundColor: self.qrcodeBackgroundColor, foregroundColor: self.qrcodeForegroundColor, watermark: self.qrcodeBackgroundImage, icon: self.qrcodeCenterImage, shape: self.qrcodeShape)
                self.qrcodeImageView.image = image
            }
        }
    }
    
    
    // MARK: - Clear Navigation Bar Button
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        qrcodeBackgroundColor = CGColor.white()
        qrcodeForegroundColor = CGColor.black()
        qrcodeBackgroundImage = nil
        qrcodeCenterImage = nil
        qrcodeImageView.image = UIImage(named: "unknown")
        qrcodeTextField.text = ""
        qrcodeShape = 0
    }
    
    
    // MARK: - Save Navigation Bar Button
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if qrcodeImageView.image == UIImage(named: "unknown") {
            let alert = UIAlertController(title: "Error", message: "You have to create QR code before save", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if let features = detectQRCode(qrcodeImageView.image), features.isEmpty {
                let alert = UIAlertController(title: "Error", message: "Your QR code is unreadable!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // this code for addind watermarks to saved QR codes
//                if let mainImage = qrcodeImageView.image, let watermarkImage = UIImage(named: "watermark") {
//                    let rect = CGRect(x: 0, y: 0, width: mainImage.size.width, height: mainImage.size.height)
//                    UIGraphicsBeginImageContextWithOptions(mainImage.size, true, 0)
//                    let context = UIGraphicsGetCurrentContext()
//                    context!.setFillColor(UIColor.white.cgColor)
//                    context!.fill(rect)
//                    mainImage.draw(in: rect, blendMode: .normal, alpha: 1)
//                    watermarkImage.draw(in: CGRect(x: 10, y: 10, width: 200, height: 100), blendMode: .normal, alpha: 0.6)
//                    guard let result = UIGraphicsGetImageFromCurrentImageContext() else { print("Image not found!"); return }
//                    UIGraphicsEndImageContext()
//                    UIImageWriteToSavedPhotosAlbum(result, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//                }
                
                // this code just for saving QR codes
                guard let selectedImage = qrcodeImageView.image else { print("Image not found!"); return }
                UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
     
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if isBackgroundImage == true {
                qrcodeBackgroundImage = pickedImage
                isBackgroundImage = false
            } else if isCenterImage == true {
                qrcodeCenterImage = pickedImage.rounded(with: .white, width: 200)
                isCenterImage = false
            }
            
            let image = qrCode(from: qrcodeTextField.text!, backgroundColor: qrcodeBackgroundColor, foregroundColor: qrcodeForegroundColor, watermark: qrcodeBackgroundImage, icon: qrcodeCenterImage, shape: qrcodeShape)
            qrcodeImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
