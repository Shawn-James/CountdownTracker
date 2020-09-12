//
//  CoreDataStack.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-07-30.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData
import Combine


class CoreDataStack {
   lazy var container: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "Countdowns")
      container.loadPersistentStores { _, error in
         if let error = error {
            preconditionFailure("Failed to load persistent stores: \(error)")
         }
      }
      //container.viewContext.automaticallyMergesChangesFromParent = true
      return container
   }()

   var mainContext: NSManagedObjectContext { container.viewContext }

   init() {}

   func fetch<Object: CDFetchable>(
      with descriptor: Object.FetchDescriptor,
      from context: NSManagedObjectContext? = nil
   ) throws -> [Object] {
      let moc = context ?? mainContext

      return try moc.fetch(descriptor.request())
   }

   func save(in context: NSManagedObjectContext? = nil) throws {
      let moc = context ?? mainContext

      var caughtError: Error?
      moc.performAndWait {
         do {
            try moc.save()
         } catch {
            caughtError = error
         }
      }
      if let error = caughtError {
         throw error
      }
   }
}

// MARK: - CDFetchable

/// An NSManagedObject subclass that can be fetched using the CDFetchDescriptor and associated interfaces.
protocol CDFetchable: NSManagedObject {
   /// The class's associated FetchDescriptor type.
   associatedtype FetchDescriptor: CDFetchDescriptor where FetchDescriptor.Object == Self
}

/// Typically an enum with computed values for requests and predicates that makes fetching more simple and type safe for Core Data NSManagedObjects.
protocol CDFetchDescriptor {
   associatedtype Object: CDFetchable where Object.FetchDescriptor == Self

   var predicate: NSPredicate? { get }
   func request() -> NSFetchRequest<Object>
}

// MARK: - NSMO Extensions

extension NSManagedObject {
   func getContext() throws -> NSManagedObjectContext {
      guard let moc = self.managedObjectContext else {
         throw CountdownError.noManagedObjectContextForObject
      }
      return moc
   }
}
