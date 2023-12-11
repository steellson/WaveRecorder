//
//  URLBuilder.swift
//  WaveRecorder
//
//  Created by Andrew Steellson on 11.12.2023.
//

import Foundation

final class URLBuilder {
    
    static func buildURL(
        forRecordWithName name: String,
        andFormat format: String
    ) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
            .appendingPathExtension(format)
    }
}
