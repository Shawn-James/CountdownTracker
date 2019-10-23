//
//  Strings.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

extension String {
    static let countdownCellReuseID = "CountdownCell"
    
    // MARK: - Segue Identifiers
    static let addEventSegue = "AddEventSegue"
    static let eventDetailSegue = "EventDetailSegue"
    static let editEventSegue = "EditEventSegue"
    static let sortFilterSegue = "SortFilterSegue"
    
    // MARK: - Colors
    static let cellBackgroundColor = "cellBackgroundColor"
    static let secondaryCellBackgroundColor = "secondaryCellBackgroundColor"
    
    // MARK: - Methods
    func stripMultiSpace() -> String {
        var string = self
        
        while string.contains("  ") {
            string = string.replacingOccurrences(of: "  ", with: " ")
        }
        while string.last == " " {
            string.removeLast()
        }
        while string.first == " " {
            string.removeFirst()
        }
        
        return string
    }
}

extension Character {
    static let tagSeparator = Character(",")
}
