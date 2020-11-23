//
//  BaseViewController.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showAlert(withTitle title: String?, andMessage message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            dLog("")
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    typealias SegueSenderCallback = (_ vc: UIViewController) -> Void
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue,
                      sender: sender)
        if let prepareBlock = sender as? SegueSenderCallback {
            prepareBlock(segue.destination)
        }
    }

}
