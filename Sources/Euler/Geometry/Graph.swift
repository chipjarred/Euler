//
//  Graph.swift
//  
//
//  Created by Arthur Guiot on 2020-03-04.
//

import Foundation
import SwiftPlot
import AGGRenderer

/// Object that lets you plot graphs natively.
///
/// `Graph` is heavily based on SwiftPlot (cross platform).
///
public class Graph {
    
    /// A sub structure to the `Graph` to represent a set of point
    public struct PointSet {
        /// The set of point that will be used to draw the graph
        public var set: [Point]
        /// The name of the set (will be shown as a label)
        public var name: String
        /// Creates a new `PointSet` object.
        public init(points: [Point], name: String) {
            self.set = points
            self.name = name
        }
        /// Render the set of points defined with a simple scatter plot
        /// - Parameter callback: A callback that will take a `ScatterPlot` and change it for customisation.
        public func render(_ callback: (ScatterPlot<Double, Double>) -> Void) -> Data {
            let renderer = AGGRenderer()
            var plot = ScatterPlot<Double, Double>(enableGrid: true)
            let x = set.map { $0.x.asDouble() ?? Double.infinity }
            let y = set.map { $0.y.asDouble() ?? Double.infinity }
            plot.addSeries(x, y, label: self.name, color: .red)
            callback(plot)
            plot.drawGraph(renderer: renderer)
            let b64 = renderer.base64Png()
            guard let dataDecoded = Data(base64Encoded: b64, options: .ignoreUnknownCharacters) else { fatalError("[Graph] Encoding error") }
            return dataDecoded
        }
    }
}
