# Resource
Resource is a library for building API's with [Frank](https://github.com/NestProject/Frank), and other [Nest Project](https://github.com/NestProject) web frameworks.

## Example

```swift
struct Repository: Resource {
    let name = "Resource"
    let description = "Library for building REST API's with Frank"
}
```

if requested as JSON would return:

```json
{
    "name": "Resource",
    "description": "Library for building REST API's with Frank"
}
```

Resource will also embed any resources returned in the `relations()` dictionary.

For example:
```swift
public struct User: Resource {
	let prettyName = "Danielle Lancashire"
	let username = "endocrimes"
	let favouriteRepository = Repository()

	public func attributes() -> [String : Any] {
		return ["pretty_name": prettyName, "username": username]
	}

	public func relations() -> [String : [Resource]] {
		return ["favourite_repository": [favouriteRepository]]
	}
}
```

if requested as JSON would return:

```json
{
	"pretty_name": "Danielle Lancashire",
	"username": "endocrimes",
	"embed": {
		"favourite_repository": {
			"name": "Resource",
			"description": "Library for building REST API's with Frank"
		}
	}
}
```

## Content Types

### Default

Resource comes with support for:
- JSON (application/json)

### Custom

You can provide custom content types by overriding the `encoders` function on a resource.

## Coming Soon
- [] Better support for content negotiation

