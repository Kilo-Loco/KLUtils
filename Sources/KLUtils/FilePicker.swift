//
//  FilePicker.swift
//
//
//  Created by Kilo Loco on 11/22/23.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

public enum SelectedFileType {
    case image(UIImage)
    case video(URL)
    case document(Data)
    case unknown
}

public struct FilePicker: UIViewControllerRepresentable {
    
    @Binding public var selectedFile: SelectedFileType
    @Environment(\.dismiss) public var dismiss
    
    public typealias UIViewControllerType = PHPickerViewController
    
    public func makeCoordinator() -> FilePickerCoordinator {
        FilePickerCoordinator(filePicker: self)
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

public class FilePickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    
    public let filePicker: FilePicker
    
    public init(filePicker: FilePicker) {
        self.filePicker = filePicker
    }
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        filePicker.dismiss.callAsFunction()
        
        guard let provider = results.first?.itemProvider else {
            self.filePicker.selectedFile = .unknown
            return
        }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.filePicker.selectedFile = .image(image)
                    } else {
                        self?.filePicker.selectedFile = .unknown
                    }
                }
            }
        } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                DispatchQueue.main.async {
                    if let url = url {
                        self?.filePicker.selectedFile = .video(url)
                    } else {
                        self?.filePicker.selectedFile = .unknown
                    }
                }
            }
        } else {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.content.identifier) { [weak self] (data, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        self?.filePicker.selectedFile = .document(data)
                    } else {
                        self?.filePicker.selectedFile = .unknown
                    }
                }
            }
        }
    }
}
