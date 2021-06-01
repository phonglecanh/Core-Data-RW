//
//  CampSiteServiceTests.swift
//  CampgroundManagerTests
//
//  Created by Lê Cảnh Phong on 01/06/2021.
//  Copyright © 2021 Razeware. All rights reserved.
//

import XCTest
import UIKit
import CampgroundManager
import CoreData

class CampSiteServiceTests: XCTestCase {

  // MARK: Properties
    var campSiteService: CampSiteService!
    var coreDataStack: CoreDataStack!
    override func setUp() {
      super.setUp()
      coreDataStack = TestCoreDataStack()
      campSiteService = CampSiteService(
        managedObjectContext: coreDataStack.mainContext,
        coreDataStack: coreDataStack)
    }
    override func tearDown() {
      super.tearDown()
      campSiteService = nil
      coreDataStack = nil
    }
  
  func testAddCampsite() {
    let campsite = campSiteService.addCampSite(1, electricity: true, water: true)
    XCTAssertTrue(campsite.siteNumber == 1, "Site number should be 1")
    XCTAssertTrue(campsite.electricity!.boolValue,
        "Site should have electricity")
      XCTAssertTrue(campsite.water!.boolValue,
        "Site should have water")
  }
  
  func testRootContextIsSavedAfterAddingCampsite() {
    let derivedContext = coreDataStack.newDerivedContext()
    campSiteService = CampSiteService(
      managedObjectContext: derivedContext,
      coreDataStack: coreDataStack)
    expectation(
      forNotification: .NSManagedObjectContextDidSave,
      object: coreDataStack.mainContext) {
        notification in
  return true
  }
    derivedContext.perform {
      let campSite = self.campSiteService.addCampSite(1,
        electricity: true,
        water: true)
      XCTAssertNotNil(campSite)
  }
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save did not occur")
    }
  }
  
  func testGetCampSiteWithMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1,
      electricity: true,
      water: true)
    let campSite = campSiteService.getCampSite(1)
    XCTAssertNotNil(campSite, "A campsite should be returned")
   }
  
   func testGetCampSiteNoMatchingSiteNumber() {
     _ = campSiteService.addCampSite(1,
       electricity: true,
       water: true)
     let campSite = campSiteService.getCampSite(2)
     XCTAssertNil(campSite, "No campsite should be returned")
   }
        
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
