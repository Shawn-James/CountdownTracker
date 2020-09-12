//
//  Combine+Transmitter.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-12.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Combine

@propertyWrapper
struct Transmitter<Output> {
   var wrappedValue: Output? {
      get { return nil }
      set { if let value = newValue { subject.send(value) } }
   }

   private let subject = PassthroughSubject<Output, Never>()

   var projectedValue: AnyPublisher<Output, Never> {
      subject.eraseToAnyPublisher()
   }
}
