//
//  Squad.swift
//  SwapTheCell
//
//  Created by Владимир Олейников on 15/4/2022.
//

import Foundation

struct Squad {
    var team: [Person]
    static var shared =  Squad(team: [])
}
