//
//  pip_performanceApp.swift
//  pip-performance
//
//  Created by Naruki Chigira on 2022/08/14.
//

import SwiftUI

@main
struct AppMain: App {
    @StateObject var measurer = Measurer()
    
    var body: some Scene {
        WindowGroup {
            ContentView(measurer: measurer)
                .onAppear() {
                    Task() {
                        await withTaskGroup(of: Void.self) { group in
                            let tasks: [@Sendable () async -> Void] = [
                                { await measurer.measureContextCreateAverageTime() },
                                { await measurer.measurePixelBufferCreateAverageTime() },
                                { await measurer.measurePixelBufferCreateFromPoolAverageTime() },
                                { await measurer.measureCreateUIImageFromSingleView() },
                                { await measurer.measureCreateUIImageFromMultipleView() },
                                { await measurer.measureCreateUIImageFromSingleImageView() },
                                { await measurer.measureCreateUIImageFromMultipleImageView() }
                            ]
                            for task in tasks {
                                group.addTask(operation: task)
                                await group.waitForAll()
                            }
                        }
                    }
                }
        }
    }
}
