//
//  ContentView.swift
//  pip-performance
//
//  Created by Naruki Chigira on 2022/08/14.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var measurer: Measurer
    
    var body: some View {
        let contextCreateAverageTime = measurer.contextCreateAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."
        let pixelBufferCreateAverageTime = measurer.pixelBufferCreateAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."
        let pixelBufferCreateFromPoolAverageTimeMS = measurer.pixelBufferCreateFromPoolAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."
        let singleViewImageCreateAverageTimeMS = measurer.singleViewImageCreateAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."
        let multipleViewImageCreateAverageTimeMS = measurer.multipleViewImageCreateAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."
        let singleImageViewImageCreateAverageTimeMS = measurer.singleImageViewImageCreateAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."
        let mulitpleImageViewImageCreateAverageTimeMS = measurer.multipleImageViewImageCreateAverageTimeMS
            .map { String(format: "%6.4f", $0) + "[ms]" } ?? "measuring..."

        ScrollView(.vertical) {
            VStack {
                VStack(spacing: 16) {
                    Text("Average Times of \(measurer.numberOfTrials) Trials")
                        .bold()
                        .padding(.init(top: 0, leading: 0, bottom: 2, trailing: 0))
                    MeasureResultView(title: "Create CIContext", time: contextCreateAverageTime)
                    MeasureResultView(title: "Create CVPixelBuffer", time: pixelBufferCreateAverageTime)
                    MeasureResultView(title: "Create CVPixelBuffer from Pool", time: pixelBufferCreateFromPoolAverageTimeMS)
                    MeasureResultView(title: "Create Single View Image", time: singleViewImageCreateAverageTimeMS)
                    MeasureResultView(title: "Create Multiple View Image", time: multipleViewImageCreateAverageTimeMS)
                    MeasureResultView(title: "Create Single ImageView Image", time: singleImageViewImageCreateAverageTimeMS)
                    MeasureResultView(title: "Create Multiple ImageView Image", time: mulitpleImageViewImageCreateAverageTimeMS)
                }
                .padding()
                .frame(maxWidth: 320)
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(measurer: Measurer())
    }
}
