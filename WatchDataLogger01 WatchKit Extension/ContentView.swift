//
//  ContentView.swift
//  WatchDataLogger01 WatchKit Extension
//
//  Created by uno on 2019/12/31.
//  Copyright © 2019 uno. All rights reserved.
//

import SwiftUI
import AVFoundation
import WatchConnectivity

var audioRecorder: AVAudioRecorder?
var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    
    var valueSensingIntervals = [1.0, 2.0, 5.0, 10, 60, 0.5, 0.1, 0.05, 0.01]
    var valueSensingTypes = ["Audio", "Motion", "HeartRate", "Motion and HeartRate"]

    var workoutSession: WorkoutManager
    @State var workoutInProgress = false
    
    @State public var strStatus: String = "status"
    @State private var intSelectedInterval: Int = 0
    @State private var intSelectedTypes: Int = 0
    
    
    var body: some View {
        VStack {
            ScrollView{
                Text(self.strStatus)
                if workoutInProgress {
                    Text("Workout session: ON")
                } else {
                    Text("Workout session: OFF")
                }
                Button(action:{
                    if self.valueSensingTypes[self.intSelectedTypes] == "Audio" {
                        self.strStatus = self.startAudioRecording()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Motion" {
                        self.strStatus = startMotionSensorUpdates(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                        //self.startWorkoutSession()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "HeartRate" {
                        workoutSession.requestAuthorization()
                        workoutSession.startWorkout()
                        workoutInProgress = true
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Motion and HeartRate" {
                        workoutSession.requestAuthorization()
                        workoutSession.startWorkout()
                        workoutInProgress = true
                        self.strStatus = startMotionSensorUpdates(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                    }
                })
                    {
                    Text("Start sensor DAQ")
                }
                Button(action:{
                    if self.valueSensingTypes[self.intSelectedTypes] == "Audio" {
                        self.strStatus = self.finishAudioRecording()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Motion" {
                        self.strStatus = stopMotionSensorUpdates()
                        //self.stopWorkoutSession()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "HeartRate" {
                        workoutSession.endWorkout()
                        workoutInProgress = false
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Motion and HeartRate" {
                        self.strStatus = stopMotionSensorUpdates()
                        workoutSession.endWorkout()
                        workoutInProgress = false
                    }
                })
                    {
                    Text("Stop sensor DAQ")
                }
                Button(action:{
                    self.strStatus = self.fileTransfer(fileURL: self.getSensorDataFileURL(), metaData: ["":""])
                })
                    {
                    Text("Send sensor data")
                }
                Picker("Sensing data type", selection: $intSelectedTypes){
                    ForEach(0 ..< valueSensingTypes.count) {
                        Text(self.valueSensingTypes[$0])
                    }
                }.frame(height: 40)
                Picker("DAQ interval [s]", selection: $intSelectedInterval){
                    ForEach(0 ..< valueSensingIntervals.count) {
                        Text(String(self.valueSensingIntervals[$0]))
                    }
                }.frame(height: 40)
                Button(action:{
                    self.strStatus = self.playAudio()
                    //self.strStatus = getAudioFileURLString()
                })
                    {
                    Text("Play audio")
                }
                Button(action:{
                    self.strStatus = self.finishPlayAudio()
                })
                    {
                    Text("Stop audio")
                }
                Button(action:{
                    self.strStatus = self.fileTransfer(fileURL: self.getAudioFileURL(), metaData: ["":""])
                })
                    {
                    Text("Send audio file")
                }
            }
        }
    }
    

    
    func getAudioFileURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioURL = docsDirect.appendingPathComponent("recodringW.m4a")
        //let audioURL = docsDirect.appendingPathComponent(getDateTimeString()+".m4a")
        return audioURL
    }
    
    func getSensorDataFileURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileURL = docsDirect.appendingPathComponent("SensorData.csv")
        return fileURL
    }
    
    func startAudioRecording()-> String{
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            let settingsDictionary = [
                AVFormatIDKey:Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            try audioSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url:getAudioFileURL(),settings: settingsDictionary)
            audioRecorder!.record()
            return "REC audio in progress"
        }
        catch {
            return "REC audio error"
        }
    }
    
    func finishAudioRecording()->String{
        audioRecorder?.stop()
        return "Finished."
    }
    
    func playAudio()->String{
        let url = getAudioFileURL()
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            audioPlayer = sound
            sound.prepareToPlay()
            sound.play()
            return "Play audio started."
        }
        catch {
            return "Play audio error."
        }
    }
    
    func finishPlayAudio()->String{
        audioPlayer?.stop()
        return "Play audio finished."
    }
    
    func fileTransfer(fileURL: URL, metaData: [String:String])->String{
        WCSession.default.transferFile(fileURL, metadata: metaData)
        return "File transfer initiated."
    }
    
    // Convert the seconds into seconds, minutes, hours.
    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Convert the seconds, minutes, hours into a string.
    func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
        return String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(workoutSession: WorkoutManager())
    }
}


