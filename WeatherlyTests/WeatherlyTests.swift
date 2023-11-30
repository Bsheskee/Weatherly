//
//  WeatherlyTests.swift
//  WeatherlyTests
//
//  Created by bartek on 26/11/2023.
//

import XCTest
@testable import Weatherly

final class WeatherlyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFilterNonEnglishCharacters_WithNonEnglishCharacters_ShouldFilterOut() {
        let viewModel = WeatherViewModel(httpClient: HTTPClient())
        let input = "Montréal, Città della Pieve, Gdańsk"
        
        let result = viewModel.filterNonEnglishCharacters(from: input)
        
        XCTAssertEqual(result, "MontrealCittadellaPieveGdansk", "Expected non-English characters to be filtered out")
    }

}
