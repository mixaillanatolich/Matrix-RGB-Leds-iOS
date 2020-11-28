//
//  GyverStateResponse.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import Foundation

class LightsStateResponse: BLEResponse {

    var isNotification = false
    var isAutoPlayMode = false
    var effectId = 0
    var brightness: UInt8 = 0
    var effectSpeed: UInt8 = 0
    var effectChangeTimeout: UInt8 = 0
    
    override init?(rawData: Data?) {
        super.init(rawData: rawData)
        
        guard let data = dataArray else {
            return nil
        }
        
        guard data.count >= 4 && (data[0] == 0xB4 || data[0] == 0xB5) else {
            return nil
        }
        
        guard data.count-2 == data[1] else {
            return nil
        }
        
        isNotification = data[0] == 0xB4
        isAutoPlayMode = data[2] == 0x01
        effectId = Int(data[3])
        brightness = data[4]
        effectSpeed = data[5]
        effectChangeTimeout = data[6]
    }
}
