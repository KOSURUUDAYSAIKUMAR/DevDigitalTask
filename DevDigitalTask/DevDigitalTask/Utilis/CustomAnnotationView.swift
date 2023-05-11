//
//  CustomAnnotationView.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
           super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
           canShowCallout = true
           update(for: annotation)
       }

       override var annotation: MKAnnotation? { didSet { update(for: annotation) } }

       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

       private func update(for annotation: MKAnnotation?) {
           image = (annotation as? CustomAnnotation)?.pinCustomImage
       }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
