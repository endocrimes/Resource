import Frank
import Nest
import Inquiline
import JSON

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public typealias ContentType = String

public struct Encoder<OutputType> {
	let encode: Resource -> OutputType

	init(encode: Resource -> OutputType) {
		self.encode = encode
	}
}

public extension Encoder {
	static func JSONEncoder() -> Encoder<String> {
		return Encoder<String>() { resource in
			let json = resource.JSONValue
			return json.serialize(DefaultJSONSerializer())
		}
	}
}

public protocol Resource {
	func attributes() -> [String : Any]
	func relations() -> [String : [Resource]]
	func encoders() -> [ContentType : Encoder<String>]
	func get(request: RequestType) throws -> ResponseConvertible
}

extension Resource {
	public var dictionaryValue: [String : Any] {
		var attributes = self.attributes()
		let relations = self.relations()
		
		guard !relations.keys.isEmpty else { return attributes }

		var embed = [String : Any]()
		for (key, value) in relations {
			let objects = value.map { $0.dictionaryValue }
			if objects.count == 1 {
				embed[key] = objects.first!
			}
			else {
				embed[key] = objects
			}
		}
		attributes["embed"] = embed

		return attributes
	}

	var JSONValue: JSON {
		return dictionaryValue.JSONValue
	}
}

public enum ResourceErrors: ErrorType {
	case ContentTypeUnavailable(String)
}

public extension Resource {
	func attributes() -> [String : Any] {
		let mirror = Mirror(reflecting: self)
		var returnValue = [String : Any]()
		for child in mirror.children where child.0 != nil {
			let key = child.0!
			let value = child.1
			returnValue[key] = value
		}

		return returnValue
	}

	func relations() -> [String : [Resource]] {
		return [String : [Resource]]()
	}

	func encoders() -> [ContentType : Encoder<String>] {
		let JSONEncoder = Encoder<String>.JSONEncoder()
		return ["application/json" : JSONEncoder]
	}

	private func encoderForContentType(contentType: ContentType?) throws -> (ContentType, Encoder<String>) {
		let encoders = self.encoders()
		if let contentType = contentType {
			guard let encoder = encoders[contentType] else { throw ResourceErrors.ContentTypeUnavailable(contentType) }
			return (contentType, encoder)
		}
		else {
			let contentType = encoders.keys.first!
			return (contentType, encoders[contentType]!)
		}
	}

	func get(request: RequestType) throws -> ResponseConvertible {
		let encoding = try encoderForContentType(request.contentType)
		let body = encoding.1.encode(self)
		return Response(.Ok, contentType: encoding.0, body: body)
	}
}

