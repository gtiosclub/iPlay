//
//  CameraVM.swift
//  iPlay
//
//  Created by Danny Byrd on 4/10/25.
//

#if os(iOS)

import Foundation
import CoreImage
import Observation

@Observable
class CameraViewModel {
    var currentFrame: CGImage?
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}

#endif
