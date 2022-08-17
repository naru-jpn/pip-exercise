//
//  Looper.swift
//  pip-custom
//
//  Created by Naruki Chigira on 2022/08/13.
//

import Foundation

protocol LooperDelegate: AnyObject {
    func loop(_ looper: Looper)
}

/// ループ処理の制御
final class Looper {
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private(set) var isRunning = false {
        didSet {
            guard oldValue != isRunning else {
                return
            }
            if isRunning {
                timer = Timer.scheduledTimer(timeInterval: 1.0 / TimeInterval(frequencyPerSecond), target: self, selector: #selector(handleLoop), userInfo: nil, repeats: true)
                timer?.tolerance = 1.0 / TimeInterval(frequencyPerSecond) * 0.1
            } else {
                timer = nil
            }
        }
    }

    weak var delegate: LooperDelegate?

    private let frequencyPerSecond: Int

    init(frequencyPerSecond: Int) {
        self.frequencyPerSecond = frequencyPerSecond
    }

    /// 開始
    func run() {
        guard !isRunning else {
            print("Looper is already running.")
            return
        }
        isRunning = true
    }

    /// 停止
    func stop() {
        isRunning = false
    }

    @objc
    private func handleLoop() {
        delegate?.loop(self)
    }
}
