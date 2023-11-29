//
//  MainMenu.swift
//  4puzzle
//
//  Created by Philipp Tschan on 26.11.23.
//

import SpriteKit
import GameplayKit
import UIKit

class GameMenu: SKScene, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // Start Game Button
    var startGameButton = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var startGame = UIButton(type: .system)
    
    // Game Mode Buttons
    var pictureMode = UIButton(type: .system)
    var galleryMode = UIButton(type: .system)
    
    // Back Button
    var back = UIButton(type: .system)
    
    // animation time
    let slide = 0.3
    
    override func didMove(to view: SKView) {
        
        // Game Start Button
        self.backgroundColor = .systemCyan
//        startGameButton.backgroundColor = .systemBlue
//        startGameButton.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.height * 0.1)
//        startGameButton.layer.cornerRadius = 10
//        startGameButton.clipsToBounds = true
//        startGameButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        startGameButton.center = CGPoint(x: view.frame.midX, y: view.frame.midY * 1.5)
        
        // Back Button
        back.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        back.setTitle("back", for: .normal)
        back.setTitleColor(.white, for: .normal)
        back.layer.cornerRadius = 20
        back.backgroundColor = .systemBlue
        back.center.y = view.frame.height - view.frame.height * 0.15
        back.center.x = view.frame.width * 0.1
        back.addTarget(self, action: #selector(backFunc), for: .touchUpInside)
        back.alpha = 0

        // Choose Mode Buttons
        // Picture Mode
        pictureMode.frame = CGRect(x: 0, y: 200, width: view.frame.width / 2, height: view.frame.height * 0.1)
        pictureMode.setTitle("Picture Mode", for: .normal)
        pictureMode.setTitleColor(.white, for: .normal)
        pictureMode.layer.cornerRadius = 20
        pictureMode.backgroundColor = .systemBlue
        pictureMode.center.x = view.frame.midX * 3
        
        // Gallery Mode
        galleryMode.frame = CGRect(x: 0, y: 300, width: view.frame.width / 2, height: view.frame.height * 0.1)
        galleryMode.setTitle("Gallery Mode", for: .normal)
        galleryMode.setTitleColor(.white, for: .normal)
        galleryMode.layer.cornerRadius = 20
        galleryMode.backgroundColor = .systemBlue
        galleryMode.center.x = view.frame.midX * 3
        galleryMode.addTarget(self, action: #selector(galleryModeFunc), for: .touchUpInside)
        
        
        view.addSubview(pictureMode)
        view.addSubview(galleryMode)
        view.addSubview(back)
        
        
        startGame.setTitle("Start Game", for: .normal)
        startGame.setTitleColor(.white, for: .normal)
        startGame.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.height * 0.1)
        startGame.backgroundColor = .systemBlue
        startGame.layer.cornerRadius = 20
        startGame.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        startGame.center = CGPoint(x: view.frame.midX, y: view.frame.midY * 1.5)
        startGame.tag = 1
//        startGameButton.addSubview(startGame)
        
        view.addSubview(startGame)
        
        
        
        

    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        // Entfernen Sie alle Buttons oder andere UIViews, die Sie der View hinzugefügt haben
        for button in view.subviews {
            if let current = button as? UIButton {
                current.removeFromSuperview()
            }
        }
        // Wiederholen Sie dies für alle anderen UIView-Elemente
    }
    @objc func newGame(from view: SKView) {
        
        UIView.animate(withDuration: self.slide){
            self.pictureMode.center.x -= view.frame.midX * 2
            self.galleryMode.center.x -= view.frame.midX * 2
            self.startGameButton.center.x -= view.frame.midX * 2
            self.startGame.center.x -= view.frame.midX * 2
            self.back.alpha = 1
        }
    }
    
    // back Button function
    @objc func backFunc(_ sender: UIButton) {
        for view in self.view!.subviews {
            if let button = view as? UIButton, button != sender{
                UIView.animate(withDuration: self.slide) {
                    button.center.x += self.view!.frame.midX * 2
                    sender.alpha = 0
                }
            }
//            if view.tag == 1 {
//                UIView.animate(withDuration: 1.0){
//                    view.center.x += self.view!.frame.midX * 2
//                }
//            }
            
        }
    }
    
    @objc func galleryModeFunc(from view: SKView){
        var delay: TimeInterval = 0.0
        let delayIncrement: TimeInterval = 0.2
        for view in self.view!.subviews {
            if let button = view as? UIButton, button.currentTitle != "back"{
                UIView.animate(withDuration: 0.6, delay: delay, options: [], animations: {
                    button.center.x -= self.view!.frame.midX * 2
                }, completion: nil)
                delay += delayIncrement
            }
            else {
                if let button = view as? UIButton {
                    UIView.animate(withDuration: 0.3){
                        button.alpha = 0
                    }
                }
            }
        }
        if let currentScene = self.scene {
                    currentScene.removeAllActions()
                    currentScene.removeAllChildren()
                    if let view = self.view {
                        if let scene = GameScene(fileNamed: "GameScene") {
                            scene.scaleMode = .aspectFit
                            let wait = SKAction.wait(forDuration: 0.5)
                            self.run(wait){
                                let transition = SKTransition.doorway(withDuration: 0.63)
                                view.presentScene(scene, transition: transition)
                            }
                            
        
                        }
                        view.ignoresSiblingOrder = true
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                
                    
//                     Fügen Sie hier den Code hinzu, um die GameScene neu zu initialisieren
//                     z.B. Spielzustand zurücksetzen und Spiel neu starten
                }
    }
    
}
