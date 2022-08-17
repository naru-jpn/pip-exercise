//
//  MeasureResultView.swift
//  pip-performance
//
//  Created by Naruki Chigira on 2022/08/14.
//

import SwiftUI

/// 計測結果の表示用ビュー
struct MeasureResultView: View {
    let title: String
    var time: String
    
    var body: some View {
        VStack {
            Text(title)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 2)
            Text(time)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .clipped()
        .shadow(color: .black.opacity(0.2), radius: 2)
    }
}

struct MeasureResultView_Previews: PreviewProvider {
    static var previews: some View {
        MeasureResultView(title: "Title", time: "...")
    }
}
