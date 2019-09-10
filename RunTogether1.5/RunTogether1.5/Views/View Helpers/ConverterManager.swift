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
    
    static func paceFormatter(distance:Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String{
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        if seconds == 0 {return ""}
        //thank you professor mortenson for finally providing me with some usefull info DVT
        let speedMagnitude = distance.value / Double(seconds)
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return formatter.string(from: speed.converted(to: outputUnit))
    }
    
    static func measureMentFormatter(distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        return formatter.string(from: distance)
        
    }
}
