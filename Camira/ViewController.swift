//
//  ViewController.swift
//  Camira
//
//  Created by Marcus Kida on 18/05/2015.
//  Copyright (c) 2015 Marcus Kida. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, GameDelegate {
    
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

//        let player = Player(name: "Gustbert")
//        
//        let finalDestination2 = Place(text: "Thats all folks, finally!", actions: nil, npcs: nil, nextPlace: nil)
//        finalDestination2.delay = 5
//        
//        let finalDestination = Place(text: "Thats all folks!", actions: nil, npcs: nil, nextPlace: finalDestination2)
//        finalDestination.delay = 3
//        
//        let surePlace = Place(text: "Sureplace! 😅", actions: nil, npcs: nil, nextPlace: finalDestination)
//        surePlace.delay = 2
//        
//        let finalActions = [Action(text: "Sure!", nextPlace: surePlace), Action(text: "Probably not...", nextPlace: nil)]
//        let actions = [Action(text: "Head right back", nextPlace: Place(text: "That's it, nothing to do for you, or is there?", actions: finalActions, npcs: nil, nextPlace: nil))]
//        let hall = Place(text: "You're standing inside a giant hall!", actions: actions, npcs: nil, nextPlace: nil)
//        game = Game(title: "Fuzzy Camira", subtitle: "An Adventure of low cunning!", initialPlace: hall, player: player, tableView: tableView, gameDelegate: self)
        
        game = Game(title: "Camira", subtitle: "A sample game", initialPlace: Place.start(), player: Player.main(), tableView: tableView, gameDelegate: self)
//        game.play()
        
        let place = game.placeAtStep(5)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return game.cellForRowAtIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }

    func gameWillReloadData(game: Game) {
        tableView.reloadData()
    }
}

extension Action {
    static func hallwayToDiningRoom() -> Action {
        return Action(text: "Go to dining room", nextPlace: Place.diningRoom())
    }
    
    static func escapeThroughWindow() -> Action {
        return Action(text: "Escape through window", nextPlace: Place.outside())
    }
    
    static func goToBathroom() -> Action {
        return Action(text: "Go to bathroom", nextPlace: Place.bathroom())
    }
}

extension Place {
    static func start() -> Place {
        return Place(text: "You're standing in a giant hallway.", actions: [Action.hallwayToDiningRoom()], npcs: nil, nextPlace: nil)
    }
    
    static func diningRoom() -> Place {
        return Place(text: "Oh, a dining room.", actions: [Action.goToBathroom()], npcs: nil, nextPlace: nil)
    }
    
    static func bathroom() -> Place {
        return Place(text: "Smelly old bathroom", actions: [Action.escapeThroughWindow()], npcs: nil, nextPlace: nil)
    }
    
    static func outside() -> Place {
        return Place(text: "You're outside, it's over now!", actions: nil, npcs: nil, nextPlace: Place.gameOver())
    }
    
    static func gameOver() -> Place {
        let p = Place(text: "Really, over!", actions: nil, npcs: nil, nextPlace: nil)
        p.delay = 2
        return p
    }
}

extension Player {
    static func main() -> Player {
        return Player(name: "Marcus")
    }
}

