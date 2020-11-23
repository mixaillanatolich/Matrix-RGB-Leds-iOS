//
//  ResponseFactory.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import Foundation

class ResponseFactory: BLEResponseFactory {

    override func handleNotificationRawResponse(rawData: Data) -> BLEResponse? {
        if let response = LightsStateResponse(rawData: rawData) {
            if response.isNotification {
                return response
            }
        }
        return nil
    }
    
    override func handleNotificationResponse(message: BLEResponse) {
        dLog("need send notification for \(message)")
        guard message is LightsStateResponse else { return }
        DispatchQueue.main.async {
            LEDController.settingsallback?(message as! LightsStateResponse)
        }
    }
    
}
