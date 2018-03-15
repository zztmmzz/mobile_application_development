//
//  ViewController.swift
//  LearnGoogleMapSDK
//
//  Created by Tran Man on 11/23/17.
//  Copyright © 2017 Tran Man. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    let locationManager = CLLocationManager()
    var mapView: GMSMapView!
    var currentLocation: CLLocation?
    var destinations: [Location] = []
    
    lazy var latTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .done
        tf.enablesReturnKeyAutomatically = true
        tf.clearButtonMode = .whileEditing
        tf.delegate = self
        return tf
    }()
    
    lazy var lngTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .done
        tf.enablesReturnKeyAutomatically = true
        tf.clearButtonMode = .whileEditing
        tf.delegate = self
        return tf
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleDoneButton), for: .touchUpInside)
        button.setTitle("Search", for: .normal)
        return button
    }()
    
    @objc private func handleDoneButton(_ sender: UIButton) {
        print("Finding")
    }
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .done
        tf.enablesReturnKeyAutomatically = true
        tf.clearButtonMode = .whileEditing
        tf.delegate = self
        return tf
    }()
    
    lazy var myLocationImageView: UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "mylocationIcon"))
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMyLocationImg))
        imgView.addGestureRecognizer(tap)
        return imgView
    }()
    
    lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    @objc private func handleMyLocationImg() {
        let camera = GMSCameraPosition.camera(withTarget: (currentLocation?.coordinate)!, zoom: 20.0)
        mapView.animate(to: camera)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        let auths = CLLocationManager.authorizationStatus()
        if auths == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        drawMarker()
        addTextField()
        addMyLocationImg()
        addTableView()
        tableView.isHidden = true
    }
    
    private func addMyLocationImg() {
        view.addSubview(myLocationImageView)
        
        NSLayoutConstraint.activate([
            myLocationImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            myLocationImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ])
    }
    
    private func addTextField() {
        view.addSubview(inputTextField)
        
        NSLayoutConstraint.activate([
            inputTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0),
            inputTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20.0),
            inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20.0),
            inputTextField.heightAnchor.constraint(equalToConstant: 48.0)
            ])
        
        view.addSubview(latTextField)
        NSLayoutConstraint.activate([
                latTextField.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 10),
                latTextField.leftAnchor.constraint(equalTo: inputTextField.leftAnchor, constant: 0),
                latTextField.rightAnchor.constraint(equalTo: inputTextField.rightAnchor),
                latTextField.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        view.addSubview(lngTextField)
        NSLayoutConstraint.activate([
                lngTextField.topAnchor.constraint(equalTo: latTextField.bottomAnchor, constant: 10),
                lngTextField.leftAnchor.constraint(equalTo: inputTextField.leftAnchor, constant: 0),
                lngTextField.rightAnchor.constraint(equalTo: inputTextField.rightAnchor),
                lngTextField.heightAnchor.constraint(equalToConstant: 30)
            ])

    }
    
    private func addMap(lat: Double, long: Double) {
        let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let camera = GMSCameraPosition.camera(withTarget: position, zoom: 20.0)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.frame = view.frame
        mapView.mapType = .normal
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.insertSubview(mapView, at: 0)
    }
    
    private func drawMarker() {
        let marker = UIImageView(image: #imageLiteral(resourceName: "markerIcon"))
        marker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(marker)
        
        NSLayoutConstraint.activate([
            marker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            marker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 4.0),
            tableView.leftAnchor.constraint(equalTo: inputTextField.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: inputTextField.rightAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 300.0)
            ])
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        inputTextField.resignFirstResponder()
        tableView.isHidden = true
    }
    
    var isFinder = false
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if isFinder {
            isFinder = false
            return
        }
        let lat = position.target.latitude
        let long = position.target.longitude
        
        latTextField.text = "\(lat)"
        lngTextField.text = "\(long)"
        
        let requestURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=AIzaSyBtHlexFJCYspmiuPTccLNNGCZi3Oh1OAw"
        
        Alamofire.request(requestURL).responseJSON { (response) in
            let dict = response.value as! NSDictionary
            
            guard (dict["status"] as! String) == "OK" else {
                return
            }
            
            if let results = dict["results"] as? [NSDictionary] {
                let result = results.first!
                
                if let address = result["formatted_address"] {
                    DispatchQueue.main.async {
                        self.inputTextField.text = address as? String
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            latTextField.text = "\(location.coordinate.latitude)"
            lngTextField.text = "\(location.coordinate.longitude)"
            addMap(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        destinations.removeAll()
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == inputTextField {
            tableView.isHidden = false
            textField.resignFirstResponder()
            let address = textField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let requestURL = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=AIzaSyBtHlexFJCYspmiuPTccLNNGCZi3Oh1OAw"
            
            Alamofire.request(requestURL).responseJSON { (response) in
                guard let dict = response.value as? NSDictionary else {
                    return
                }
                
                guard (dict["status"] as! String) == "OK" else {
                    return
                }
                
                guard let results = dict["results"] as? [NSDictionary]  else {
                    return
                }
                
                for result in results {
                    
                    guard let address = result["formatted_address"] as? String else {
                        return
                    }
                    
                    if let geometry = result["geometry"] as? NSDictionary {
                        if let geo = geometry["location"] as? NSDictionary {
                            let lat = (geo["lat"] as! Double)
                            let long = (geo["lng"] as! Double)
                            DispatchQueue.main.async {
                                let marker = GMSMarker(position: CLLocation(latitude: lat, longitude: long).coordinate)
                                marker.map = self.mapView
                            }
                            
                            DispatchQueue.main.async {
                                var location = Location()
                                location.lat = lat
                                location.long = long
                                location.address = address
                                self.destinations.append(location)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath.init(item: self.destinations.count - 1, section: 0)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        }
                    }
                    
                }
                
                if let result = results.first {
                    if let address = result["geometry"] as? NSDictionary {
                        if let location = address["location"] as? NSDictionary {
                            let lat = (location["lat"] as! Double)
                            let long = (location["lng"] as! Double)
                            DispatchQueue.main.async {
                                let marker = GMSMarker(position: CLLocation(latitude: lat, longitude: long).coordinate)
                                marker.map = self.mapView
                            }
                        }
                    }
                }
            }
            return true
        } else {
            var lat = "0.0"
            var lng = "0.0"
            if let latSetter = latTextField.text {
                lat = latSetter
            }
            if let lngSetter = lngTextField.text {
                lng = lngSetter
            }
            
            let requestURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=AIzaSyBtHlexFJCYspmiuPTccLNNGCZi3Oh1OAw"
            
            Alamofire.request(requestURL).responseJSON { (response) in
                let dict = response.value as! NSDictionary
                
                guard (dict["status"] as! String) == "OK" else {
                    return
                }
                
                if let results = dict["results"] as? [NSDictionary] {
                    let result = results.first!
                    
                    if let address = result["formatted_address"] {
                        DispatchQueue.main.async {
                            self.inputTextField.text = address as? String
                        }
                    }
                }
            }
            
            let camera = GMSCameraPosition.camera(withLatitude: Double(lat)!, longitude: Double(lng)!, zoom: 20.0)
            mapView.animate(to: camera)
        }
        
        return true
    }
}


extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        cell.textLabel?.text = destinations[indexPath.item].address
        return cell
    }
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true
        isFinder = true
        let location = destinations[indexPath.item]
        latTextField.text = location.lat.description
        lngTextField.text = location.long.description
        let camera = GMSCameraPosition.camera(withLatitude: location.lat, longitude: location.long, zoom: 20.0)
        mapView.animate(to: camera)
        inputTextField.text = location.address
        mapView.clear()
        destinations.removeAll()
        tableView.reloadData()
    }
}
