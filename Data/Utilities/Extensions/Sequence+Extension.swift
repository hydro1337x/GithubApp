//
//  Sequence+Extension.swift
//  Data
//
//  Created by Benjamin Mecanović on 30.07.2022..
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func uniqued() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
