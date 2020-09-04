//
//  DataCollecter.swift
//  WatchDataLogger01
//
//  Created by Uno on 2020/09/01.
//  Copyright © 2020 uno. All rights reserved.
//

import Foundation
import CoreMotion

let motionManager = CMMotionManager()

func startSensorUpdates(intervalSeconds: Double)->String{
    if motionManager.isDeviceMotionAvailable{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileURL = docsDirect.appendingPathComponent(sensorDataFileName)
        let stringfirstline = "Timestamp,Pitch,Roll,Yaw,RotionX,RotionY,RotationZ,GravityX,GravityY,GravityZ,AxelX,AxelY,AxelZ\n"
        creatDataFile(onetimestring: stringfirstline, fileurl: fileURL)
        motionManager.deviceMotionUpdateInterval = intervalSeconds
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!,withHandler: {
            (motion:CMDeviceMotion?, error:Error?) in
            //getMotionData(deviceMotion: motion!)
            saveMotionData(deviceMotion: motion!, fileurl: fileURL)
        })
        return "Started sensor updates with "+String(intervalSeconds)+"s"
    } else{
    return "Failed to start sensor updates"
    }
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
    let string = "\(deviceMotion.timestamp),\(deviceMotion.attitude.pitch),\(deviceMotion.attitude.roll),\(deviceMotion.attitude.yaw),\(deviceMotion.rotationRate.x),\(deviceMotion.rotationRate.y),\(deviceMotion.rotationRate.z),\(deviceMotion.gravity.x),\(deviceMotion.gravity.y),\(deviceMotion.gravity.z),\(deviceMotion.userAcceleration.x),\(deviceMotion.userAcceleration.y),\(deviceMotion.userAcceleration.z)\n"
    appendDataToFile(string: string, fileurl: fileurl)
}

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

func stopSensorUpdates()->String {
    if motionManager.isDeviceMotionAvailable{
        motionManager.stopDeviceMotionUpdates()
        return "Stopped sensor updates."
    }else {
        return "Failed stopping sensor updates"
    }
}