//
//  RealmData.swift
//  PriceTracker
//
//  Created by ben on 2018/7/2.
//  Copyright © 2018年 ben. All rights reserved.
//

import Foundation
import RealmSwift

class Price: Object {
    @objc dynamic var price: Double = 0.0
    @objc dynamic var location = ""
    @objc dynamic var date = Date()
    
    convenience init(price: Double, date: Date) {
        self.init()
        self.price = price
        self.date = date
    }
}

class Commodity: Object {
    @objc dynamic var barcode = ""
    @objc dynamic var name = ""
    @objc dynamic var imageName = ""
    let prices = List<Price>()
    
    override static func primaryKey() -> String? {
        return "barcode"
    }
}


class RealmPrice {
    static let realm = try! Realm()
    
    static func dump() {
        print("Dump all commodities")
        let commodities = realm.objects(Commodity.self)
        for commodity in commodities {
            print("barcode: \(commodity.barcode), name: \(commodity.name)")
            for price in commodity.prices {
                print("\t date: \(price.date), \(price.price)")
            }
        }
        print("-----------\n")
    }
    
    static func commodityExist(barcode: String) -> Bool {
        let commodities = realm.objects(Commodity.self).filter("barcode = %@", barcode)
        if (commodities.count == 0) {
            return false
        }
        return true
    }
    
    static func addNewPrice(barcode: String, price value: Double, date: Date) throws {
        let commodities = realm.objects(Commodity.self).filter("barcode = %@", barcode)
        if (commodities.count > 0) {
            let price = Price(price: value, date: date)
            try realm.write {
                commodities[0].prices.append(price)
            }
        }
    }
    
    static func addNewCommodity(barcode: String, price value: Double, product name: String?,
                                imageName: String?, date: Date) throws {
        let commodities = realm.objects(Commodity.self).filter("barcode = %@", barcode)
        if (commodities.count == 0) {
            let price = Price(price: value, date: date)
            
            let commodity = Commodity()
            commodity.prices.append(price)
            commodity.barcode = barcode
            if let name = name {
                commodity.name = name
            }
            if let imageName = imageName {
                commodity.imageName = imageName
            }
            
            try realm.write {
                realm.add(commodity)
            }
        }
    }
    
    static func deletePrice(barcode: String, index: Int) throws {
        let commodity = realm.objects(Commodity.self).filter("barcode = %@", barcode)[0]
        try realm.write {
            // NOTE: when deleting a price, realm will also remote it from the list
            // https://stackoverflow.com/questions/32475692/how-to-delete-a-realm-child-object-correctly
            realm.delete(commodity.prices[index])
        }
        
        /* do this in uppler layer
        if commodity.prices.count == 0 {
            try realm.write {
                realm.delete(commodity)
            }
        }
        */
    }
    
    static func deleteCommodity(barcode: String) throws {
        let commodity = realm.objects(Commodity.self).filter("barcode = %@", barcode)[0]
        try realm.write {
            for price in commodity.prices {
                realm.delete(price)
            }
            realm.delete(commodity)
        }
    }
    
    static func getPriceRecordCount(barcode: String) -> Int {
        return getCommodity(barcode: barcode)?.prices.count ?? 0
    }
    
    static func getCommodities() -> Results<Commodity> {
        return realm.objects(Commodity.self)
    }

    static func getCommodities(keyword: String) -> Results<Commodity> {
        return realm.objects(Commodity.self).filter("name CONTAINS '\(keyword)'")
    }

    static func getCommodity(barcode: String) -> Commodity? {
        return realm.objects(Commodity.self).filter("barcode = %@", barcode).first
    }

    static func getMaxPrice(commodity: Commodity?) -> Double {
        if let commodity = commodity {
            let price = commodity.prices.max(ofProperty: "price") as Double? ?? 0.0
            return price
        }

        return 0.0
    }

    static func getMinPrice(commodity: Commodity?) -> Double {
        if let commodity = commodity {
            let price = commodity.prices.min(ofProperty: "price") as Double? ?? 0.0
            return price
        }

        return 0.0
    }
    
    static func getLatestPrice(commodity: Commodity?) -> Double {
        if let commodity = commodity {
            let price = commodity.prices.last?.price
            return price ?? 0.0
        }
        
        return 0.0
    }
}



