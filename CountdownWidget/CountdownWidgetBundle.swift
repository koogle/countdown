//
//  CountdownWidgetBundle.swift
//  CountdownWidget
//
//  Created by Jakob Frick on 24/11/2024.
//

import WidgetKit
import SwiftUI
import CountdownShared

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
        CountdownWidgetLiveActivity()
    }
}
