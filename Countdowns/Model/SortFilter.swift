//
//  SortFilter.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-07-30.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


// MARK: - Sort

struct EventSort: Equatable, CustomStringConvertible {
   let property: Property
   let direction: ComparisonResult
   let keyPath: PartialKeyPath<Event>

   init(
      property: EventSort.Property = .endDate,
      direction: ComparisonResult = .orderedAscending)
   {
      self.property = property
      self.direction = direction
      
      switch property {
      case .endDate:
         self.keyPath = \Event.dateTime
      case .creationDate:
         self.keyPath = \Event.creationDate
      case .modifiedDate:
         self.keyPath = \Event.modifiedDate
      case .numberOfTags:
         self.keyPath = \Event.nsmanagedTags.count
      }
   }

   init?(rawValue: Int) {
      guard let property = Property(
               rawValue: rawValue % Property.allCases.count),
            let direction = ComparisonResult(
               rawValue: rawValue / Property.allCases.count)
      else { return nil }

      self.init(property: property, direction: direction)
   }

   var rawValue: Int {
      property.rawValue + (Property.allCases.count * direction.rawValue)
   }

   var isAscending: Bool { direction == .orderedAscending }

   var description: String {
      "\(property) \(isAscending ? "↓" : "↑")"
   }

   enum Property: Int, CustomStringConvertible, CaseIterable {
      case endDate
      case creationDate
      case modifiedDate
      case numberOfTags

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
}


// MARK: - Filter

enum EventFilter: CustomStringConvertible {
   case none
   case noLaterThanDate(Date)
   case noSoonerThanDate(Date)
   case tag(UUID?)

   var description: String {
      switch self {
      case .none: return "(none)"
      case .noLaterThanDate: return "Now → ..."
      case .noSoonerThanDate: return "... → ∞"
      case .tag: return "Tag..."
      }
   }
}

extension EventFilter: Codable {
   enum CodingKeys: CodingKey {
      case intValue
      case date
      case tagID
   }

   enum Error: Swift.Error {
      case noData
      case decodeFailure(Swift.Error? = nil)
      case encodeFailure(Swift.Error? = nil)
   }
   
   var intValue: Int {
      switch self {
      case .none: return 0
      case .noLaterThanDate: return 1
      case .noSoonerThanDate: return 2
      case .tag: return 3
      }
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
            self = .noLaterThanDate(try date())
         case 2:
            self = .noSoonerThanDate(try date())
         case 3:
            self = .tag(try? tagID())
         default:
            throw Error.decodeFailure()
         }
      } catch let error as Self.Error {
         throw error
      } catch {
         throw Error.decodeFailure(error)
      }
   }

   func encode(to encoder: Encoder) throws {
      do {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(intValue, forKey: .intValue)

         switch self {
         case .none:
            break
         case .noLaterThanDate(let date), .noSoonerThanDate(let date):
            try container.encode(date, forKey: .date)
         case .tag(let tagID):
            try container.encode(tagID, forKey: .tagID)
         }
      } catch let error as Self.Error {
         throw error
      } catch {
         throw Error.encodeFailure(error)
      }
   }
}


// MARK: - Extensions

extension Array where Element == Event {
   mutating func sort(by style: EventSort) {
      self.sort(by: {
         switch style.property {
         case .endDate:
            return $0.dateTime.compare($1.dateTime) == style.direction
         case .creationDate:
            return $0.creationDate.compare($1.creationDate) == style.direction
         case .modifiedDate:
            return $0.modifiedDate.compare($1.modifiedDate) == style.direction
         case .numberOfTags:
            return $0.tags.count.compare($1.tags.count) == style.direction
         }
      })
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
         case .noLaterThanDate(let date):
            return $0.dateTime < date
         case .noSoonerThanDate(let date):
            return $0.dateTime > date
         }
      }
   }
}


extension Int {
   func compare(_ other: Int) -> ComparisonResult {
      switch self {
      case other:
         return .orderedSame
      case ..<other:
         return .orderedAscending
      case (other + 1)... :
         return .orderedDescending
      default:
         fatalError("Impossible case")
      }
   }
}
