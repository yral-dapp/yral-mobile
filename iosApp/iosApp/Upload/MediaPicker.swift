//
//  MediaPicker.swift
//  iosApp
//
//  Created by Sarvesh Sharma on 10/02/25.
//  Copyright © 2025 orgName. All rights reserved.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers 

class VideoPickerViewController: UIViewController {
  func showVideoPickerOptions() {
    let alert = UIAlertController(title: "Select Video Source", message: nil, preferredStyle: .actionSheet)

    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
        self.openCamera()
      }))
    }

    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
        self.openPhotoLibrary()
      }))
    }

    alert.addAction(UIAlertAction(title: "File Manager", style: .default, handler: { _ in
      self.openDocumentPicker()
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    self.present(alert, animated: true)
  }

  func openCamera() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .camera
    picker.mediaTypes = ["public.movie"]
    picker.videoMaximumDuration = 60
    self.present(picker, animated: true)
  }

  func openPhotoLibrary() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    picker.mediaTypes = ["public.movie"]
    self.present(picker, animated: true)
  }

  func openDocumentPicker() {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie])
    documentPicker.delegate = self
    self.present(documentPicker, animated: true)
  }

  private func validateVideo(url: URL) -> Bool {
    let asset = AVAsset(url: url)
    let durationSeconds = CMTimeGetSeconds(asset.duration)
    if durationSeconds > 60 {
      let alert = UIAlertController(title: "Error", message: "Selected video exceeds 60 seconds.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alert, animated: true)
      return false
    }
    print("Video is valid. Duration: \(durationSeconds) seconds")
    return true
  }
}

extension VideoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    picker.dismiss(animated: true)

    if let mediaURL = info[.mediaURL] as? URL {
      if validateVideo(url: mediaURL) {
        print("Video selected: \(mediaURL)")
      }
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
}

extension VideoPickerViewController: UIDocumentPickerDelegate {

  func documentPicker(_ controller: UIDocumentPickerViewController,
                      didPickDocumentsAt urls: [URL]) {
    controller.dismiss(animated: true)
    if let url = urls.first, validateVideo(url: url) {
      print("Video selected from File Manager: \(url)")
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    controller.dismiss(animated: true)
  }
}
