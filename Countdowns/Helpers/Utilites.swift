//
//  Utilites.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-07-30.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


func unimplemented(function: String = #function, file: String = #file) -> Never {
   fatalError("\(function) in \(file) has not been implemented")
}
