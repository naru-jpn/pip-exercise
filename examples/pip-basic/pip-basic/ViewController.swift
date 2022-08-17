//
//  ViewController.swift
//  pip-basic
//
//  Created by Naruki Chigira on 2022/08/13.
//

import AVKit
import UIKit

class ViewController: UIViewController {
    /// サンプル動画再生用ビュー
    @IBOutlet private var sampleVideoPlayerView: SampleVideoPlayerView!
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
    
    private lazy var pictureInPictureController: AVPictureInPictureController = {
        guard let controller = AVPictureInPictureController(playerLayer: sampleVideoPlayerView.playerLayer) else {
            fatalError("Failed to get AVPictureInPictureController.")
        }
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // あらかじめ pictureInPictureController の生成をしておかないと初回の startPictureInPicture() に失敗する
        pictureInPictureController.delegate = self
        pictureInPictureController.requiresLinearPlayback = false
        pictureInPictureController.canStartPictureInPictureAutomaticallyFromInline = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sampleVideoPlayerView.player.play()
    }
    
    @IBAction private func didTapStartButton(_ sender: UIButton) {
        pictureInPictureController.startPictureInPicture()
    }
    
    @IBAction private func didTapStopButton(_ sender: UIButton) {
        pictureInPictureController.stopPictureInPicture()
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
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print(#function)
        completionHandler(true)
    }
}
