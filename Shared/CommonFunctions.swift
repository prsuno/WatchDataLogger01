//
//  CommonFunctions.swift
//  WatchDataLogger01
//
//  Created by Uno on 2020/09/01.
//  Copyright © 2020 uno. All rights reserved.
//

import Foundation

let sensorDataFileName = "SensorData.csv"

func getDateTimeString() -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy_MMdd_HHmmss"
    let now = Date()
    return f.string(from: now)
}

func convertDateTimeString(now: Date) -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy/MM/dd_HH:mm:ss"
    return f.string(from: now)
}

func getDateTimeMilisecString() -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy_MMdd_HHmm_ss_SSS"
    let now = Date()
    return f.string(from: now)
}
