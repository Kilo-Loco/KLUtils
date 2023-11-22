//
//  CameraView.swift
//  
//
//  Created by Kilo Loco on 11/22/23.
//

import SwiftUI
import AVFoundation

public enum CameraMediaType {
    case image(UIImage)
    case video(URL)
    case none
}

public struct CameraView: UIViewControllerRepresentable {
    
    @Binding public var mediaType: CameraMediaType
    @Environment(\.dismiss) public var dismiss
    
    public typealias UIViewControllerType = UIImagePickerController
    
    public func makeCoordinator() -> CameraPickerCoordinator {
        CameraPickerCoordinator(cameraPicker: self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

public class CameraPickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public let cameraPicker: CameraView
    
    public init(cameraPicker: CameraView) {
        self.cameraPicker = cameraPicker
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cameraPicker.mediaType = .none
        cameraPicker.dismiss.callAsFunction()
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraPicker.dismiss.callAsFunction()
        
        if let image = info[.originalImage] as? UIImage {
            cameraPicker.mediaType = .image(image)
        } else if let url = info[.mediaURL] as? URL {
            cameraPicker.mediaType = .video(url)
        } else {
            cameraPicker.mediaType = .none
        }
    }
}
