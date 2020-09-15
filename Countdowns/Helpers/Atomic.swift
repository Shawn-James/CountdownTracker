//
//  Atomic.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


@propertyWrapper
struct Atomic<Value> {
   private lazy var queue: DispatchQueue = {
      let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
      return DispatchQueue(label: "\(appName).AtomicQueue.\(Value.self)")
   }()
   private var value: Value

   var wrappedValue: Value {
      mutating get { queue.sync { value } }
      set { queue.sync { value = newValue } }
   }

   var projectedValue: DispatchQueue {
      mutating get { queue }
   }

   init(wrappedValue: Value) {
      self.value = wrappedValue
   }
}
