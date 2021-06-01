//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by Lê Cảnh Phong on 01/06/2021.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {
  @NSManaged var dateCreated: Date
  @NSManaged var image: UIImage?
  @NSManaged var note: Note?
}
