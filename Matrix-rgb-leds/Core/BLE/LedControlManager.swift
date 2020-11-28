//
//  LedControlManager.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import Foundation

let LEDController = LedControlManager.sharedInstance

class LedControlManager: NSObject {
    
    typealias SettigsCallbackClosure = (_ settings: LightsStateResponse) -> Void
    var settingsallback: SettigsCallbackClosure?
    
    public static let sharedInstance: LedControlManager = {
        let instance = LedControlManager()
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    func sendPing(callback: @escaping (_ isSuccess: Bool) -> Void) {
        makeCommandAndSend(data: Data([0x00]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: LedStateCommand.self) { (status, response) in
            DispatchQueue.main.async {
                callback(status && response != nil)
            }
        }
    }
    
    func loadSetting(callback: @escaping (_ isSuccessful: Bool, _ response: LightsStateResponse?) -> Void) {
        makeCommandAndSend(data: Data([0x00]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: LedStateCommand.self) { (status, response) in
            DispatchQueue.main.async {
                guard status, let response = response else {
                    callback(false, nil)
                    return
                }
                
                if response is LightsStateResponse {
                    callback(true, (response as! LightsStateResponse))
                } else {
                    callback(false, nil)
                }
            }
        }
    }
    
    func setMode(_ id: Int, speed: UInt8 = 50, callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x08
        let modeId:UInt8 = UInt8(id)
//        let theSpeed:UInt8
//        if speed > 254 {
//            theSpeed = UInt8(254)
//        } else if speed < 30 {
//            theSpeed = UInt8(30)
//        } else {
//            theSpeed = UInt8(speed)
//        }
         
        makeCommandAndSend(data: Data([commandId, 0x00, modeId, speed]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: SetModeCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                guard status, let response = response else {
                    callback(false)
                    return
                }
                
                if response is CommonStatusResponse {
                    callback((response as! CommonStatusResponse).status)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    func playMode(pause: Bool, callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x10
        let command:UInt8 = pause ? 0x01 : 0x00
         
        makeCommandAndSend(data: Data([commandId, command]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: LedStateCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                callback(status)
                guard status, let response = response, response is LightsStateResponse else { return }
                DispatchQueue.main.async {
                    self.settingsallback?(response as! LightsStateResponse)
                }
            }
        }
    }
    
    func prevModeCmd(callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x10
        let command:UInt8 = 0x02
         
        makeCommandAndSend(data: Data([commandId, command]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: LedStateCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                callback(status)
                guard status, let response = response, response is LightsStateResponse else { return }
                DispatchQueue.main.async {
                    self.settingsallback?(response as! LightsStateResponse)
                }
            }
        }
    }
    
    func nextModeCmd(callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x10
        let command:UInt8 = 0x03
         
        makeCommandAndSend(data: Data([commandId, command]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: LedStateCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                callback(status)
                guard status, let response = response, response is LightsStateResponse else { return }
                DispatchQueue.main.async {
                    self.settingsallback?(response as! LightsStateResponse)
                }
            }
        }
    }
    
    func effectPlayTime(minutes: UInt8, callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x11
         
        makeCommandAndSend(data: Data([commandId, minutes]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: SetModeCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                guard status, let response = response else {
                    callback(false)
                    return
                }
                
                if response is CommonStatusResponse {
                    callback((response as! CommonStatusResponse).status)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    func effectSpeed(_ speed: UInt8, callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x0f
         
        makeCommandAndSend(data: Data([commandId, speed]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: SetModeCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                guard status, let response = response else {
                    callback(false)
                    return
                }
                
                if response is CommonStatusResponse {
                    callback((response as! CommonStatusResponse).status)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    func matrixBrightness(_ brightness: UInt8, callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x04
         
        makeCommandAndSend(data: Data([commandId, brightness]),
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: SetModeCommand.self) { (status, response) in
            
            DispatchQueue.main.async {
                guard status, let response = response else {
                    callback(false)
                    return
                }
                
                if response is CommonStatusResponse {
                    callback((response as! CommonStatusResponse).status)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    fileprivate func sendCommand(_ command: UInt32, callback: @escaping (_ isSuccessful: Bool) -> Void) {
        let commandId:UInt8 = 0x02
        
        var commandData = Data()
        commandData.append(Data([commandId]))
        commandData.append(Data([ UInt8(command & 0x000000FF) ]))
//        commandData.append(Data([
//            UInt8(command & 0x000000FF),
//            UInt8((command & 0x0000FF00) >> 8),
//            UInt8((command & 0x00FF0000) >> 16),
//            UInt8((command & 0xFF000000) >> 24)
//            ]))
        
        makeCommandAndSend(data: commandData,
                           isWaitResponse: true, isWriteWithResponse: true,
                           command: SendCmdCommand.self) { (status, response) in
            callback(status)
            guard status, let response = response, response is LightsStateResponse else { return }
            DispatchQueue.main.async {
                self.settingsallback?(response as! LightsStateResponse)
            }
        }
    }
    
    func makeCommandAndSend<T: BLERequestInitializable>(data: Data, isWaitResponse: Bool,
                                                        isWriteWithResponse: Bool, command: T.Type,
                                                        callback: @escaping (_ isSuccessful: Bool, _ response: BLEResponse?) -> Void) {
        
        let request = CommonRequest(rawData: data, requestCharacteristic: "FFE1", responseCharacteristic: "FFE1")
        request.timeout = 2
        request.isWaitResponse = isWaitResponse
        request.isWriteWithResponse = isWriteWithResponse
        request.mode = .write
        request.retryCount = 1
        
        let command = command.init(with: request) as! BLECommand
        command.responseCallback = { (status, response, error) in
            dLog("status: \(status)")
            dLog("response: \(response?.dataAsString().orNil ?? "")")
            dLog("error: \(error.orNil)")
            callback(status == .success, response)
        }

        BLEManager.currentDevice?.addCommandToQueue(command)
    }
    
}


