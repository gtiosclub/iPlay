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
    var tilt: Double = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
    
    func startFetchingMotionData() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            timer = Timer(fire: Date(), interval: motionManager.deviceMotionUpdateInterval, repeats: true, block: { (timer) in
                if let data = self.motionManager.deviceMotion {
                    self.tilt = data.attitude.roll
                }
            })
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
        } else {
            print("Device motion is unavailable.")
        }
    }
}
#endif
