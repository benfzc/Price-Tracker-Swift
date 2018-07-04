//
//  AlertWrapper.swift
//  PriceTracker
//
//  Created by ben on 2018/7/4.
//  Copyright © 2018年 ben. All rights reserved.
//

import Foundation
import UIKit

class AlertWrapper {
    static func showMessage(viewController: UIViewController, title: String, message: String, completion: (() -> Swift.Void)? = nil) {
        /* alert controller */
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        /* ok button */
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            alertViewController.dismiss(animated: true, completion: nil)

            completion?()
        })
        /* add button to window */
        alertViewController.addAction(okAction)
        
        /* show window */
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
