//
//  FinishedRunViewController.swift
//  RunTogether1.5
//
//  Created by Ian Hall on 9/12/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FinishedRunViewController: UIViewController {
    
    
    //MARK: - OUTLETS
    
    
    @IBOutlet weak var mappedRunView: MKMapView!
    
    var listOfLocations:[CLLocation]?
    
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMap()
    
    }
    
    
    
    
    //MARK: - Helper Functions
    func loadMap(){
        guard let locations = listOfLocations, locations.count > 0, let region = mapRegion() else{
            //TODO: - add some more error control and alert user
            return
        }
        mappedRunView.setRegion(region, animated: true)
        mappedRunView.addOverlay(polyLine())
    }
    
    func mapRegion() -> MKCoordinateRegion? {
        //unwarp my list
        guard let locations =  listOfLocations else {
            return nil
        }
        //make sure i wasnt handed an empty list
        if locations.count > 0 {
            //grab all latitudes
            let latitudes = locations.map{ location -> Double in
                return location.coordinate.latitude
            }
            //grab all longitudes
            let longitudes = locations.map { location -> Double in
                return location.coordinate.longitude
            }
            //grab the mins and maxes of all
            let maxLat = latitudes.max()!
            let minLat = latitudes.max()!
            let maxLong = longitudes.max()!
            let minLong = longitudes.min()!
            
            //create a center which i can do with my previously found mins and maxes
            
            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
            //region also requires a span
            let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3 )
            //bam i should be able to make a region
            
            let region = MKCoordinateRegion(center: center, span: span)
            
            return region
        }
        return nil
    }
   
    
    func polyLine() -> MKPolyline {
        //unwrap my locations
        guard let locations = listOfLocations else{
            return MKPolyline()
        }
        //make an array of coordinates that mkpolyline can use
        let coords: [CLLocationCoordinate2D] = locations.map { (location) in
            return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension FinishedRunViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .orange
        renderer.lineWidth = 3
        return renderer
    }
    
}
