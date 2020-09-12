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

   func getCurrentSort() -> EventSort {
      let rawSort = UInt8(userDefaults.integer(forKey: .currentSortStyle))
      return EventSort(rawValue: rawSort) ?? EventSort()
   }

   func setCurrentSort(_ sort: EventSort) {
      userDefaults.set(sort.rawValue, forKey: .currentSortStyle)
   }

   func getCurrentFilter() throws -> EventFilter {
      guard let data = userDefaults.data(forKey: .currentFilter) else {
         throw CodingError.noData
      }
      return try decoder.decode(EventFilter.self, from: data)
   }

   func setCurrentFilter(_ filter: EventFilter) throws {
      let data = try encoder.encode(filter)
      userDefaults.setValue(data, forKey: .currentFilter)
   }
}
