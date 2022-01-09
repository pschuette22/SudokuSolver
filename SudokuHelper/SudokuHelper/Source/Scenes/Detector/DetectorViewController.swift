//
//  DetectorViewController.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 12/24/21.
//

import Foundation
import UIKit
import AVKit

final class DetectorViewController: ViewController<DetectorViewControllerState, DetectorViewControllerModel> {
    private let captureSession: AVCaptureSession = .init()
    private var videoDevice: AVCaptureDevice!
    private var bufferSize: CGSize = .zero
    private let previewContainer = UIView()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    private var detectedSudokuPreview: UIView?
    private let visionInputVerifierView: UIImageView = UIImageView()
    
    
    required init(model: DetectorViewControllerModel = .init()) {
        super.init(model: model)
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        endCaptureSession()
    }

    override func setupSubviews() {
        setupCaptureSession()
        setupPreviewLayer()
        setupVisionInputVerifier()
    }

    override func render(_ state: DetectorViewControllerState) {
        Logger.log(.debug, message: "Render DetectorViewControllerState", params: ["state": state])
        switch state.context {
        case .detecting:
            removeSudokuDetectionPreview()
            visionInputVerifierView.image = nil

        case let .detectedSudoku(image, size, frame, confidence):
            // TODO: Normalize frame to displayed image
            let scaleX = previewLayer.frame.width / size.width
            let scaleY = previewLayer.frame.height / size.height
            let scale = max(scaleX, scaleY)
            let translateX = (scale - scaleX) / (scale * 2)
            let translateY = (scale - scaleY) / (scale * 2)
            let translatedFrame = CGRect(
                x: frame.origin.x - translateX,
                y: frame.origin.y - translateY,
                width: frame.size.width + translateX,
                height: frame.size.height + translateY
            )
            
            let normalizedFrame = CGRect(
                x: translatedFrame.origin.x * previewLayer.frame.width,
                y: translatedFrame.origin.y * previewLayer.frame.height,
                width: translatedFrame.width * previewLayer.frame.width,
                height: translatedFrame.height * previewLayer.frame.height
            )

            drawSudokuDetectionPreview(frame: normalizedFrame, confidence: confidence)
            visionInputVerifierView.image = UIImage(cgImage: image)
            print("Drew it!")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = .init(origin: .zero, size: previewContainer.frame.size)
    }
}

// MARK: - Subview Helpers
extension DetectorViewController {
    func setupCaptureSession() {
        guard
            let videoDevice = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .back
            ).devices.first
        else {
            model.didFailToSetupCaptureSession()
            return
        }

        self.videoDevice = videoDevice
        
        let deviceInput: AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            Logger.log(.error, message: "Failed to setup capture session", params: ["error": error])
            model.didFailToSetupCaptureSession(error)
            return
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium

        guard captureSession.canAddInput(deviceInput) else {
            model.didFailToSetupCaptureSession()
            Logger.log(.error, message: "Could not add video device input to the session")
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(deviceInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let videoQueueLabel = (Bundle.main.bundleIdentifier ?? "") + ".videoOutputQueue"
        let videoDataOutputQueue = DispatchQueue(label: videoQueueLabel)
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        guard captureSession.canAddOutput(videoDataOutput) else {
            model.didFailToSetupCaptureSession()
            Logger.log(.error, message: "Could not add video data output to the session")
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addOutput(videoDataOutput)
                
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        captureConnection?.videoOrientation = .portrait

        bufferSize = CGSize()
        do {
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            Logger.log(.error, message: "failed to lock configuration", params: ["error": error])
        }

        captureSession.commitConfiguration()
    }
    
    func setupPreviewLayer() {
        view.addSubview(previewContainer)
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.clipsToBounds = true
        NSLayoutConstraint.activate([
            previewContainer.topAnchor.constraint(equalTo: view.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        previewLayer.contentsGravity = .resizeAspectFill
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.layer.addSublayer(previewLayer)
    }
    
    func setupVisionInputVerifier() {
        let size = CGSize(width: view.frame.width * 0.2, height: view.frame.height * 0.2)
        let originY = view.frame.height - size.height - 16
        let originX = view.frame.width - size.width - 16
        
        view.addSubview(visionInputVerifierView)
        visionInputVerifierView.frame = CGRect(origin: .init(x: originX, y: originY), size: size)
        visionInputVerifierView.backgroundColor = .clear
        visionInputVerifierView.contentMode = .scaleAspectFit
        visionInputVerifierView.clipsToBounds = false
    }
}

// MARK: - AVKit integrations

extension DetectorViewController {
    private func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        
        captureSession.startRunning()
        model.didStartCaptureSession()
    }

    private func endCaptureSession() {
        guard captureSession.isRunning else { return }
        
        captureSession.stopRunning()
        model.didEndCaptureSession()
    }
    
    private func imageFromSampleBuffer(
        sampleBuffer: CMSampleBuffer,
        videoOrientation: AVCaptureVideoOrientation
    ) -> (image: CGImage, size: CGSize)? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let context = CIContext()
        var `ciImage` = CIImage(cvPixelBuffer: imageBuffer)
        
        var orientation: CGImagePropertyOrientation
        var imageSize = bufferSize
        switch videoOrientation {
        case .portrait:
            orientation = .up
//            imageSize = .init(width: bufferSize.height, height: bufferSize.width)
        case .portraitUpsideDown:
            orientation = .down
//            imageSize = .init(width: bufferSize.height, height: bufferSize.width)
        case .landscapeRight:
            orientation = .left
        case .landscapeLeft:
            orientation = .right
        @unknown default:
            Logger.log(.error, message: "Unrecognized video orientation", params: ["orientation": videoOrientation])
            orientation = .left
        }

        ciImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return (image: cgImage, size: imageSize)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension DetectorViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            let imageData = imageFromSampleBuffer(
                sampleBuffer: sampleBuffer,
                videoOrientation: connection.videoOrientation
            )
        else {
            model.didNotDetectSudoku()
            return
        }
        
        DispatchQueue.main.async { [weak self, imageData] in
            self?.model.findSudoku(
                in: imageData.image,
                bufferSize: imageData.size
            )
        }
    }
}

// MARK: - Sudoku Detection Preview Helpers

private extension DetectorViewController {
    func removeSudokuDetectionPreview() {
        detectedSudokuPreview?.removeFromSuperview()
        detectedSudokuPreview = nil
    }
    
    func drawSudokuDetectionPreview(frame: CGRect, confidence: Float) {
        removeSudokuDetectionPreview()
        
        let preview = UIView(frame: frame)
        preview.backgroundColor = .clear
        preview.layer.borderColor = UIColor.yellow.withAlphaComponent(CGFloat(confidence)).cgColor
        preview.layer.borderWidth = 3.0
        previewContainer.addSubview(preview)
        detectedSudokuPreview = preview
    }
    
}
