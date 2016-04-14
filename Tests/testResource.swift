#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import Spectre
import Frank
@testable import Resource

// Need @testable inquiline to test responses.
@testable import Inquiline

import Foundation

public struct Location: Resource {
	let name: String
}

public struct Person: Resource {
	public let name: String
	internal let birthMonth: Int
	private let likesSwift: Bool

	public func relations() -> [String : [Resource]] {
		return [
			"location": [Location(name: "London")],
			"past_locations": [Location(name: "Derby"), Location(name: "Bournemouth"), Location(name: "Macclesfield")]
		]
	}
}

func testResource() {
	describe("Resource") {

		let sut = Person(name: "Daniel", birthMonth: 11, likesSwift: true)

		$0.it("should have the correct attributes") {
			let attributes = sut.attributes()

			try expect(attributes.count) == 3

			try expect(attributes["name"] as? String) == sut.name
			try expect(attributes["birthMonth"] as? Int) == sut.birthMonth
			try expect(attributes["likesSwift"] as? Bool) == sut.likesSwift
		}

		$0.it("should return JSON for a get with application/json") {
			let expectedPayload = "{\"likesSwift\":true,\"embed\":{\"location\":{\"name\":\"London\"},\"past_locations\":[{\"name\":\"Derby\"},{\"name\":\"Bournemouth\"},{\"name\":\"Macclesfield\"}]},\"birthMonth\":11,\"name\":\"Daniel\"}"
	
			let request = Request(method: "GET", path: "/person/1", headers: [("Accept", "application/json")])
			let response = try? sut.get(request).asResponse() as! Response
			let body = response?.body as! BytesPayload
			let bodyString = String(bytes: body.bytes!, encoding: NSUTF8StringEncoding)!

			try expect(bodyString) == expectedPayload
			try expect(response?.contentType) == "application/json"
		}
	}
}

