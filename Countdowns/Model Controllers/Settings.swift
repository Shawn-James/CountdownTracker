//
//  Settings.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-12.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class Settings {
   private let encoder = JSONEncoder()
   private let decoder = JSONDecoder()

   private let userDefaults = UserDefaults.standard

   func getCurrentSort() -> EventSortDescriptor {
      let rawSort = UInt8(userDefaults.integer(forKey: .currentSortStyle))
      return EventSortDescriptor(rawValue: rawSort) ?? EventSortDescriptor()
   }

   func setCurrentSort(_ sort: EventSortDescriptor) {
      userDefaults.set(sort.rawValue, forKey: .currentSortStyle)
   }

   func getCurrentFilter() throws -> EventFilterDescriptor {
      guard let data = userDefaults.data(forKey: .currentFilter) else {
         throw CodingError.noData
      }
      return try decoder.decode(EventFilterDescriptor.self, from: data)
   }

   func setCurrentFilter(_ filter: EventFilterDescriptor) throws {
      let data = try encoder.encode(filter)
      userDefaults.setValue(data, forKey: .currentFilter)
   }
}
