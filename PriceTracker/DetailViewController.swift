//
//  DetailViewController.swift
//  PriceTracker
//
//  Created by ben on 2018/7/3.
//  Copyright © 2018年 ben. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var barcode = ""

    @IBOutlet weak var priceTableView: UITableView!
    @IBOutlet weak var barcodeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let commodity = RealmPrice.getCommodity(barcode: barcode) {
            if commodity.name.count > 0 {
                barcodeLabel.text = commodity.name
            }
            else {
                barcodeLabel.text = barcode
            }
        }
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmPrice.getPriceRecordCount(barcode: barcode)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "priceTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "priceTableViewCell", for: indexPath) as! DetailPriceTableViewCell
        if let price = RealmPrice.getCommodity(barcode: barcode)?.prices[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            
            cell.priceLabel.text = String(format: "%2.2f", price.price)
            cell.dateLabel.text = dateFormatter.string(from: price.date)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try RealmPrice.deletePrice(barcode: barcode, index: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            catch {
                AlertWrapper.showMessage(viewController: self, title: "Error Deleting Price", message: "")
                return
            }

            // if all price data are deleted, delete this commodity too
            if let commodity = RealmPrice.getCommodity(barcode: barcode) {
                if commodity.prices.count == 0 {
                    JpegWrapper.removeImageFileInDocumentDirectory(filename: commodity.imageName)
                    do {
                        try RealmPrice.deleteCommodity(barcode: barcode)
                    }
                    catch {
                        print("delete Commodity with barcode \(barcode) failed\n")
                        return
                    }
                    navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
