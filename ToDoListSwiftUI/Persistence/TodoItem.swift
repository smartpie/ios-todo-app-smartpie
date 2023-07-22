import Foundation

enum Importance: String {
    case important = "important"
    case basic = "basic"
    case low = "low"
}

public struct TodoItem: Equatable, Sendable, Identifiable {
    static let separator: String = ";"

    public let id: String
    let text: String
    let importance: Importance
    let deadLine: Date?
    let isDone: Bool
    let creationDate: Date
    let lastChangeDate: Date?

    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .basic,
         deadLine: Date? = nil,
         isDone: Bool = false,
         creationDate: Date = Date(),
         lastChangeDate: Date? = Date()) {
        self.id = id
        self.importance = importance
        self.deadLine = deadLine
        self.isDone = isDone
        self.creationDate = creationDate
        self.lastChangeDate = lastChangeDate
        self.text = text
    }
}

// MARK: - TodoItem JSON
extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        if json as? [String: Any] == nil { return nil }
        let properties = json as! [String: Any]
        var temp: [String: Any] = [:]

        if let tempId = properties[kId] as? String, tempId != "" { temp[kId] = tempId } else { return nil }
        if let tempText = properties[kText] as? String, tempText != "" {
            temp[kText] = tempText
        } else { return nil }

        if properties[kImportance] == nil { temp[kImportance] = Importance(rawValue: "basic") }
        else if let tempImportanceRaw = properties[kImportance] as? String,
                let tempImportance = Importance(rawValue: tempImportanceRaw) { temp[kImportance] = tempImportance }
        else { return nil }

        if properties[kDeadline] == nil { temp[kDeadline] = nil }
        else if let tempDeadLine = properties[kDeadline] as? Int {
            temp[kDeadline] = Date(timeIntervalSince1970: Double(tempDeadLine))
        } else { return nil }

        if let tempIsDone = properties[kIsDone] as? Bool { temp[kIsDone] = tempIsDone } else { return nil }

        if let tempCreationDate = properties[kCreationDate] as? Int {
            temp[kCreationDate] = Date(timeIntervalSince1970: Double(tempCreationDate))
        } else { return nil }

        if properties[kLastChangeDate] == nil { temp[kLastChangeDate] = nil }
        else if let tempLastChangeDate = properties[kLastChangeDate] as? Int {
            temp[kLastChangeDate] = Date(timeIntervalSince1970: Double(tempLastChangeDate))
        } else { return nil }

        return TodoItem(id: temp[kId] as! String,
                        text: temp[kText] as! String,
                        importance: temp[kImportance] as! Importance,
                        deadLine: temp[kDeadline] as? Date,
                        isDone: temp[kIsDone] as! Bool,
                        creationDate: temp[kCreationDate] as! Date,
                        lastChangeDate: temp[kLastChangeDate] as? Date)
    }


    var json: Any {
        var tempDictionary: [String: Any] = [:]

        tempDictionary[kId] = id
        tempDictionary[kText] = text
        if importance != Importance.basic { tempDictionary[kImportance] = importance.rawValue }
        if deadLine != nil { tempDictionary[kDeadline] = Int(deadLine!.timeIntervalSince1970) }
        tempDictionary[kIsDone] = isDone
        tempDictionary[kCreationDate] = Int(creationDate.timeIntervalSince1970)
        if lastChangeDate != nil { tempDictionary[kLastChangeDate] = Int(lastChangeDate!.timeIntervalSince1970) }

        return tempDictionary
    }

    func getJsonForNet(deviceID: String) -> [String: Any] {
        var tempDictionary: [String: Any] = [:]

        tempDictionary[kId] = id
        tempDictionary[kText] = text
        tempDictionary[kImportance] = importance.rawValue
        if deadLine != nil { tempDictionary[kDeadline] = Int(deadLine!.timeIntervalSince1970) }
        tempDictionary[kIsDone] = isDone
        tempDictionary[kCreationDate] = Int(creationDate.timeIntervalSince1970)
        if lastChangeDate != nil { tempDictionary[kLastChangeDate] = Int(lastChangeDate!.timeIntervalSince1970) }
        tempDictionary[kDeviceID] = deviceID

        return tempDictionary
    }
}

//MARK: - Keys
// Keys that used in backend
private let kId = "id"
private let kText = "text"
private let kImportance = "importance"
private let kDeadline = "deadline"
private let kIsDone = "done"
private let kCreationDate = "created_at"
private let kLastChangeDate = "changed_at"
private let kDeviceID = "last_updated_by"
