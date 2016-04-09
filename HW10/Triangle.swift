//
//  Triangle.swift
//  HW10
//
//  Created by Wind on 3/31/16.
//  Copyright © 2016 Ryan Milvenan. All rights reserved.
//

import Foundation
import simd

struct Vertex {
    var position:vector_float4
    var color:vector_float4
}

let vertex_data:[Vertex] = [
    Vertex(position:[-1.0, -1.0, 0.0, 1.0], color:[22.0/255.0, 33.0/255.0, 44.0/255.0, 1.0]),
    Vertex(position:[0.0, 1.0, 0.0, 1.0], color:[122.0/255.0, 133.0/255.0, 144.0/255.0, 1.0]),
    Vertex(position:[1.0, -1.0, 0.0, 1.0], color:[0.0, 180.0/255.0, 90.0/255.0, 1.0])
]

var stale_vertex_data = vertex_data