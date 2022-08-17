//
//  PiPRenderer.swift
//  pip-custom
//
//  Created by Naruki Chigira on 2022/08/13.
//

import CoreMedia

protocol PiPRenderer {
    var preferedCanvasSize: CGSize { get }

    func render(on sampleBuffer: CMSampleBuffer)
}
