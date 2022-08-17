//
//  ViewController.swift
//  pip-custom
//
//  Created by Naruki Chigira on 2022/08/13.
//

import AVKit
import CoreMedia
import UIKit

/// FPS
private let frequencyPerSecond: Int = 30

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
    /// ループ管理
    private lazy var looper: Looper = {
        let looper = Looper(frequencyPerSecond: frequencyPerSecond)
        looper.delegate = self
        return looper
    }()
    /// CMSampleBuffer のキャッシュ管理
    private lazy var sampleBufferFactory = CMSampleBufferFactory()
    /// レンダラ
    private var renderer: PiPRenderer = FillRenderer(gradationInterval: frequencyPerSecond * 5)
    private var presentationTimeStamp: CMTime = .zero
    
    private lazy var pictureInPictureController: AVPictureInPictureController = {
        let contentSource = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: sampleBufferDisplayLayer, playbackDelegate: self)
        let controller = AVPictureInPictureController(contentSource: contentSource)
        controller.requiresLinearPlayback = false
        controller.canStartPictureInPictureAutomaticallyFromInline = false
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        looper.run()
    }
    
    private func layoutSampleBufferDisplayLayer() {
        sampleBufferDisplayLayer.frame = .init(origin: .zero, size: layerContainerView.frame.size)
    }
    
    /// CMSampleBuffer の生成と描画
    private func render() {
        if sampleBufferDisplayLayer.status == .failed {
            pictureInPictureController.invalidatePlaybackState()
            sampleBufferDisplayLayer.flush()
        }
        
        presentationTimeStamp = CMTimeAdd(presentationTimeStamp, CMTime(value: 1, timescale: CMTimeScale(frequencyPerSecond)))
        let canvasSize = renderer.preferedCanvasSize
        guard let sampleBuffer = sampleBufferFactory.make(
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            presentationTimeStamp: presentationTimeStamp,
            refreshRate: frequencyPerSecond
        ) else {
            return
        }
        
        renderer.render(on: sampleBuffer)
        sampleBufferDisplayLayer.enqueue(sampleBuffer)
    }
    
    @IBAction private func didSelectAspectRatio(_ sender: UISegmentedControl) {
        guard let fillRenderer = renderer as? FillRenderer, let aspectRatio = FillRenderer.AspectRatio(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        // アスペクト比の変更
        fillRenderer.aspectRatio = aspectRatio
    }
    
    @IBAction private func didTapStartButton(_ sender: UIButton) {
        pictureInPictureController.startPictureInPicture()
    }
    
    @IBAction private func didTapStopButton(_ sender: UIButton) {
        pictureInPictureController.stopPictureInPicture()
    }
}

extension ViewController: LooperDelegate {
    func loop(_ looper: Looper) {
        render()
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
