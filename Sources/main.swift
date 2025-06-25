// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Vapor

import OpenAPIRuntime
import OpenAPIVapor


// Define a type that conforms to the generated protocol.
struct MyRecallAppServiceAPIImpl: APIProtocol {
  func getGreeting(_ input: Operations.GetGreeting.Input) async throws -> Operations.GetGreeting.Output {
    let inarg = input.query.name ?? "Hello:Robert"
    let greet = inarg.split(separator: ":")[0]
    let name = inarg.split(separator: ":")[1]
    print(greet + ", " + name)

    let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0] as NSURL
    
    // add a filename
    let fileUrl = documentsUrl.appendingPathComponent("MyRecallApp/" + name + ".txt")
    
    // write to it
    try! greet.write(to: fileUrl!, atomically: true, encoding: String.Encoding.utf8)
    let greeting = Components.Schemas.Greeting(message: "\(greet), \(name)!")
    return .ok(.init(body: .json(greeting)))
  }
  
  func getEmoji(_ input: Operations.GetEmoji.Input) async throws -> Operations.GetEmoji.Output {
    let emojis = "👋👍👏🙏🤙🤘"
    let emoji = String(emojis.randomElement()!)
    print(emoji)
    return .ok(.init(body: .plainText(.init(emoji))))
  }
}

// Create your Vapor application.
let app = try await Vapor.Application.make()
//print(app.http.server.configuration.hostname)
app.http.server.configuration.hostname = "0.0.0.0"

// Create a VaporTransport using your application.
let transport = VaporTransport(routesBuilder: app)


// Create an instance of your handler type that conforms the generated protocol
// defining your service API.
let handler = MyRecallAppServiceAPIImpl()


// Call the generated function on your implementation to add its request
// handlers to the app.
try print(Servers.Server1.url())
try handler.registerHandlers(on: transport, serverURL: Servers.Server1.url())


// Start the app as you would normally.
try await app.execute()
