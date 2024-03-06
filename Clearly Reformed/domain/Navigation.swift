//
//  Navigation.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import Foundation

enum NavLocation {
    case splash, webpage
}

class Navigation: ObservableObject {
    @Published var route: NavLocation = .splash
}
