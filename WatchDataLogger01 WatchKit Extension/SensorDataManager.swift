//
//  SensorDataManager.swift
//  WatchDataLogger01
//
//  Created by Uno on 2020/09/01.
//  Copyright © 2020 uno. All rights reserved.
//

import Foundation
import CoreMotion

//
// Heart rate data acquisition
// All functionalities are implemented by WorkoutManager.swift.

//
// Acceleration data acquisition
//

extension CMSensorDataList: Sequence {
    public typealias Iterator = NSFastEnumerationIterator

    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

let sensorrecorder = CMSensorRecorder()

func startAccelerationSensorUpdates(durationMinutes: Double)->String{
    dateDAQStarted = Date()
    var stringreturn = "Acceleration DAQ failed."
    if CMSensorRecorder.isAccelerometerRecordingAvailable() {
        sensorrecorder.recordAccelerometer(forDuration: durationMinutes * 60)
        stringreturn = "Acceleration DAQ started at \(convertDateTimeString(now: dateDAQStarted)) for \(durationMinutes) min"
    }
    return stringreturn
}

func stopAccelerationSensorUpdates(intervalSeconds: Double)->String {
    dateDAQEnded = Date()
    var stringreturn = "Acceleration data retrieve failed"
    if let listCMSensorData = sensorrecorder.accelerometerData(from: dateDAQStarted, to: dateDAQEnded){
        stringreturn = "Acceleration data retrieved at \(convertDateTimeString(now: dateDAQEnded))"
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileURL = docsDirect.appendingPathComponent(sensorDataFileName)
        let stringfirstline = "\(convertDateTimeString(now: dateDAQStarted))\nTimestamp,AxelX,AxelY,AxelZ\n"
        creatDataFile(onetimestring: stringfirstline, fileurl: fileURL)
        let tol: Double = 1.0/(50*100) // intervalSeconds must be smaller than 100 [s] in this case.
        for (index, data) in (listCMSensorData.enumerated()) {
            if (abs(Double(index).remainder(dividingBy: intervalSeconds*50.0)) < tol) {
                let stringData = "\((data as AnyObject).timestamp!),\((data as AnyObject).acceleration.x),\((data as AnyObject).acceleration.y),\((data as AnyObject).acceleration.z)\n"
                appendDataToFile(string: stringData, fileurl: fileURL)
                //print(index, data)
            }
        }
        
    }
    return stringreturn
}

//
// Motion data acquisition
//

let motionManager = CMMotionManager()

func startMotionSensorUpdates(intervalSeconds: Double)->String{
    var stringreturn = "Default motion sensor"
    if motionManager.isDeviceMotionAvailable{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileURL = docsDirect.appendingPathComponent(sensorDataFileName)
        let stringfirstline = "Timestamp,DateTimeMilisec,Pitch,Roll,Yaw,RotX,RotY,RotZ,GravX,GravY,GravZ,AxelX,AxelY,AxelZ\n"
        creatDataFile(onetimestring: stringfirstline, fileurl: fileURL)
        motionManager.deviceMotionUpdateInterval = intervalSeconds
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!,withHandler: {
            (motion:CMDeviceMotion?, error:Error?) in
            saveMotionData(deviceMotion: motion!, fileurl: fileURL)
        })
        stringreturn = "Started motion sensor DAQ with "+String(intervalSeconds)+"s"
    } else{
    stringreturn = "Failed motion sensor DAQ"
    }
    return stringreturn
}

func getMotionData(deviceMotion: CMDeviceMotion){
    print("attitudeX:", deviceMotion.attitude.pitch)
    print("attitudeY:", deviceMotion.attitude.roll)
    print("attitudeZ:", deviceMotion.attitude.yaw)
    print("gyroX:", deviceMotion.rotationRate.x)
    print("gyroY:", deviceMotion.rotationRate.y)
    print("gyroZ:", deviceMotion.rotationRate.z)
    print("gravityX:", deviceMotion.gravity.x)
    print("gravityY:", deviceMotion.gravity.y)
    print("gravityZ:", deviceMotion.gravity.z)
    print("accX:", deviceMotion.userAcceleration.x)
    print("accY:", deviceMotion.userAcceleration.y)
    print("accZ:", deviceMotion.userAcceleration.z)
}

func saveMotionData(deviceMotion: CMDeviceMotion, fileurl: URL){
    let datetimemilisecstring = getDateTimeMilisecString()
    let string = "\(deviceMotion.timestamp), \(datetimemilisecstring),\(deviceMotion.attitude.pitch),\(deviceMotion.attitude.roll),\(deviceMotion.attitude.yaw),\(deviceMotion.rotationRate.x),\(deviceMotion.rotationRate.y),\(deviceMotion.rotationRate.z),\(deviceMotion.gravity.x),\(deviceMotion.gravity.y),\(deviceMotion.gravity.z),\(deviceMotion.userAcceleration.x),\(deviceMotion.userAcceleration.y),\(deviceMotion.userAcceleration.z)\n"
    appendDataToFile(string: string, fileurl: fileurl)
}

func stopMotionSensorUpdates()->String {
    if motionManager.isDeviceMotionAvailable{
        motionManager.stopDeviceMotionUpdates()
        return "Stopped motion sensor updates."
    }else {
        return "Failed stopping motion sensor updates"
    }
}


//
// Common data file handling functions
//

func testDataFileSave()->String{
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docsDirect = paths[0]
    let fileURL = docsDirect.appendingPathComponent(sensorDataFileName)
    creatDataFile(onetimestring: "First line\n", fileurl: fileURL)
    appendDataToFile(string: "Second line\n", fileurl: fileURL)
    return "Saved test data file"
}

func creatDataFile(onetimestring: String, fileurl: URL){
    if FileManager.default.fileExists(atPath: fileurl.path) {
      do {
        try FileManager.default.removeItem(atPath: fileurl.path)
      } catch {
          print("Existing sensor data file cannot be deleted.")
      }
    }
    let data = onetimestring.data(using: .utf8)
    if FileManager.default.createFile(atPath: fileurl.path, contents: data, attributes: nil){
        print("Data file was created successfully.")
    } else {
        print("Failed creating data file.")
    }
}

func appendDataToFile(string: String, fileurl: URL){
    if let outputStream = OutputStream(url: fileurl, append: true) {
        outputStream.open()
        let data = string.data(using: .utf8)!
        let bytesWritten = outputStream.write(string, maxLength: data.count)
        if bytesWritten < 0 { print("Data write(append) failed.") }
        outputStream.close()
    } else {
        print("Unable to open file for appending data.")
    }
}
