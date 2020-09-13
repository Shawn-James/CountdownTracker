//
//  UserFacingError.swift
//  EcoSoapBank
//
//  Created by Jon Bash on 2020-08-20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import Foundation


struct CustomError: LocalizedError {
    let errorDescription: String
    let recoverySuggestion: String
}


struct ErrorMessage: CustomStringConvertible {
    let title: String
    let message: String
    let error: Error?

    private static let fallbackTitle = "An unknown error occurred."
    private static let fallbackMessage = "Please contact the developer for more information."

    init(title: String, message: String, error: Error? = nil) {
        self.title = title
        self.message = message
        if let error = error {
            self.error = error
        } else {
            self.error = CustomError(errorDescription: title,
                                     recoverySuggestion: message)
        }
    }

    init(error: Error? = nil) {
        if let error = error as? LocalizedError {
            self.init(
                title: error.errorDescription ?? Self.fallbackTitle,
                message: error.recoverySuggestion
                    ?? error.failureReason
                    ?? Self.fallbackMessage
            )
        } else {
            self.init(title: Self.fallbackTitle,
                      message: Self.fallbackMessage,
                      error: error)
        }
    }

    var description: String {
        var desc = ""
        if let error = error {
            desc += "\(error)\n"
        }
        desc += "\(title)\n\(message)"
        return desc
    }
}


enum MockError: Error {
    case shouldFail
}


extension Result where Failure == Error {
    static func mockFailure() -> Result<Success, Failure> {
        Result.failure(MockError.shouldFail)
    }
}
