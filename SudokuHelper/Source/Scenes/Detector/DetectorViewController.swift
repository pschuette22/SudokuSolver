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
    private let parsingContainerView = UIView()
    private var parsingSudokuImage: UIImageView?
    private var captureButton = UIButton(type: .custom)
    private var cellOverlayViews = [UIView]()
    
    required init(
        coordinatorIdentifier: UUID,
        model: DetectorViewControllerModel = .init()
    ) {
        super.init(
            coordinatorIdentifier: coordinatorIdentifier,
            model: model
        )
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
        setupParsingContainer()
//        #if DEBUG
//        setupVisionInputVerifier()
//        #endif
        setupCaptureButton()
    }

    override func render(_ state: DetectorViewControllerState) {
        previewContainer.isHidden = state.isPreviewLayerDisplayed == false
        parsingContainerView.isHidden = state.isParsingViewDisplayed == false
        captureButton.isHidden = state.isCaptureButtonHidden
        captureButton.alpha = state.captureButtonAlpha
        captureButton.setTitle(state.captureButtonText, for: .normal)

        switch state.context {
        case .detecting:
            removeSudokuDetectionPreview()
            visionInputVerifierView.image = nil
            startCaptureSession()

        case let .detectedSudoku(image, size, frame, confidence):
            let scaleX = previewLayer.frame.width / size.width
            let scaleY = previewLayer.frame.height / size.height
            let scale = max(scaleX, scaleY)
            let clippedWidth = ((scale - scaleX) * size.width) / 2
            let clippedHeight = ((scale - scaleY) * size.height) / 2
            let normalizedFrame = CGRect(
                x: (frame.origin.x * scale) - clippedWidth,
                y: (frame.origin.y * scale) - clippedHeight,
                width: frame.size.width * scale,
                height: frame.size.height * scale
            )

            drawSudokuDetectionPreview(frame: normalizedFrame, confidence: confidence)

            #if DEBUG
            visionInputVerifierView.image = UIImage(cgImage: image)
            #endif

        case let .parsingSudoku(image):
            endCaptureSession()
            drawCapturedSudoku(from: image)
            // TODO: some sort of parsing animation
        
        case let.locatedCells(image, cells):
            let drawingResult = drawCapturedSudoku(from: image)
            draw(locatedCells: cells, scale: drawingResult.scale)
            
        case let .parsedSudoku(image, imageSize, cells):
            print("did parse sudoku!")
//            let drawingResult = drawSudokuBeingParsed(from: image)
//            draw(locatedCells: cells, scale: drawingResult.scale)

        case let .solvedSudoku(image, imageSize, cells):
            let drawingResult = drawCapturedSudoku(from: image)
            let relevantCells = cells.flattened.filter { cell in
                switch cell.type {
                case .solved, .error:
                    return true
                case .unknown, .empty, .filled:
                    return false
                }
                
            }
            draw(locatedCells: relevantCells, scale: drawingResult.scale)
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
        captureSession.sessionPreset = .hd1280x720

        guard
            captureSession.canAddInput(deviceInput)
        else {
            model.didFailToSetupCaptureSession()
            Logger.log(.error, message: "Could not add video device input to the session")
            captureSession.commitConfiguration()
            return
        }

        captureSession.addInput(deviceInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_OneComponent32Float)]
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
            previewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            previewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        previewLayer.contentsGravity = .center
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.layer.addSublayer(previewLayer)
    }
    
    func setupParsingContainer() {
        view.addSubview(parsingContainerView)
        parsingContainerView.translatesAutoresizingMaskIntoConstraints = false
        parsingContainerView.clipsToBounds = true
        NSLayoutConstraint.activate([
            parsingContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            parsingContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            parsingContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            parsingContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupVisionInputVerifier() {
        let size = CGSize(width: view.frame.width * 0.2, height: view.frame.height * 0.2)
        let originY = view.frame.height - size.height - 16
        let originX = view.frame.width - size.width - 16
        
        view.addSubview(visionInputVerifierView)
        visionInputVerifierView.frame = CGRect(origin: .init(x: originX, y: originY), size: size)
        visionInputVerifierView.backgroundColor = .clear
        visionInputVerifierView.contentMode = .scaleAspectFit
        visionInputVerifierView.clipsToBounds = true
    }
    
    func setupCaptureButton() {
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.tintColor = .yellow
        captureButton.setTitleColor(.black, for: .normal)
        captureButton.isHidden = true
        captureButton.addTarget(self, action: #selector(didTapCaptureButton(_:)), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
            buttonConfiguration.cornerStyle = .capsule
            captureButton.configuration = buttonConfiguration
        } else {
            // Fallback on earlier versions
            captureButton.titleEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
            captureButton.layer.cornerRadius = 16
        }
        
        NSLayoutConstraint.activate([
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        ])
    }
    
    @objc
    func didTapCaptureButton(_ sender: Any?) {
        model.didTapCaptureButton()
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
        switch videoOrientation {
        case .portrait:
            orientation = .up
        case .portraitUpsideDown:
            orientation = .down
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
        
        return (image: cgImage, size: ciImage.extent.size)
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
            return
        }
        
        DispatchQueue.main.async { [weak self, imageData] in
            self?.model.findSudoku(
                in: imageData.image
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
    
    func drawSudokuDetectionPreview(frame: CGRect, confidence: CGFloat) {
        removeSudokuDetectionPreview()
        
        let preview = UIView(frame: frame)
        preview.backgroundColor = .clear
        preview.layer.borderColor = UIColor.yellow.withAlphaComponent(confidence).cgColor
        preview.layer.borderWidth = 3.0
        previewContainer.addSubview(preview)
        detectedSudokuPreview = preview
    }
    
    @discardableResult
    func drawCapturedSudoku(from image: CGImage) -> (image: UIImageView, scale: CGPoint) {
        parsingSudokuImage?.subviews.forEach { $0.removeFromSuperview() }
        parsingContainerView.isHidden = false
        parsingSudokuImage?.removeFromSuperview()
        let parsingSudokuImage = UIImageView(image: UIImage(cgImage: image))
        parsingSudokuImage.clipsToBounds = false
        parsingSudokuImage.contentMode = .scaleToFill
        parsingSudokuImage.translatesAutoresizingMaskIntoConstraints = false
        parsingContainerView.addSubview(parsingSudokuImage)
        parsingContainerView.clipsToBounds = false
        let scale = min(view.frame.width / CGFloat(image.width), view.frame.height / CGFloat(image.height))
        
        NSLayoutConstraint.activate([
            parsingSudokuImage.widthAnchor.constraint(equalToConstant: scale * CGFloat(image.width)),
            parsingSudokuImage.heightAnchor.constraint(equalToConstant: scale * CGFloat(image.height)),
            parsingSudokuImage.centerXAnchor.constraint(equalTo: parsingContainerView.centerXAnchor),
            parsingSudokuImage.centerYAnchor.constraint(equalTo: parsingContainerView.centerYAnchor),
        ])
        self.parsingSudokuImage = parsingSudokuImage
        
        return (image: parsingSudokuImage, scale: CGPoint(x: scale, y: scale))
    }
    
    func draw(locatedCells: [DetectorViewControllerState.LocatedCell], scale: CGPoint) {
        cellOverlayViews.forEach { $0.removeFromSuperview() }
        
        locatedCells.forEach {
            let scaledRect = CGRect(
                x: $0.frame.origin.x * scale.x,
                y: $0.frame.origin.y * scale.y,
                width: $0.frame.width * scale.x,
                height: $0.frame.height * scale.y
            )
            
            let boxView = UIView(frame: scaledRect)
            boxView.backgroundColor = .clear
            switch $0.type {
            case .filled:
                boxView.layer.borderColor = UIColor.magenta.cgColor
            case .empty:
                boxView.layer.borderColor = UIColor.yellow.cgColor
            case .unknown:
                boxView.layer.borderColor = UIColor.blue.cgColor
            case let .solved(value):
                let horizontalInset = scaledRect.width * 0.2
                let verticalInset = scaledRect.height * 0.2
                let width = scaledRect.width * 0.6
                let height = scaledRect.height * 0.6
                
                let solutionLabel = UILabel(frame: .init(x: horizontalInset, y: verticalInset, width: width, height: height))
                solutionLabel.text = "\(value)"
                solutionLabel.textAlignment = .center
                solutionLabel.textColor = .darkGray
                solutionLabel.font = UIFont.systemFont(ofSize: height)
                boxView.addSubview(solutionLabel)
                boxView.layer.borderColor = UIColor.clear.cgColor

            case .error:
                boxView.layer.borderColor = UIColor.red.cgColor
            }

            boxView.layer.borderWidth = 2
            self.parsingSudokuImage?.addSubview(boxView)
            cellOverlayViews.append(boxView)
        }
    }
}
