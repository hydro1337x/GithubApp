//
//  DateMapper.swift
//  Presentation
//
//  Created by Benjamin Mecanović on 06.08.2022..
//

import Foundation

public final class DateMapper: Mapper {
    private let dateFormatter: DateFormatter
    private let inputFormat: String
    private let outputFormat: String

    public init(
        dateFormatter: DateFormatter,
        inputFormat: String,
        outputFormat: String
    ) {
        self.dateFormatter = dateFormatter
        self.inputFormat = inputFormat
        self.outputFormat = outputFormat
    }

    public func map(input: String) -> String {
        dateFormatter.dateFormat = inputFormat
        let date = dateFormatter.date(from: input)
        dateFormatter.dateFormat = outputFormat

        guard let date = date else { return "N/A" }

        let dateString = dateFormatter.string(from: date)

        return dateString
    }
}
