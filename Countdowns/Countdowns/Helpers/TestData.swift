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
                dateTime: EventController.newDate(year: 2019, month: 07, day: 31)
            ),
            Event(name: "10-year anniversary",
                  dateTime: EventController.newDate(year: 2023, month: 06, day: 29)
            )
        ]
        
        eventList[0].imageData = UIImage.checkmark.jpegData(compressionQuality: 1.0)
        eventList[3].imageData = UIImage(contentsOfFile: "jonElieEinstein.jpg")?.jpegData(compressionQuality: 1.0)
        
        return eventList
    }
}
