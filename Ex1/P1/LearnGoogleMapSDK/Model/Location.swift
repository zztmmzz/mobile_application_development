//
//  Location.swift
//  LearnGoogleMapSDK
//
//  Created by Tran Man on 11/24/17.
//  Copyright © 2017 Tran Man. All rights reserved.
//

import UIKit

struct Location {
   var address: String
   var lat: Double
   var long: Double
   
   init() {
      address = ""
      lat = 0.0
      long = 0.0
   }
}
