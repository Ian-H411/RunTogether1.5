//
//  ConverterManager.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/10/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import Foundation

struct Converter{
    //    static func formatDate(date:Date) -> String {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateStyle = .medium
    //        return dateFormatter.string(from: date)
    //    }
    
    static func formatTime(seconds: Int) -> String{
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.unitsStyle = .positional
        timeFormatter.zeroFormattingBehavior = .pad
        return timeFormatter.string(from: TimeInterval(seconds))!
    }
    
    static func pace(distance: Measurement<UnitLength>, seconds: Int,user: User) -> String {
        
        var outputUnit = UnitSpeed.minutesPerMile
        if user.prefersMetric{
            outputUnit = UnitSpeed.minutesPerKilometer
        }
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit] // 1
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return formatter.string(from: speed.converted(to: outputUnit))
    }
    
    //    static func paceFormatter(distance:Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String{
    //        let formatter = MeasurementFormatter()
    //        formatter.unitOptions = [.providedUnit]
    //        if seconds == 0 {return ""}
    //        //thank you professor mortenson for finally providing me with some usefull info DVT
    //        let speedMagnitude = distance.value / Double(seconds)
    //        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
    //        return formatter.string(from: speed.converted(to: outputUnit))
    //    }
    
    
    static func distance(_ distance: Double,user:User) -> String {
        var preferedLength = UnitLength.kilometers
        if !user.prefersMetric{
            preferedLength = UnitLength.miles
        }
        let distanceMeasurement = Measurement(value: distance, unit: preferedLength)
        return Converter.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        return formatter.string(from: distance)
    }
    
    static func date(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    //    static func measureMentFormatter(distance: Measurement<UnitLength>) -> String {
    //        let formatter = MeasurementFormatter()
    //        formatter.unitOptions = .naturalScale
    //        return formatter.string(from: distance)
    //
    //    }
}
