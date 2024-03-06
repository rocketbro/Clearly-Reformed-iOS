//
//  Network Monitor.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    @Published var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.schedule {
                self.isConnected = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
