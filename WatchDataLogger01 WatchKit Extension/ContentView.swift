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
    
    @State public var strStatus: String = "status"
    
    var body: some View {
        VStack {
            ScrollView{
                Text("strStatus: \(self.strStatus)")
                Button(action:{
                    self.strStatus = self.startAudioRecording()
                    //self.strStatus = getAudioFileURLString()
                })
                    {
                    Text("REC audio")
                }
                Button(action:{
                    self.strStatus = self.finishAudioRecording()
                })
                    {
                    Text("Stop REC")
                }
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
                    Text("Stop Play")
                }
                Button(action:{
                    self.strStatus = self.fileTransfer(fileURL: self.getAudioFileURL(), metaData: ["":""])
                })
                    {
                    Text("Send audio file")
                }
                Button(action:{
                    self.strStatus = startSensorUpdates(intervalSeconds: 1.0)
                })
                    {
                    Text("Start sensor DAQ")
                }
                Button(action:{
                    self.strStatus = stopSensorUpdates()
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
                 Button(action:{
                    self.strStatus = testDataFileSave()
                 })
                     {
                     Text("Save test file")
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
            return "PLY audio started."
        }
        catch {
            return "PLY audio error."
        }
    }
    
    func finishPlayAudio()->String{
        audioPlayer?.stop()
        return "Finished."
    }
    
    func fileTransfer(fileURL: URL, metaData: [String:String])->String{
        WCSession.default.transferFile(fileURL, metadata: metaData)
        return "File transfer initiated."
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
