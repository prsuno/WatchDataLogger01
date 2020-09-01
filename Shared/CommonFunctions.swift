//
//  CommonFunctions.swift
//  WatchDataLogger01
//
//  Created by Uno on 2020/09/01.
//  Copyright © 2020 uno. All rights reserved.
//

import Foundation

func getDateTimeString() -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy_MMdd_HHmmss"
    let now = Date()
    return f.string(from: now)
}
