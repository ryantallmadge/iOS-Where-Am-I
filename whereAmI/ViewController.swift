//
//  ViewController.swift
//  whereAmI
//
//  Created by Ryan Tallmadge on 1/8/16.
//  Copyright © 2016 dotrender. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var latitudeLabel    : UILabel!
    @IBOutlet weak var longitudeLabel   : UILabel!
    @IBOutlet weak var addressLine1Label: UILabel!
    @IBOutlet weak var addressLine2Label: UILabel!
    @IBOutlet weak var addressStackView : UIStackView!
    @IBOutlet weak var loadingLabel     : UILabel!
    @IBOutlet weak var placeTitleLabel  : UILabel!
    @IBOutlet weak var map              : MKMapView!
    @IBOutlet weak var placesLabel      : UILabel!
    
    let locationManager = CLLocationManager();
    let geoCoder        = CLGeocoder();
    let regionRadius : CLLocationDistance = 1000;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self;
        map.mapType = .Hybrid;
        placesLabel.numberOfLines = 0;
        placesLabel.sizeToFit();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        locationAuthStatus();
    }
    
    
    func locationAuthStatus(){
        if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse){
            map.showsUserLocation = true;
        } else {
            locationManager.requestWhenInUseAuthorization();
        }
    }
    
    func centerMapOnLocation(location : CLLocation){
        let coordRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2);
        map.setRegion(coordRegion, animated: true);
    }
    
    func getGooglePlacesData(lat lat : Double, long : Double){
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=500&types=food&key=AIzaSyCjLESThgS3uYi5CdoS10NQQZW-d-d59KA";
        
        let session = NSURLSession.sharedSession();
        let url = NSURL(string: urlString)!;
        self.placesLabel.hidden = false;
        session.dataTaskWithURL(url)
            { (data :NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                if let responseData = data {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments);
                        if let dict = json as? Dictionary<String, AnyObject> {
                            let dataResults = (dict["results"] as! NSArray) as Array;
                            
                            var places = [String]();
                            for result in dataResults {
                                if let name = result["name"] as? String{
                                    places.append(name);
                                }
                            }
                             self.placesLabel.text = "\(places.joinWithSeparator(", "))";
                            
                        }
                    } catch {
                        print("couldnt get google places");
                    }
                }
            }.resume();
        
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location {

            geoCoder.reverseGeocodeLocation(loc, completionHandler: {
                (placemarks,error) in
                let places = placemarks;
                if let placeMarks = places {
                    let place = placeMarks[0] as CLPlacemark;
                    self.latitudeLabel.text = "\(loc.coordinate.latitude)";
                    self.longitudeLabel.text = "\(loc.coordinate.longitude)";
                    self.addressLine1Label.text = "\(place.subThoroughfare!)" + " " + "\(place.thoroughfare!)";
                    self.addressLine2Label.text = "\(place.locality!)" + ", " + "\(place.administrativeArea!)" + " " + "\(place.postalCode!)";
                    self.getGooglePlacesData(lat : loc.coordinate.latitude, long: loc.coordinate.longitude);
                    self.loadingLabel.hidden = true;
                    self.addressStackView.hidden = false;
                }
            });
            centerMapOnLocation(loc);
        }
    }

}

