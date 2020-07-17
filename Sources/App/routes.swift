import Vapor
import Leaf
import PokerNowKit
import SwiftCSV

func routes(_ app: Application) throws {

    app.get { req in
        req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter"
        ])
    }

    app.on(.POST, "logs", body: .collect(maxSize: "1mb")) { req -> EventLoopFuture<Vapor.View> in
        let log = try req.content.decode(Log.self)

        var converted : String = ""
        do {
            let csvFile: CSV = try CSV(string: log.raw)
            
            
            let game = Game(rows: csvFile.namedRows)
            for hand in game.hands {
                let pokerStarsLines = hand.getPokerStarsDescription(heroName: "pj4533", multiplier: 0.01, tableName: "PokerNowConverter").joined(separator: "\n")
                converted.append(pokerStarsLines)
                converted.append("\n")
            }
        } catch let parseError as CSVParseError {
            print(parseError)
        } catch {
            print("Error loading file")
        }
        
         return req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter",
            "raw": log.raw,
            "converted": converted
        ])
    }
    
}
