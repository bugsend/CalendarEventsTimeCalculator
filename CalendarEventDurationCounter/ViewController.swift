//
//  ViewController.swift
//  CalendarEventDurationCounter
//
//  Created by Sergey Zaytsev on 04/09/2017.
//  Copyright © 2017 Sergey Zaytsev. All rights reserved.
//

import Cocoa
import EventKit

class ViewController: NSViewController {

    @IBOutlet weak var outputTextLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCalendarAuthorizationStatus();
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    fileprivate func checkCalendarAuthorizationStatus() {
        
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch (status) {
        case .notDetermined:
            requestAccessToCalendars()
        case .authorized:
            loadCalendars()
        case .restricted, .denied:
            print("Access to Calendars either _restricted_ or _denied_")
        }
        
        
    }
    
    fileprivate func requestAccessToCalendars() {
        
        EKEventStore().requestAccess(to: .event, completion: {
        
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted {
                DispatchQueue.main.async(execute: { self.loadCalendars() })
            } else {
                DispatchQueue.main.async( execute: { print("Didn't manage to get access to calendars") } )
            }
            
        })
        
    }
    
    fileprivate func loadCalendars() {
        
        EKEventStore().calendars(for: .event).forEach {
        
            if $0.title == "bw" {
            
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let startDate = dateFormatter.date(from: "2016-01-01")
                let endDate = dateFormatter.date(from: "2017-12-30")
                
                let eventsPredicate = EKEventStore().predicateForEvents(withStart: startDate!,
                                                                        end: endDate!, calendars: [$0])
                
                let events = EKEventStore().events(matching: eventsPredicate).sorted(){
                    (e1: EKEvent, e2: EKEvent) -> Bool in
                    return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
                }
            
                var string = ""
                var totalTime: Double = 0.0
                events.forEach {
                    let startDate = $0.startDate
                    let endDate = $0.endDate
                    
                    let interval = endDate.timeIntervalSince(startDate)
                    
                    string += "\neventName = \($0.title)."
                    let duration: Double = interval / (60 * 60)
                    string += ". Duration = \(duration) hours"
                    
                    totalTime.add(duration)
                    
                }
                
                string += "\n\n\nTotal time: = \(totalTime) hours"
                
                self.outputTextLabel.stringValue = string

            }
        
        }
    }
}

