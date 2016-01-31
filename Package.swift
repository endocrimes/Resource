import PackageDescription

let package = Package(
					  name: "Resource",
					  dependencies: [
						  .Package(url: "https://github.com/nestproject/Nest.git", majorVersion: 0),
						  .Package(url: "https://github.com/nestproject/Frank.git", majorVersion: 0),
						  .Package(url: "https://github.com/nestproject/Inquiline.git", majorVersion: 0),
						  .Package(url: "https://github.com/endocrimes/JSON.git", majorVersion: 0)
					  ],
					  testDependencies: [
						  .Package(url: "https://github.com/kylef/spectre-build", majorVersion: 0)
					  ])
