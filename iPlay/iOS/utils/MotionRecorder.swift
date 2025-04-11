//
//  MotionRecorder.swift
//  iPlay
//
//  Created by Rexxwell Tendean on 4/2/25.
//

#if os(iOS)
import CoreMotion

class MotionRecorder: ObservableObject {
    let motionManager: CMMotionManager = CMMotionManager()
    var timer: Timer?
    @Published var tilt: Double = 0.0
    
    func startFetchingMotionData() {
        motionManager.deviceMotionUpdateInterval = 0.1 //change interval if needed
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let data = self.motionManager.deviceMotion {
                    DispatchQueue.main.async {
                        self.tilt = data.attitude.roll
                    }
                }
            }
        } else {
            print("Device motion is unavailable.")
        }
    }
    
    deinit {
        timer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
    }
    
}
#endif
