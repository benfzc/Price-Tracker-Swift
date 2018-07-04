//
//  ViewController.swift
//  PriceTracker
//
//  Created by ben on 2018/6/30.
//  Copyright © 2018年 ben. All rights reserved.
//

import UIKit
import BarcodeScanner

class ViewController: UIViewController {
    var barcode = ""
    var commodities = RealmPrice.getCommodities()

    @IBOutlet weak var commoditiesTableView: UITableView!
    @IBOutlet weak var keywordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //RealmPrice.dump()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()

        // watch user input to update tableview in real time
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: NSNotification.Name.UITextFieldTextDidChange,
                                               object: nil)

    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }



    @IBAction func scanButtonTapped(_ sender: Any) {
        launchBarcodeScanner()
    }


    // hide keyboard when touching background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    func reloadTableView() {
        if let keyword = keywordTextField.text, keyword.count > 0 {
            commodities = RealmPrice.getCommodities(keyword: keyword)
        }
        else {
            commodities = RealmPrice.getCommodities()
        }
        commoditiesTableView.reloadData()
    }
}


// MARK:- create next page
extension ViewController {
    func showCommodityAddViewController(barcode: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "CommodityAddViewController") as? CommodityAddViewController else {
            return
        }
        
        // pass data to next view controller
        nextViewController.barcode = barcode
        
        // show next view
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func showHistoryViewController(barcode: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController else {
            return
        }
        
        // pass data to next view controller
        nextViewController.barcode = barcode
        
        // show next view
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}

// MARK:- UITableView Data Source
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commodities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commodity = commodities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "commodityCell", for: indexPath) as! CommodityListTableViewCell
        if commodity.name.count > 0 {
            cell.nameLabel.text = commodity.name
        }
        else {
            cell.nameLabel.text = commodity.barcode
        }
        cell.priceLabel.text = String(format: "%2.2f", RealmPrice.getLatestPrice(commodity: commodity))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showHistoryViewController(barcode: commodities[indexPath.row].barcode)
    }
    
}

// MARK:- Barcode Scanner
extension ViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    func launchBarcodeScanner() {
        let scanner = BarcodeScannerViewController()
        
        scanner.codeDelegate = self
        scanner.errorDelegate = self
        scanner.dismissalDelegate = self
        
        
        scanner.title = "Barcode Scanner"
        //scanner.headerViewController.titleLabel.text = "Barcode Scanner"
        
        
        present(scanner, animated: true, completion: nil)
        //navigationController?.pushViewController(scanner, animated: true)
    }
    
    // MARK: BarcodeScannerCodeDelegate
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        barcode = code
        
        controller.dismiss(animated: false) { () in
            if (RealmPrice.commodityExist(barcode: code)) {
                self.showHistoryViewController(barcode: code)
            }
            else {
                self.showCommodityAddViewController(barcode: code)
            }
        }
    }
    
    // MARK: BarcodeScannerErrorDelegate
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    // MARK: BarcodeScannerDismissalDelegate
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK:- TextField Delegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textDidChange() {
        reloadTableView()
    }
}
