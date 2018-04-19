//
//  kana_sound.swift
//  Xylophone
//
//  Created by Hoijan Lai on 03/02/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation
import AudioToolbox

class Sound {
    var soundEffect: SystemSoundID = 0
    init(name: String, type: String = "wav") {
        let path = Bundle.main.path(forResource: name, ofType: type)!
        let pathURL = NSURL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(pathURL as CFURL, &soundEffect)
    }
    func play() {
        AudioServicesPlaySystemSound(soundEffect)
    }
}
