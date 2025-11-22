//
//  Favorite+CoreDataProperties.swift
//  MovieDB-CSS214
//
//  Created by Sapuan Talaspay on 11/22/25.
//
//


import Foundation
import CoreData

extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var movieID: Int64
    @NSManaged public var posterPath: String?
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: Double
}

extension Favorite: Identifiable {

}
