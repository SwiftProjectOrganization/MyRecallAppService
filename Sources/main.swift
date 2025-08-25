// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Vapor

import OpenAPIRuntime
import OpenAPIVapor


// Define a type that conforms to the generated protocol.
struct MyRecallAppServiceAPIImpl: APIProtocol {
  func putJson(_ input: Operations.PutJson.Input) async throws -> Operations.PutJson.Output {
    let user = input.query.user ?? "Rob"
    let topic = input.query.topic ?? "BioChemistry"
    let content = input.query.content ?? "No content!"
    //print((user, topic, content.count))
    
    let fileManager = FileManager.default
    let documentsUrl = fileManager.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0] as NSURL
    
    let dirUrl = documentsUrl.appendingPathComponent("MyRecallApp/Data" + "/" + user)
    var isDir: ObjCBool = false
    if !fileManager.fileExists(atPath: dirUrl!.path , isDirectory: &isDir) {
      print("Given directory \(String(describing: dirUrl!)) does not exist.")
      do {
        try fileManager.createDirectory(at: dirUrl!,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        print("Created directory \(dirUrl!)")
      } catch {
        print("Could not create directory \(dirUrl!)")
        print(error.localizedDescription)
      }
    }
    
    isDir = false
    if fileManager.fileExists(atPath: dirUrl!.path , isDirectory: &isDir) {
      let topicUrl = dirUrl?.appendingPathComponent(topic + ".json")
      do {
        try content.write(to: topicUrl! as URL,
                          atomically: true,
                          encoding: String.Encoding.utf8)
        let retcode = Components.Schemas.Json(message: "Wrote `\(topic)` for user `\(user)`!")
        return .ok(.init(body: .json(retcode)))
      } catch {
        print(error.localizedDescription)
        print("Could not write \(String(describing: topicUrl!)).")
        let retcode = Components.Schemas.Json(message: "Topic `\(topic)` for user `\(user)` could not be written!")
        return .ok(.init(body: .json(retcode)))
      }
    } else {
      print("Given DIRECTORY \(String(describing: dirUrl!)) does not exist, nothing stored.")
      let retcode = Components.Schemas.Json(message: "Topic `\(topic)` for user `\(user)` not stored!")
      return .ok(.init(body: .json(retcode)))
    }
  }
  
  func listTopics(_ input: Operations.ListTopics.Input) async throws -> Operations.ListTopics.Output {
    let user = input.query.user ?? "Rob"
    
    let fileManager = FileManager.default
    let documentsUrl = fileManager.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0] as NSURL
    
    let dirUrl = documentsUrl.appendingPathComponent("MyRecallApp/Data" + "/" + user)
    var isDir: ObjCBool = false
    if fileManager.fileExists(atPath: dirUrl!.path , isDirectory: &isDir) {
      do {
        let items = try fileManager.contentsOfDirectory(atPath: dirUrl!.path)
        print(items)
        let retcode = Components.Schemas.Json(message: "Reading topics for user `\(user)`!")
        return .ok(.init(body: .json(retcode)))
      } catch {
        print(error.localizedDescription)
        print("Could not read contents of directory \(String(describing: dirUrl!)).")
        let retcode = Components.Schemas.Json(message: "Can't read topics for user `\(user)`")
        return .ok(.init(body: .json(retcode)))
      }
    } else {
      print("Given DIRECTORY \(String(describing: dirUrl!)) does not exist, nothing read.")
      let retcode = Components.Schemas.Json(message: "Topics for user `\(user)` not read!")
      return .ok(.init(body: .json(retcode)))
    }
    
  }
  
  func getJson(_ input: Operations.GetJson.Input) async throws -> Operations.GetJson.Output {
    let user = input.query.user ?? "Rob"
    let topic = input.query.topic ?? "Huberman"
    
    let fileManager = FileManager.default
    let documentsUrl = fileManager.urls(for: .documentDirectory,
                                      in: .userDomainMask)[0] as NSURL
    
    let fileName = "MyRecallApp/Data" + "/" + user + "/" + topic + ".json"
    let dirUrl = documentsUrl.appendingPathComponent(fileName)
    var isDir: ObjCBool = false
    if fileManager.fileExists(atPath: dirUrl!.path , isDirectory: &isDir) {
      do {
        let contents = try String(contentsOf: dirUrl!)
        print(contents)
        let retcode = Components.Schemas.Json(message: "Reading topic `\(topic)` for user `\(user)`!")
        return .ok(.init(body: .json(retcode)))
      } catch {
        print(error.localizedDescription)
        print("Could not read \(fileName).")
        let retcode = Components.Schemas.Json(message: "Can't read topics for user `\(user)`")
        return .ok(.init(body: .json(retcode)))
      }
    } else {
      print("Given topic \(String(describing: dirUrl!)) does not exist, nothing read.")
      let retcode = Components.Schemas.Json(message: "Topic `\(topic)` for user `\(user)` not read!")
      return .ok(.init(body: .json(retcode)))
    }

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
