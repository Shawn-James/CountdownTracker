//
//  SortFilter.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-07-30.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


// MARK: - Sort

struct EventSortDescriptor: Hashable, CustomStringConvertible, RawRepresentable {
   var property: Property
   var ascending: Bool

   init(
      property: EventSortDescriptor.Property = .endDate,
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

   func nsSortDescriptor() -> NSSortDescriptor {
      switch property {
      case .endDate:
         return NSSortDescriptor(keyPath: \Event.dateTime, ascending: ascending)
      case .creationDate:
         return NSSortDescriptor(keyPath: \Event.creationDate, ascending: ascending)
      case .modifiedDate:
         return NSSortDescriptor(keyPath: \Event.modifiedDate, ascending: ascending)
      case .numberOfTags:
         return NSSortDescriptor(keyPath: \Event.tags.count, ascending: ascending)
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
            if property.rawValue == rawValue & (EventSortDescriptor.ascendingRaw - 1) {
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

struct EventFilterDescriptor: Hashable {
   var option: Option
   var archived: Bool

   init(_ option: Option = .all, archived: Bool = false) {
      self.option = option
      self.archived = archived
   }

   var filter: (Event) -> Bool {
      Self.filter(self)
   }

   var nsPredicate: NSPredicate {
      let archivePredicate = NSPredicate(format: "archived == \(archived)")
      return NSCompoundPredicate(andPredicateWithSubpredicates: [
         option.nsPredicate,
         archivePredicate
      ])
   }

   static let unarchived: Self = EventFilterDescriptor(.all, archived: false)

   static func filter(
      _ descriptor: EventFilterDescriptor
   ) -> ((Event) -> Bool) {
      let catComp = descriptor.option.filter
      return { $0.archived && catComp($0) }
   }
}

extension EventFilterDescriptor: Codable {}


extension EventFilterDescriptor {
   enum Option: Hashable {
      case all
      case date(Date, endIsBefore: Bool = true)
      case tag(UUID?)

      static let before: (Date) -> Self = { date in
         .date(date, endIsBefore: true)
      }
      static let after: (Date) -> Self = { date in
         .date(date, endIsBefore: false)
      }

      var filter: (Event) -> Bool {
         Self.filter(self)
      }

      var nsPredicate: NSPredicate {
         switch self {
         case .all:
            return NSPredicate(value: true)
         case let .date(date, endIsBefore):
            let predicateString: String = endIsBefore ? "dateTime < %@" : "dateTime > %@"
            return NSPredicate(format: predicateString, date as CVarArg)
         case .tag(let tagID):
            if let uuid = tagID {
               return NSPredicate(format: "ANY tags.uuid == %@", uuid as CVarArg)
            } else {
               return NSPredicate(format: "tags.@count == 0")
            }
         }
      }

      var date: Date? {
         get {
            if case .date(let date, _) = self {
               return date
            } else { return nil }
         }
         set {
            Self.cachedDate = newValue
            if let date = newValue {
               if case .date(_, let isBefore) = self {
                  self = .date(date, endIsBefore: isBefore)
               } else {
                  self = .date(date)
               }
            } else if case .date = self {
               self = .all
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
            case .all: return 0
            case .date(_, let isBefore): return isBefore ? 1 : 2
            case .tag: return 3
            }
         }
         set {
            switch newValue {
            case 0: self = .all
            case 1, 2: self = .date(Self.cachedDate ??= Date(), endIsBefore: newValue == 1)
            case 3: self = .tag(Self.cachedTagID)
            default: break
            }
         }
      }

      static var cachedDate: Date?
      static var cachedTagID: UUID?

      static var descriptions: [String] {
         ["(none)",
          "Now → ...",
          "... → ∞",
          "Tag...",]
      }

      static func filter(
         _ option: EventFilterDescriptor.Option
      ) -> ((Event) -> Bool) {
         switch option {
         case .all:
            return { _ in true }
         case .tag(let tagIDOrNil):
            if let tagID = tagIDOrNil {
               return { $0.isTaggedWith(tagWithID: tagID) }
            } else {
               return { $0.tags.isEmpty }
            }
         case let .date(date, endIsBefore):
            return endIsBefore ? { $0.dateTime < date } : { $0.dateTime > date }
         }
      }
   }
}

extension EventFilterDescriptor.Option: Codable {
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
            self = .all
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
         case .date(let date, _):
            try container.encode(date, forKey: .date)
         case .tag(let tagID):
            try container.encode(tagID, forKey: .tagID)
         default: break
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
   func sorted(by style: EventSortDescriptor) -> [Event] {
      self.sorted(by: style.sort)
   }

   mutating func sort(by style: EventSortDescriptor) {
      self.sort(by: style.sort)
   }

   func filtered(by style: EventFilterDescriptor) -> [Event] {
      configure(self) { $0.filter(by: style) }
   }

   mutating func filter(by style: EventFilterDescriptor) {
      self = filter(style.filter)
   }
}
