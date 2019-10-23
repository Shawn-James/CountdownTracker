//
//  Notifications.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-23.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsHelper {
    
    private static var _shared: NotificationsHelper?
    
    static var shared: NotificationsHelper {
        if let helper = _shared {
            return helper
        } else {
            return NotificationsHelper()
        }
    }
    
    var notificationsAllowed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: .notificationsAllowed)
        }
        set(didAllow) {
            UserDefaults.standard.set(didAllow, forKey: .notificationsAllowed)
        }
    }
    
    func setNotification(for event: Event) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            if settings.alertSetting == .enabled {
                let content = UNMutableNotificationContent()
                content.title = "Countdown ended!"
                content.body = "Test body"
                if settings.soundSetting == .enabled {
                    content.sound = .default
                } else {
                    content.sound = .none
                }
                
                let dateComponents = Calendar.autoupdatingCurrent.dateComponents(
                    [.year, .month, .day, .hour, .minute], from: event.dateTime
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: event.uuid, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if error != nil {
                        print("Notification error! \(error!)")
                    }
                }
            }
            if settings.badgeSetting == .enabled {
                // badge
            }
        }
    }
    
    func cancelNotification(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.uuid])
    }
}
