//
//  ViewController.swift
//  pip-camera
//
//  Created by Naruki Chigira on 2022/08/27.
//

import AVKit
import CoreMedia
import UIKit

class ViewController: UIViewController {
    /// AVSampleBufferDisplayLayer のコンテナとしてのビュー
    @IBOutlet private var layerContainerView: UIView!
    /// PiP 開始ボタン
    @IBOutlet private var startButton: UIButton! {
        didSet {
            startButton.setImage(AVPictureInPictureController.pictureInPictureButtonStartImage, for: .normal)
        }
    }
    /// PiP 停止ボタン
    @IBOutlet private var stopButton: UIButton! {
        didSet {
            stopButton.setImage(AVPictureInPictureController.pictureInPictureButtonStopImage, for: .normal)
            stopButton.isEnabled = false
        }
    }
    
    /// 描画先のレイヤー
    private let sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    
    private lazy var pictureInPictureController: AVPictureInPictureController = {
        let contentSource = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: sampleBufferDisplayLayer, playbackDelegate: self)
        let controller = AVPictureInPictureController(contentSource: contentSource)
        controller.requiresLinearPlayback = false
        controller.canStartPictureInPictureAutomaticallyFromInline = false
        return controller
    }()
    
    private lazy var cameraCapture = CameraCapture()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraCapture.configure()
        cameraCapture.delegate = self
        
        sampleBufferDisplayLayer.backgroundColor = UIColor.black.cgColor
        layerContainerView.layer.addSublayer(sampleBufferDisplayLayer)
        pictureInPictureController.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // sampleBufferDisplayLayer の配置調整
        layoutSampleBufferDisplayLayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !cameraCapture.isRunning {
            cameraCapture.start()
        }
    }

    private func layoutSampleBufferDisplayLayer() {
        sampleBufferDisplayLayer.frame = .init(origin: .zero, size: layerContainerView.frame.size)
    }
    
    @IBAction private func didTapStartButton(_ sender: UIButton) {
        debugPrint(pictureInPictureController.isPictureInPicturePossible)
        pictureInPictureController.startPictureInPicture()
    }
    
    @IBAction private func didTapStopButton(_ sender: UIButton) {
        pictureInPictureController.stopPictureInPicture()
    }
}

extension ViewController: CameraCaptureDelegate {
    func cameraCapture(_ cameraCapture: CameraCapture, didOutput sampleBuffer: CMSampleBuffer) {
        if sampleBufferDisplayLayer.status == .failed {
            pictureInPictureController.invalidatePlaybackState()
            sampleBufferDisplayLayer.flush()
        }
        sampleBufferDisplayLayer.enqueue(sampleBuffer)
    }
}

extension ViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(#function)
        startButton.isEnabled = false
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(#function)
        stopButton.isEnabled = true
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(#function)
        stopButton.isEnabled = false
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(#function)
        startButton.isEnabled = true
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print(#function, error)
    }
}

extension ViewController: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        print(#function)
        return CMTimeRange(start: .zero, end: .positiveInfinity)
    }
    
    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        print(#function)
        return true
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        print(#function, playing)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
        print(#function, newRenderSize)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        print(#function)
        completionHandler()
    }
}
