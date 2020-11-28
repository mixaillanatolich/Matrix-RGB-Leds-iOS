//
//  LedControlViewController.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

public protocol LedControlScreenDelegate : NSObjectProtocol {
    func pairControllerWillDismiss()
}

class LedControlViewController: BaseViewController {

    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var controlLabel: UILabel!
    @IBOutlet weak var effectsTable: UITableView!
    
    @IBOutlet weak var showMoreOptionsButton: UIButton!
    @IBOutlet weak var controlViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var prevEffectButton: UIButton!
    @IBOutlet weak var nextEffectButton: UIButton!
    
    @IBOutlet weak var brightnessLabel: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBOutlet weak var effectSpeedLabel: UILabel!
    @IBOutlet weak var effectSpeedSlider: UISlider!
    
    @IBOutlet weak var effectTimeLabel: UILabel!
    @IBOutlet weak var effectTimeSlider: UISlider!
    
    @UserDefaultOptionl<String>(key: .deviceId, defaultValue: nil) var deviceId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LEDController.settingsallback = { (settings) in
            self.parseSettings(settings)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenDidShow()
    }
    
    fileprivate func parseSettings(_ response: LightsStateResponse) {

        dLog("\n\tsettings \n\teffectId: \(response.effectId) \n\tisAutoPlayMode: \(response.isAutoPlayMode)")
        
        stopButton.isSelected = !response.isAutoPlayMode
        
        if response.effectId < effects.count {
            effectsTable.selectRow(at: IndexPath(row: response.effectId, section: 0), animated: true, scrollPosition: .middle)
        }
        
        brightnessLabel.text = "Brightness \(response.brightness)"
        brightnessSlider.value = Float(response.brightness)
        
        effectSpeedLabel.text = "Effect Speed \(response.effectSpeed)"
        effectSpeedSlider.value = Float(response.effectSpeed)
        
        effectTimeLabel.text = "Effect Time \(response.effectChangeTimeout)"
        effectTimeSlider.value = Float(response.effectChangeTimeout)
    }
    
    //MARK: -
    @IBAction func pairButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowPairScreen", sender: {(destVC: UIViewController) in
            destVC.presentationController?.delegate = self
        } as SegueSenderCallback)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        LEDController.loadSetting(callback: { (result, response) in
            if result {
                self.parseSettings(response!)
            }
        })
    }
    
    @IBAction func showMoreOptionsButtonClicked(_ sender: Any) {
        showMoreOptionsButton.isSelected = !showMoreOptionsButton.isSelected
        showMoreOptionsButton.isUserInteractionEnabled = false
        controlViewHeightConstraint.constant = showMoreOptionsButton.isSelected ? 275.0 : 210.0
        UIView.animate(withDuration: 0.8, animations: {
                self.view.layoutIfNeeded()
            }, completion: {res in
                self.showMoreOptionsButton.isUserInteractionEnabled = true
        })
    }
    
    // MARK: - control commands
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isEnabled = false
        
        LEDController.playMode(pause: sender.isSelected) { (status) in
            DispatchQueue.main.async {
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func prevEffectButtonClicked(_ sender: UIButton) {
        sender.isEnabled = false
        LEDController.prevModeCmd { (status) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func nextEffectButtonClicked(_ sender: UIButton) {
        sender.isEnabled = false
        LEDController.nextModeCmd { (status) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func brightnessSliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        
        brightnessLabel.text = "Brightness \(value)"
    }
    
    @IBAction func brightnessSliderTouchUp(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        
        brightnessLabel.text = "Brightness \(value)"
        
        LEDController.matrixBrightness(UInt8(value)) { (response) in
        }
    }
    
    @IBAction func effectSpeedSliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        
        effectSpeedLabel.text = "Effect Speed \(value)"
    }
    
    @IBAction func effectSpeedSliderTouchUp(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        
        effectSpeedLabel.text = "Effect Speed \(value)"
        
        LEDController.effectSpeed(UInt8(value)) { (response) in
        }
    }
    
    @IBAction func effectTimeSliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        
        effectTimeLabel.text = "Effect Time \(value)"
    }
    
    @IBAction func effectTimeSliderTouchUp(_ sender: UISlider) {
        let value = Int(sender.value)
        sender.value = Float(value)
        
        effectTimeLabel.text = "Effect Time \(value)"
        
        LEDController.effectPlayTime(minutes: UInt8(value)) { (response) in
        }
    }
    
    
    //MARK: -
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LedControlViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        DispatchQueue.main.async {
            self.screenDidShow()
        }
    }
}

extension LedControlViewController: LedControlScreenDelegate {
    func pairControllerWillDismiss() {
        DispatchQueue.main.async {
            self.screenDidShow()
        }
    }
}

extension LedControlViewController {
    
    fileprivate func screenDidShow() {
        
        BLEManager.setupConnectStatusCallback { (connectStatus, peripheral, devType, error) in
            
            dLog("conn status: \(connectStatus)")
            dLog("error: \(error.orNil)")
            
            if connectStatus == .ready {
                DispatchQueue.main.async {
                    self.controlLabel.textColor = UIColor.green
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.buttonClicked(self)
                }
            } else if connectStatus == .error || connectStatus == .timeoutError || connectStatus == .disconected {
                DispatchQueue.main.async {
                    self.controlLabel.textColor = UIColor.yellow
                    BLEManager.connectToDevice(peripheral!, deviceType: .expectedDevice,
                                               serviceIds: [CBUUID(string: "FFE0")],
                                               characteristicIds: [CBUUID(string: "FFE1")], timeout: 30.0)
                }
            }
        }
          
        self.controlLabel.textColor = UIColor.white
        
        guard !BLEManager.deviceConnected() else {
            self.controlLabel.textColor = UIColor.green
//            self.loadSettings()
            return
        }
          
        guard let deviceId = deviceId else {
            return
        }
        
        guard let peripheral = BLEManager.canConnectToPeripheral(with: deviceId) else {
            return
        }
        
        self.controlLabel.textColor = UIColor.yellow
        BLEManager.connectToDevice(peripheral, deviceType: .expectedDevice,
                                   serviceIds: [CBUUID(string: "FFE0")],
                                   characteristicIds: [CBUUID(string: "FFE1")],
                                   device: LedDevicePeripheral.self, timeout: 30.0)
    }
    
}

/*
 Эффекты:
  sparklesRoutine();    // случайные цветные гаснущие вспышки
  snowRoutine();        // снег
  matrixRoutine();      // "матрица"
  starfallRoutine();    // звездопад (кометы)
  ballRoutine();        // квадратик
  ballsRoutine();       // шарики
  rainbowRoutine();     // радуга во всю матрицу горизонтальная
  rainbowDiagonalRoutine();   // радуга во всю матрицу диагональная
  fireRoutine();        // огонь

Крутые эффекты "шума":
  madnessNoise();       // цветной шум во всю матрицу
  cloudNoise();         // облака
  lavaNoise();          // лава
  plasmaNoise();        // плазма
  rainbowNoise();       // радужные переливы
  rainbowStripeNoise(); // полосатые радужные переливы
  zebraNoise();         // зебра
  forestNoise();        // шумящий лес
  oceanNoise();         // морская вода

 */

fileprivate let effects = ["Badness Noise",
                           "Cloud Noise",
                           "Lava Noise",
                           "Plasma Noise",
                           "Rainbow Noise",
                           "Rainbow Stripe Noise",
                           "Zebra Noise",
                           "Forest Noise",
                           "Ocean Noise",
                           "Snow Routine",
                           "Sparkles Routine",
                           "Matrix Routine",
                           "Starfall Routine",
                           "Ball Routine",
                           "Balls Routine",
                           "Rainbow Routine",
                           "Rainbow Diagonal Routine",
                           "Fire Routine",
                         //  "brightnessRoutine",
                         //  "Colors Routine",
                          // "rainbowColorsRoutine"
                            ]

extension LedControlViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return effects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = effects[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LEDController.setMode(indexPath.row, speed: UInt8(effectSpeedSlider.value)) { (res) in
            if !res {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
