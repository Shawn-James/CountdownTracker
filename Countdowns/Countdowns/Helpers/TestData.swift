//
//  TestData.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


class TestData {
    static var events: [Event] {
        let eventList = [
            Event(
                name: "My birthday",
                dateTime: EventController.newDate(year: 2019, month: 12, day: 06)
            ),
            Event(
                name: "Elie's/Mom's birthday",
                dateTime: EventController.newDate(year: 2019, month: 12, day: 27)
            ),
            Event(
                name: "Projected Lambda School \"graduation\"",
                dateTime: EventController.newDate(year: 2020, month: 07, day: 31, hour: 5),
                note: "I'm so excited to graduate!",
                hasTime: true
            ),
            Event(
                name: "10-year anniversary",
                dateTime: EventController.newDate(year: 2023, month: 06, day: 29)
            )
        ]
        
        eventList[0].imageData = UIImage.checkmark.jpegData(compressionQuality: 1.0)
        if let jonElieImage = UIImage(named: "jonElieEinstein.jpg") {
            eventList[3].imageData = jonElieImage.jpegData(compressionQuality: 1.0)
        } else {
            print("Error finding jonElieEinstein image!")
        }
        
        
        return eventList
    }
}
