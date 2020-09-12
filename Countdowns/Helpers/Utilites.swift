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


/// Modifies the `value` passed in and returns the object modified using the passed-in closure. Returns a copy if a value type, but mutates the original if a reference type is provided. Useful for making the setup of an item more succinct and readable.
/// - Parameters:
///   - value: The item to be modified; can be just about anything
///   - change: A closure that takes in an inout copy of the provided `value`
/// - Throws: If `change` throws an error, this method will rethrow that error; otherwise no error can or will be thrown
/// - Returns: The `value` of type `T` with the modifications in `change` applied
@discardableResult
public func configure<T>(
   _ value: T,
   with change: (inout T) throws -> Void
) rethrows -> T {
   var mutable = value
   try change(&mutable)
   return mutable
}


/// Alternatively, `?<-`?
/// (`let x = self.point?.x ?<- CGPoint.zero` vs.
/// `let x = self.point?.x ??= CGPoint.zero`)
///
/// See `Optional.orSettingIfNil` to see use in practice.
infix operator ??=

extension Optional {
   /// If nil, sets wrapped value to the new value and then returns it. If non-nil, ignores the new value
   /// and simply returns the wrapped value.
   ///
   /// Similar to the nil-coalescing operator (`??`), but additionally sets the wrapped value if non-nil.
   mutating func orSettingIfNil(_ newValueIfNil: Wrapped) -> Wrapped {
      if self == nil { self = newValueIfNil }
      return self!
   }

   /// If nil, sets wrapped value to the new value and then returns it. If non-nil, ignores the new value
   /// and simply returns the wrapped value.
   ///
   /// Similar to the nil-coalescing operator (`??`), but additionally sets the left-hand value if non-nil.
   static func ??= (lhs: inout Wrapped?, rhs: Wrapped) -> Wrapped {
      lhs.orSettingIfNil(rhs)
   }
}
