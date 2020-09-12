//
//  CountdownError.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-08.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

enum CountdownError: Error {
    case noManagedObjectContextForObject
    case unknown
    case other(Error)
}

enum CodingError: Error {
   case noData
   case decodeFailure(Error? = nil)
   case encodeFailure(Error? = nil)
}
