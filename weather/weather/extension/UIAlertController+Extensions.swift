//
//  UIViewController+Extension.swift
//  weather
//
//  Created by Gabriela Sillis on 05/08/21.
//

import UIKit

extension UIAlertController {
    
    func presentAlertController(alertTitle: String, alertMessage: String, actionTitle: String, confirmAction: @escaping () -> Void) {
        let alert: UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .default) { _ in
            confirmAction()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}
