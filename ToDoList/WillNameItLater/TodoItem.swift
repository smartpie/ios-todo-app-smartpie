import Foundation

enum Importance: String {
    case important = "важная"
    case basic = "обычная"
    case low = "неважная"
}

struct TodoItem: Equatable {
    static let separator: String = ";"
    
    let id: String
    let text: String
    let importance: Importance
    let deadLine: Date?
    let isDone: Bool
    let creationDate: Date
    let lastChangeDate: Date?
    
    init(id: String,
         importance: Importance,
         deadLine: Date?,
         isDone: Bool,
         creationDate: Date?,
         lastChangeDate: Date?,
         text: String) {
        
        self.id = id
        self.importance = importance
        self.deadLine = deadLine
        self.isDone = isDone
        self.creationDate = creationDate ?? Date()
        self.lastChangeDate = lastChangeDate
        self.text = text
    }
    
    init(importance: Importance,
         deadLine: Date?,
         isDone: Bool,
         creationDate: Date?,
         lastChangeDate: Date?,
         text: String) {
        self.init(id: UUID().uuidString,
             importance: importance,
             deadLine: deadLine,
             isDone: isDone,
             creationDate: creationDate,
             lastChangeDate: lastChangeDate,
             text: text)
    }
}

extension TodoItem {
    // –––––––––– JSON ––––––––––
    static func parse(json: Any) -> TodoItem? {
        if json as? [String: Any] == nil { return nil }
        let properties = json as! [String: Any]
        var temp: [String: Any] = [:]

        if let tempId = properties["id"] as? String, tempId != "" { temp["id"] = tempId } else { return nil }
        if let tempText = properties["text"] as? String, tempText != "" {
            temp["text"] = tempText
        } else { return nil }
        
        if properties["importance"] == nil { temp["importance"] = Importance(rawValue: "обычная") }
        else if let tempImportanceRaw = properties["importance"] as? String,
                let tempImportance = Importance(rawValue: tempImportanceRaw) { temp["importance"] = tempImportance }
        else { return nil }

        if properties["deadLine"] == nil { temp["deadLine"] = nil }
        else if let tempDeadLine = properties["deadLine"] as? Int {
            temp["deadLine"] = Date(timeIntervalSince1970: Double(tempDeadLine))
        } else { return nil }

        if let tempIsDone = properties["isDone"] as? Bool { temp["isDone"] = tempIsDone } else { return nil }

        if let tempCreationDate = properties["creationDate"] as? Int {
            temp["creationDate"] = Date(timeIntervalSince1970: Double(tempCreationDate))
        } else { return nil }

        if properties["lastChangeDate"] == nil { temp["lastChangeDate"] = nil }
        else if let tempLastChangeDate = properties["lastChangeDate"] as? Int {
            temp["lastChangeDate"] = Date(timeIntervalSince1970: Double(tempLastChangeDate))
        } else { return nil }
        
        return TodoItem(id: temp["id"] as! String,
                        importance: temp["importance"] as! Importance,
                        deadLine: temp["deadLine"] as? Date,
                        isDone: temp["isDone"] as! Bool,
                        creationDate: temp["creationDate"] as? Date,
                        lastChangeDate: temp["lastChangeDate"] as? Date,
                        text: temp["text"] as! String)
    }
    
    
    var json: Any {
        var tempDictionary: [String: Any] = [:]
        
        tempDictionary["id"] = id
        tempDictionary["text"] = text
        if importance != Importance.basic { tempDictionary["importance"] = importance.rawValue }
        if deadLine != nil { tempDictionary["deadLine"] = Int(deadLine!.timeIntervalSince1970) }
        tempDictionary["isDone"] = isDone
        tempDictionary["creationDate"] = Int(creationDate.timeIntervalSince1970)
        if lastChangeDate != nil { tempDictionary["lastChangeDate"] = Int(lastChangeDate!.timeIntervalSince1970) }

        return tempDictionary
    }
    
    
    // –––––––––– CSV ––––––––––
    static func parse(csv: String) -> TodoItem? {
        // ORDER:
        //  id  text  importance  deadLine  isDone  creationDate  lastChangeDate
        var temp: [String: Any] = [:]
        
        let csvSplit = csv.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: separator, omittingEmptySubsequences: false).map { String($0) }
        if csvSplit.count != 7 { return nil }
        
        if csvSplit[0] != "" { temp["id"] = csvSplit[0] } else { return nil }
        if csvSplit[1] != "" { temp["text"] = csvSplit[1] } else { return nil }
        
        if csvSplit[2] != "" {
            if let tempImportance = Importance(rawValue: csvSplit[2]) { temp["importance"] = tempImportance }
            else { return nil }
        } else { temp["importance"] = Importance(rawValue: "обычная") }
        
        if csvSplit[3] != "" {
            if let dateSince1970 = Double(csvSplit[3]) { temp["deadLine"] = Date(timeIntervalSince1970: dateSince1970) }
            else { return nil }
        } else { temp["deadLine"] = nil }
        
        if csvSplit[4] != "", let tempBool = Bool(csvSplit[4]) { temp["isDone"] = tempBool } else { return nil }
        
        if csvSplit[5] != "", let dateSince1970 = Double(csvSplit[5]) {
            temp["creationDate"] = Date(timeIntervalSince1970: dateSince1970)
        } else { return nil }
        
        if csvSplit[6] != "" {
            if let dateSince1970 = Double(csvSplit[6]) { temp["lastChangeDate"] = Date(timeIntervalSince1970: dateSince1970) }
            else { return nil }
        } else { temp["lastChangeDate"] = nil }
        
        return TodoItem(id: temp["id"] as! String,
                        importance: temp["importance"] as! Importance,
                        deadLine: temp["deadLine"] as? Date,
                        isDone: temp["isDone"] as! Bool,
                        creationDate: temp["creationDate"] as? Date,
                        lastChangeDate: temp["lastChangeDate"] as? Date,
                        text: temp["text"] as! String)
    }
    
    
    var csv: String {
        // ORDER:
        //  id  text  importance  deadLine  isDone  creationDate  lastChangeDate
        
        var csv = id + TodoItem.separator + text + TodoItem.separator
        if importance != .basic {
            csv += importance.rawValue + TodoItem.separator
        } else { csv += TodoItem.separator }
        
        if deadLine != nil {
            csv += String(Int(deadLine!.timeIntervalSince1970)) + TodoItem.separator
        } else { csv += TodoItem.separator }
        csv += String(isDone) + TodoItem.separator + String(Int(creationDate.timeIntervalSince1970)) + TodoItem.separator
        if lastChangeDate != nil { csv += String(Int(lastChangeDate!.timeIntervalSince1970)) }
        
        return csv
    }
}
