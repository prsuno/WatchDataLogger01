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

func startSensorUpdates(intervalSeconds: Double){
    if motionManager.isDeviceMotionAvailable{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let datafileURL = docsDirect.appendingPathComponent(sensorDataFileName)
        writeDataToFile(string: "attitudeX,attitudeY,attitudeZ,gyroX,gyroY,gyroZ,gravityX,gravityY,gravityZ,accX,accY,accZ\n", tofile: datafileURL)
        motionManager.deviceMotionUpdateInterval = intervalSeconds
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!,withHandler: {
            (motion:CMDeviceMotion?, error:Error?) in getMotionData(deviceMotion: motion!)
        })
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

func saveMotionData(deviceMotion: CMDeviceMotion, fileURL: URL){
    writeDataToFile(string: "\(deviceMotion.attitude.pitch),attitudeY,attitudeZ,gyroX,gyroY,gyroZ,gravityX,gravityY,gravityZ,accX,accY,accZ\n", tofile: fileURL)
    print("attitudeX:", deviceMotion.attitude.pitch)
}

func testDataFileSave(){
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docsDirect = paths[0]
    let fileURL = docsDirect.appendingPathComponent(sensorDataFileName)
    if FileManager.default.fileExists(atPath: fileURL.path) {
      do {
        try FileManager.default.removeItem(atPath: fileURL.path)
      } catch {
          print("Existing sensor data file cannot be deleted.")
      }
    }
    let string = "First line"
    let data = string.data(using: .utf8)
    if FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil){
        print("Data file was created successfully.")
    } else {
        print("Failed creating data file.")
    }
}

func writeDataToFile(string: String, tofile: URL){
    let data = string.data(using: .utf8)
    
    do{
        try data?.write(to: tofile)
        print("Data saved : \(tofile.absoluteURL)")
    } catch {
        print(error.localizedDescription)
    }
}

func stopSensorUpdates() {
    if motionManager.isDeviceMotionAvailable{
        motionManager.stopDeviceMotionUpdates()
    }
}
