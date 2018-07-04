//
//  CommodityAddViewController.swift
//  PriceTracker
//
//  Created by ben on 2018/7/2.
//  Copyright © 2018年 ben. All rights reserved.
//

import UIKit

class CommodityAddViewController: UIViewController {
    var barcode = ""
    var date = Date()
    var haveImage = false
    

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var barcodeLabel: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var commodityImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        barcodeLabel.text = barcode

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateTextField.text = dateFormatter.string(from: date)

        haveImage = false
        commodityImageView.image = UIImage(named: "image_picker")
        commodityImageView.layer.borderWidth = 8
        commodityImageView.layer.cornerRadius = 10
        commodityImageView.layer.borderColor = UIColor.white.cgColor

        // register handler for image tapping
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        commodityImageView.isUserInteractionEnabled = true
        commodityImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    // hide keyboard when touching background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        showCamera()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let priceString = priceTextField.text, let price = Double(priceString) else {
            AlertWrapper.showMessage(viewController: self, title: "Price Field Is Required", message: "")
            return
        }
        let name = nameTextField.text
        var imageName: String? = nil
        if haveImage {
            imageName = JpegWrapper.saveImageAsJpegFile(commodityImageView.image)
        }

        do {
            try RealmPrice.addNewCommodity(barcode: barcode, price: price, product: name, imageName: imageName, date: date)
        }
        catch {
            AlertWrapper.showMessage(viewController: self, title: "Unable to Save Data", message: "")
            return
        }

        AlertWrapper.showMessage(viewController: self, title: "Success", message: "The commodity was added.", completion:  { () in
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    

}

// MARK:- Camera Image Picker
extension CommodityAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        commodityImageView.image = image
        haveImage = true
        dismiss(animated:true, completion: nil)
    }
}

extension CommodityAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
