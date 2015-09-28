//
//  Game.swift
//  Camira
//
//  Created by Marcus Kida on 18/05/2015.
//  Copyright (c) 2015 Marcus Kida. All rights reserved.
//

import UIKit

enum CamiraTableViewCell: String {
    case Place = "PlaceCell", Action = "ActionCell"
    static let allValues = [Place, Action]
}

protocol GameDelegate: class {
    func gameWillReloadData (game: Game)
}

class Game: NSObject {
    var title: String!
    var subtitle: String!
    
    let initialPlace: Place!
    let player: Player!
    
    let tableView: UITableView!
    weak var gameDelegate: GameDelegate!
    
    var heartbeat: NSTimer!
    
    init(title: String!, subtitle: String!, initialPlace: Place!, player: Player!, tableView: UITableView!, gameDelegate: GameDelegate) {
        self.title = title
        self.subtitle = subtitle
        self.initialPlace = initialPlace
        self.player = player
        self.tableView = tableView
        self.gameDelegate = gameDelegate
        super.init()
    }
    
    func play () {
        self.heartbeat = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "heartbeat:", userInfo: nil, repeats: true)
        self.tableView.reloadData()
    }
    
    func heartbeat (sender: NSTimer) {
        if let place = placeAtStep(currentStep()) {
            if let nextPlace = place.nextPlace {
                if let delay = nextPlace.delay {
                    let newDelay = Int(delay - 1)
                    nextPlace.delay = newDelay
                    if newDelay == 0 {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func numberOfRowsInSection (section: Int) -> Int {
        let rows = currentStep() + 1
        println("rows: \(rows)")
        return rows
    }
    
    func cellForRowAtIndexPath (indexPath: NSIndexPath) -> UITableViewCell {
        println("indexPath.row: \(indexPath.row) * isPlace: \(isPlace(indexPath.row))")
        if indexPath.row == 2 {
            
        }
        if let isPlace = isPlace(indexPath.row) {
            if isPlace {
                let cell = tableView.dequeueReusableCellWithIdentifier("PlaceCell", forIndexPath: indexPath) as! UITableViewCell
                if let label = cell.textLabel {
                    label.text = textAtStep(indexPath.row, error: nil)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ActionCell", forIndexPath: indexPath) as! ActionCell
                cell.place = placeAtStep(indexPath.row)
                cell.reload = { () -> () in
                    if let delegate = self.gameDelegate {
                        delegate.gameWillReloadData(self)
                    }
                }
                println("actions at step \(indexPath.row) -> \(actionsAtStep(indexPath.row))")
                if let actions = actionsAtStep(indexPath.row) {
                    if actions.count < 1 {
                        cell.leftActionButton.hidden = true
                    }
                    if actions.count < 2 {
                        cell.rightActionButton.hidden = true
                    }
                    if let firstAction = actions.first {
                        cell.leftActionButton.setTitle(firstAction.text, forState: .Normal)
                    }
                    if let secondAction = actions.last {
                        cell.rightActionButton.setTitle(secondAction.text, forState: .Normal)
                    }
                }
                return cell
            }
        }
        return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
    }
    
    private func textAtStep (step: Int, error: NSErrorPointer) -> String? {
        if step == 0 {
            return initialPlace.text
        }
        let place = placeAtStep(step)
        if let aPlace = place {
            return aPlace.text
        }
        return nil
    }
    
    private func actionsAtStep (step: Int) -> [Action]? {
        if let place = placeAtStep(step) {
            return place.actions
        }
        if let place = placeAtStep(step-1) {
            return place.actions
        }
        return nil
    }
    
    private func selectedAction (place: Place!) -> Action? {
        if let actions = place.actions {
            for action in actions {
                if action.selected {
                    return action
                }
            }
        }
        return nil
    }
    
    private func nextPlace (place: Place?) -> Place? {
        if let aPlace = place {
            if let action = selectedAction(aPlace) {
                return action.nextPlace
            }
            if let nextPlace = aPlace.nextPlace {
                if nextPlace.delay == 0 {
                    return nextPlace
                }
            }
            return nil
        }
        return initialPlace
    }
    
    private func placeAtStep (step: Int) -> Place? {
        var place: Place?
        for index in 0...step {
            if index == step {
                if place == nil {
                    place = placeAtStep(step-1)
                }
                return place
            }
            place = nextPlace(place)
        }
        return nil
    }
    
    private func currentStep () -> Int! {
        var step = 0
        var nPlace = initialPlace
        while (nPlace != nil) {
            if let nPlaceActions = nPlace?.actions {
                step++
            }
            nPlace = nextPlace(nPlace)
            if nPlace != nil {
                step++
            }
        }
        return step
    }
    
    private func isPlace (step: Int!) -> Bool? {
        if step == 0 {
            return true
        }
        return _isPlace(step, currentStep: 0, thing: initialPlace)
    }
    
    private func _isPlace (step: Int!, currentStep: Int!, thing: AnyObject!) -> Bool? {
        if step == currentStep {
            if let aThing: AnyObject = thing {
                if aThing is Place {
                    return true
                }
                return false
            }
        }
        var nextStep = Int(currentStep)
        nextStep++
        if thing is Place {
            if let actions = (thing as! Place).actions {
                return _isPlace(step, currentStep: nextStep, thing: actions)
            } else {
                return _isPlace(step, currentStep: nextStep, thing: nextPlace((thing as! Place)))
            }
        }
        if let actions = thing as? [Action] {
            for index in 0...actions.count {
                let action = actions[index]
                if action.selected {
                    return _isPlace(step, currentStep: nextStep, thing: action.nextPlace)
                }
            }
        }
        return _isPlace(step, currentStep: nextStep, thing: thing)
    }
}
