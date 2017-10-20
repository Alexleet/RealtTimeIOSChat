//
//  ChatItemController.swift
//  ChattoChatApp
//
//  Created by Alif on 12/10/2017.
//  Copyright © 2017 Alif. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import FirebaseDatabase
import SwiftyJSON

class ChatItemController: NSObject {
    
    var initialMessages = [ChatItemProtocol]()
    var items = [ChatItemProtocol]()
    var totalMessages = [ChatItemProtocol]()
    var loadMore = false
    var userUID: String!
    typealias completeLoading = () -> Void
    
    func loadIntoItemArray(neededMsg: Int, moreToLoad: Bool) {
        
        for index in stride(from: initialMessages.count - items.count, to: (initialMessages.count - items.count - neededMsg), by: -1) {
            self.items.insert(initialMessages[index - 1], at: 0)
            self.loadMore = moreToLoad
        }
    
    }
    
    func insertItem(message: ChatItemProtocol) {
        
        self.items.append(message)
        self.totalMessages.append(message)
    
    }

    func loadPrevious(completion: @escaping completeLoading) {
        Database.database().reference().child("User-messages").child(Me.uid).child(userUID).queryEnding(atValue: nil, childKey: self.items.first?.uid).queryLimited(toLast: 51).observeSingleEvent(of: .value, with: { [ weak self ] (snapshot) in
            
            var msgs = Array(JSON(snapshot.value as Any).dictionaryValue.values).sorted(by: {(lhs, rhs) -> Bool in
                return lhs["date"].doubleValue < rhs["date"].doubleValue
            })
            
            msgs.removeLast()
            self?.loadMore = msgs.count > 50
            let converted = self!.convertToChatItemProtocal(messages: msgs)
            
            for index in stride(from: converted.count, to: converted.count - min(msgs.count, 50), by: -1) {
                self?.items.insert(converted[index - 1], at: 0)
            }
            
            completion()
        })
    }
    
    func adjustWindow() {
        self.items.removeFirst(200)
        self.loadMore = true
        
    }
}
