//
//  Recording.swift
//  SpeechRecognition
//
//  Created by Grant Maloney on 1/31/19.
//  Copyright © 2019 Grant Maloney. All rights reserved.
//

import Foundation

struct Recording {
    let title: String
    let subtitle: String
    let audio: URL
    let locale: Locale?
    
    init(title: String, subtitle: String, filename: String, locale: Locale?) {
        self.title = title
        self.subtitle = subtitle
        self.audio = Bundle.main.url(forResource: filename, withExtension: .none)!
        self.locale = locale
    }
}
