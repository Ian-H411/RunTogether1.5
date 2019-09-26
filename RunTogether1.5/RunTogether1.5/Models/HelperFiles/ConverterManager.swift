//
//  ConverterManager.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/10/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation

struct Converter{

    
    static func formatTime(seconds: Int) -> String{
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.unitsStyle = .positional
        timeFormatter.zeroFormattingBehavior = .pad
        return timeFormatter.string(from: TimeInterval(seconds))!
    }
    
    static func pace(distance: Measurement<UnitLength>, seconds: Int, user: User?) -> String {
        guard let owner = CloudController.shared.user else {return ""}
        var distance = distance
        var outputUnit = UnitSpeed.minutesPerKilometer
        if !owner.prefersMetric{
            outputUnit = UnitSpeed.minutesPerMile
            distance.convert(to: UnitLength.feet)
        }
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit] // 1
        if let otherUser = user{
            if !otherUser.prefersMetric && owner.prefersMetric{
                distance.convert(to: UnitLength.meters)
            }
            else if otherUser.prefersMetric && !owner.prefersMetric{
                distance.convert(to: UnitLength.feet)
            }
        }
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return formatter.string(from: speed.converted(to: outputUnit))
    }
    
    
    static func distance(_ distance: Double) -> String {
        guard let user = CloudController.shared.user else {return ""}
        var preferedLength = UnitLength.kilometers
        if !user.prefersMetric{
            preferedLength = UnitLength.miles
        }
        let distanceMeasurement = Measurement(value: distance, unit: preferedLength)
        return Converter.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        guard let user = CloudController.shared.user else {return ""}
        if user.prefersMetric{
            formatter.unitOptions = .providedUnit
            return formatter.string(from: distance.converted(to: UnitLength.kilometers))
        }
        formatter.unitOptions = .naturalScale
        return formatter.string(from: distance)
    }
    
    static func dateFull(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        return "Date: \(formatter.string(from: timestamp))"
    }
    
    static func dateShort(_ timestamp: Date?) -> String{
    guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }

}
