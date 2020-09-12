//
//  Persistence.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-12.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import CoreData


// TODO: Make generic & reusable (can apply to systems other than Core Data)



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
