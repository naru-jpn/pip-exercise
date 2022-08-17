//
//  SampleVideoPlayerView.swift
//  pip-basic
//
//  Created by Naruki Chigira on 2022/08/13.
//

import AVKit
import UIKit

/// AVPlayerLayer 上で動画をループ再生するためのビュー
class SampleVideoPlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    /// AVPlayerLayer
    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError("Failed to get AVPlayerLayer.")
        }
        return layer
    }
    /// サンプルの動画を表すアイテム
    private lazy var playerItem: AVPlayerItem = {
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "mp4") else {
            fatalError("Failed to get sample video.")
        }
        return AVPlayerItem(url: url)
    }()
    /// ループ再生のためのプレイヤー
    private(set) lazy var player = AVQueuePlayer(playerItem: playerItem)
    /// ループ再生の管理
    private var playerLooper: AVPlayerLooper?

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.player = player
        configureLoopPlayback()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        playerLayer.player = player
        configureLoopPlayback()
    }
    
    /// プレイヤーの生成
    private func configureLoopPlayback() {
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
    }
}
