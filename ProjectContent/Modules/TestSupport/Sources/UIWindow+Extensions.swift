//
//  UIWindow+Extensions.swift
//  TestSupport
//
//  Created by Edson Yudi Toma on 01/02/26.
//

import UIKit

extension UIWindow {
    public func takeSnapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
