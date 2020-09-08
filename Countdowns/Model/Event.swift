//
//  Event.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import CoreData


class Event: NSManagedObject {
   // MARK: - Properties
   @NSManaged var uuid: String
   @NSManaged var name: String
   @NSManaged var dateTime: Date
   @NSManaged var nsmanagedTags: NSMutableSet
   @NSManaged var note: String
   @NSManaged var hasTime: Bool
   @NSManaged var creationDate: Date
   @NSManaged var modifiedDate: Date

   @NSManaged var didNotifyDone: Bool
   @NSManaged var archived: Bool

   convenience init(
      name: String,
      dateTime: Date,
      tags: Set<Tag> = [],
      note: String = "",
      hasTime: Bool = false,
      context: NSManagedObjectContext
   ) {
      self.init(context: context)

      self.name = name
      self.dateTime = dateTime
      tags.forEach(addTag(_:))
      self.note = note
      self.hasTime = hasTime
      self.creationDate = Date()
      self.modifiedDate = creationDate
      self.uuid = UUID().uuidString
      self.didNotifyDone = false
      self.archived = false
   }
}


extension Event {
   var dateTimeHasPassed: Bool { Date() > dateTime }

   /// Time remaining until event date/time in `TimeInterval` format
   var timeInterval: TimeInterval { dateTime.timeIntervalSinceNow }

   var tags: Set<Tag> {
      nsmanagedTags.reduce(into: Set<Tag>()) { out, tag in
         out.insert(tag as! Tag)
      }
   }

   /// A string representation of the event's complete list of tags
   var tagsText: String {
      nsmanagedTags.reduce(into: "") { text, tagAny in
         if !text.isEmpty { text += ", " }
         text += (tagAny as! Tag).name
      }
   }

   func addTag(_ tag: Tag) {
      nsmanagedTags.add(tag)
   }

   func removeTag(_ tag: Tag) {
      nsmanagedTags.remove(tag)
   }

   func isTaggedWith(_ tag: Tag) -> Bool {
      nsmanagedTags.contains(tag)
   }

   func isTaggedWith(tagWithID tagID: UUID) -> Bool {
      nsmanagedTags.contains(where: { ($0 as! Tag).uuid == tagID })
   }
}
