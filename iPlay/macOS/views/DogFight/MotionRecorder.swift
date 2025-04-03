//
//  MotionRecorder.swift
//  iPlay
//
//  Created by Rexxwell Tendean on 4/2/25.
//

#if os(iOS)
import CoreMotion

class MotionRecorder {
    let motionManager: CMMotionManager = CMMotionManager()
    var timer: Timer?
    var dogFightPlayer: DogFightPlayer
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
    
    func startFetchingMotionData() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            timer = Timer(fire: Date(), interval: motionManager.deviceMotionUpdateInterval, repeats: true, block: { (timer) in
                if let data = self.motionManager.deviceMotion {
                    while (self.dogFightPlayer.lives != 0) {
                        let x = data.attitude.pitch
                        let y = data.attitude.roll
                        let z = data.attitude.yaw
                    }
                    self.motionManager.stopDeviceMotionUpdates()
                    timer.invalidate()
                }
            })
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
        } else {
            print("Device motion is unavailable.")
        }
    }
}
#endif
