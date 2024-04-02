//
//  Navigation.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import SwiftUI

enum NavLocation {
    case splash, webpage
}

@Observable class Navigation {
    var route: NavLocation = .splash
}
