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
    }

    
    // hide keyboard when touching background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let priceString = priceTextField.text, let price = Double(priceString) else {
            AlertWrapper.showMessage(viewController: self, title: "Price Field Is Required", message: "")
            return
        }
        let name = nameTextField.text
        let imageName: String? = nil
        
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
