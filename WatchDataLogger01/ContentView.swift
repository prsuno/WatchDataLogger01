//
//  ContentView.swift
//  WatchDataLogger01
//
//  Created by uno on 2019/12/31.
//  Copyright © 2019 uno. All rights reserved.
//

import SwiftUI
import AVFoundation

var audioRecorder: AVAudioRecorder?
var audioPlayer: AVAudioPlayer?

struct ContentView: View {
    
    @State public var intStatus: Int = 0
    @State public var strStatus: String = "status"
    
    var body: some View {
        VStack {
            Text("intStatus: \(self.intStatus)")
            Text("strStatus: \(self.strStatus)")
            Button(action:{
                self.intStatus = 1
                //self.strStatus = getDateTimeString()
                self.strStatus = startRecording()
                //self.strStatus = getAudioFileURLString()
            })
                {
                Text("Start")
            }
            Button(action:{
                self.intStatus = 0
                self.strStatus = finishRecording()
            })
                {
                Text("Stop")
            }
        }
    }
}

func getDateTimeString() -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy_MMdd_HHmmss"
    let now = Date()
    return f.string(from: now)
}

func getAudioFileURL() -> URL{
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docsDirect = paths[0]
    let audioURL = docsDirect.appendingPathComponent(getDateTimeString()+".m4a")
    return audioURL
}

func startRecording()-> String{
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
        return "In progress"
    }
    catch {
        return "Error occured"
    }
}

func finishRecording()->String{
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
        return "Playing audio successfully started."
    }
    catch {
        return "Error in playing process."
    }
}

func finishPlaying()->String{
    audioPlayer?.stop()
    return "Playing audio finished successfully."
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
