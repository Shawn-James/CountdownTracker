//
//  UIViewController+ErrorAlert.swift
//  EcoSoapBank
//
//  Created by Jon Bash on 2020-08-28.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit


extension ErrorMessage {
    func alertController() -> UIAlertController {
        UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
    }
}


extension UIAlertAction {
    static func okay(_ onTap: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(title: "OK", style: .default, handler: onTap)
    }
}


extension UIViewController {
    /// Present a basic alert message based on the provided `ErrorMessage` struct,
    /// which can be constructed with simple strings or with an `Error`.
    ///
    /// The error must conform to `LocalizedError` for it to be parsed into user-readable strings;
    /// otherwise, the alert will tell the user that an unknown error occurred.
    func presentAlert(
        for errorMessage: ErrorMessage,
        actions: [UIAlertAction] = [],
        animated: Bool = true,
        onComplete: (() -> Void)? = nil
    ) {
        if let presentedVC = presentedViewController {
            if (presentedVC as? UIAlertController) != nil {
                return NSLog("Error while alerted:\n\(errorMessage)")
            } else {
                return presentedVC.presentAlert(
                  for: errorMessage,
                  actions: actions,
                  animated: animated,
                  onComplete: onComplete)
            }
        }
        if let error = errorMessage.error {
            NSLog("An error occurred: \(error)")
        } else {
            NSLog("An unknown error occurred.")
        }
        let alert = errorMessage.alertController()

        if actions.isEmpty {
            alert.addAction(.okay())
        } else {
            actions.forEach(alert.addAction(_:))
        }

        present(alert, animated: animated, completion: onComplete)
    }

    /// Present a basic alert message based on the provided `Error`.
    ///
    /// The error must conform to `LocalizedError` for it to be parsed into user-readable strings;
    /// otherwise, the alert will tell the user that an unknown error occurred.
    func presentAlert(
        for error: Error?,
        actions: [UIAlertAction] = [],
        animated: Bool = true,
        onComplete: (() -> Void)? = nil
    ) {
        presentAlert(for: ErrorMessage(error: error),
                     actions: actions,
                     animated: animated,
                     onComplete: onComplete)
    }
}
