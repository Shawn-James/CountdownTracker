//
//  SortFilter.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-07-30.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


// MARK: - Sort

struct EventSort: Equatable, CustomStringConvertible, RawRepresentable {
   var property: Property
   var ascending: Bool

   init(
      property: EventSort.Property = .endDate,
      ascending: Bool = true)
   {
      self.property = property
      self.ascending = ascending
   }

   /// Initializes from a rawValue that stores both a Property and a bit for whether it is ascending or descending
   init?(rawValue: UInt8) {
      let isAscending = Self.rawToAscending(rawValue)
      guard let property = Property(rawValue: rawValue) else { return nil }

      self.init(property: property, ascending: isAscending)
   }

   var rawValue: UInt8 {
      let ascBit: UInt8 = ascending ? Self.ascendingRaw : 0
      return property.rawValue | ascBit
   }

   var description: String {
      "\(property) \(ascending ? "↓" : "↑")"
   }

   var sort: (Event, Event) -> Bool {
      switch property {
      case .endDate:
         return Self.sorter(keyPath: \.dateTime, ascending: ascending)
      case .creationDate:
         return Self.sorter(keyPath: \.creationDate, ascending: ascending)
      case .modifiedDate:
         return Self.sorter(keyPath: \.modifiedDate, ascending: ascending)
      case .numberOfTags:
         return Self.sorter(keyPath: \.tags.count, ascending: ascending)
      }
   }

   enum Property: UInt8, CustomStringConvertible, CaseIterable {
      case endDate
      case creationDate
      case modifiedDate
      case numberOfTags

      /// Initializes from a rawValue that stores both a Property and a bit for whether it is ascending or descending
      init?(rawValue: UInt8) {
         for property in Property.allCases {
            if property.rawValue == rawValue & (EventSort.ascendingRaw - 1) {
               self = property
               return
            }
         }
         return nil
      }

      var description: String {
         switch self {
         case .endDate:
            return "End date"
         case .creationDate:
            return "Date created"
         case .modifiedDate:
            return "Date modified"
         case .numberOfTags:
            return "Number of tags"
         }
      }
   }

   private static let ascendingRaw: UInt8 = 0b1000_0000

   private static func ascendingToRaw(_ ascending: Bool) -> UInt8 {
      ascending ? ascendingRaw : 0
   }

   private static func rawToAscending(_ rawValue: UInt8) -> Bool {
      (rawValue & ascendingRaw) == ascendingRaw
   }

   static func sorter<T: Comparable>(
      keyPath: KeyPath<Event, T>,
      ascending: Bool
   ) -> ((Event, Event) -> Bool) {
      return { lhs, rhs in
         if ascending {
            return (lhs[keyPath: keyPath] < rhs[keyPath: keyPath])
         } else {
            return (rhs[keyPath: keyPath] > rhs[keyPath: keyPath])
         }
      }
   }
}


// MARK: - Filter

enum EventFilter: CustomStringConvertible {
   case none
   case before(Date)
   case after(Date)
   case tag(UUID?)

   var description: String {
      Self.descriptions[intValue]
   }

   var date: Date? {
      get {
         switch self {
         case .before(let date), .after(let date):
            return date
         default:
            return nil
         }
      }
      set {
         Self.cachedDate = newValue
         if let date = newValue {
            if case .after = self {
               self = .after(date)
            } else {
               self = .before(date)
            }
         } else {
            if case .tag = self {
               return
            } else {
               self = .none
            }
         }
      }
   }

   var tagID: UUID? {
      get {
         if case .tag(let id) = self {
            return id
         } else { return nil }
      }
      set {
         Self.cachedTagID = newValue
         self = .tag(newValue)
      }
   }

   var intValue: Int {
      get {
         switch self {
         case .none: return 0
         case .before: return 1
         case .after: return 2
         case .tag: return 3
         }
      }
      set {
         switch newValue {
         case 0: self = .none
         case 1: self = .before(Self.cachedDate ??= Date())
         case 2: self = .after(Self.cachedDate ??= Date())
         case 3: self = .tag(Self.cachedTagID)
         default: break
         }
      }
   }

   static var descriptions: [String] {
      ["(none)",
       "Now → ...",
       "... → ∞",
       "Tag...",]
   }

   static var cachedDate: Date?
   static var cachedTagID: UUID?
}

extension EventFilter: Codable {
   enum CodingKeys: CodingKey {
      case intValue
      case date
      case tagID
   }

   init(from decoder: Decoder) throws {
      do {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         let rawInt = try container.decode(Int.self, forKey: .intValue)

         func date() throws -> Date {
            try container.decode(Date.self, forKey: .date)
         }

         func tagID() throws -> UUID {
            try container.decode(UUID.self, forKey: .tagID)
         }

         switch rawInt {
         case 0:
            self = .none
         case 1:
            self = .before(try date())
         case 2:
            self = .after(try date())
         case 3:
            self = .tag(try tagID())
         default:
            throw CodingError.decodeFailure()
         }
      } catch let error as CodingError {
         throw error
      } catch {
         throw CodingError.decodeFailure(error)
      }
   }

   func encode(to encoder: Encoder) throws {
      do {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(intValue, forKey: .intValue)

         switch self {
         case .none:
            break
         case .before(let date), .after(let date):
            try container.encode(date, forKey: .date)
         case .tag(let tagID):
            try container.encode(tagID, forKey: .tagID)
         }
      } catch let error as CodingError {
         throw error
      } catch {
         throw CodingError.encodeFailure(error)
      }
   }
}


// MARK: - Extensions

extension Array where Element == Event {
   func sorted(by style: EventSort) -> [Event] {
      self.sorted(by: style.sort)
   }

   mutating func sort(by style: EventSort) {
      self.sort(by: style.sort)
   }

   func filtered(by style: EventFilter) -> [Event] {
      var copy = self
      copy.filter(by: style)
      return copy
   }

   mutating func filter(by style: EventFilter) {
      self = filter {
         switch style {
         case .none:
            return true
         case .tag(let tagIDOrNil):
            if let tagID = tagIDOrNil {
               return $0.isTaggedWith(tagWithID: tagID)
            } else {
               return $0.tags.isEmpty
            }
         case .before(let date):
            return $0.dateTime < date
         case .after(let date):
            return $0.dateTime > date
         }
      }
   }
}
