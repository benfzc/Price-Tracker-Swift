//
//  HistoryViewController.swift
//  PriceTracker
//
//  Created by ben on 2018/7/2.
//  Copyright © 2018年 ben. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    var barcode = ""
    
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var newPriceTextField: UITextField!
    @IBOutlet weak var latestPriceLabel: UILabel!
    @IBOutlet weak var lowestPriceLabel: UILabel!
    @IBOutlet weak var highestPriceLabel: UILabel!
    @IBOutlet weak var commodityImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadCommodityInfo()
    }
    
    // hide keyboard when touching background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let priceString = newPriceTextField.text, let price = Double(priceString) else {
            AlertWrapper.showMessage(viewController: self, title: "Price Field Is Required", message: "")
            return
        }
        do {
            try RealmPrice.addNewPrice(barcode: barcode, price: price, date: Date())
        }
        catch {
            AlertWrapper.showMessage(viewController: self, title: "Unable to Save Data", message: "")
            return
        }
        
        newPriceTextField.text = ""
        reloadCommodityInfo()
        AlertWrapper.showMessage(viewController: self, title: "Success", message: "The price was added.")
    }
    
    @IBAction func viewAllButtonTapped(_ sender: Any) {
        showDetailViewController(barcode: barcode)
    }
    
    func reloadCommodityInfo() {
        if let commodity = RealmPrice.getCommodity(barcode: barcode) {
            if commodity.name.count > 0 {
                barcodeLabel.text = commodity.name
            }
            else {
                barcodeLabel.text = barcode
            }
            
            // FIXME: show image
            
            highestPriceLabel.text = String(format: "%2.2f", RealmPrice.getMaxPrice(commodity: commodity))
            lowestPriceLabel.text = String(format: "%2.2f", RealmPrice.getMinPrice(commodity: commodity))
            latestPriceLabel.text = String(format: "%2.2f", RealmPrice.getLatestPrice(commodity: commodity))
        }
    }
    
    func showDetailViewController(barcode: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        
        // pass data to next view controller
        nextViewController.barcode = barcode
        
        // show next view
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}
