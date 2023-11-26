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
    
    let startGameButton = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let startGame = UIButton(type: .system)
    
    override func didMove(to view: SKView) {

        self.backgroundColor = .systemCyan
        startGameButton.backgroundColor = .systemBlue
        startGameButton.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.height * 0.1)
        startGameButton.layer.cornerRadius = 10
        startGameButton.clipsToBounds = true
        startGameButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        startGameButton.center = CGPoint(x: view.frame.midX, y: view.frame.midY * 1.5)

        
        
        startGame.setTitle("Start Game", for: .normal)
        startGame.setTitleColor(.white, for: .normal)
        startGame.frame = CGRect(x: 0, y: 0, width: view.frame.width / 2, height: view.frame.height * 0.1)
        startGame.backgroundColor = .systemBlue
        startGame.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        startGameButton.addSubview(startGame)
        
        view.addSubview(startGameButton)
        
        

    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        // Entfernen Sie alle Buttons oder andere UIViews, die Sie der View hinzugefügt haben
        startGame.removeFromSuperview()
        startGameButton.removeFromSuperview()
        // Wiederholen Sie dies für alle anderen UIView-Elemente
    }
    @objc func newGame() {
        if let currentScene = self.scene {
            currentScene.removeAllActions()
            currentScene.removeAllChildren()
            if let view = self.view {
                if let scene = GameScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFit
                    
                    view.presentScene(scene)
                    
                }
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
            }
            
            // Fügen Sie hier den Code hinzu, um die GameScene neu zu initialisieren
            // z.B. Spielzustand zurücksetzen und Spiel neu starten
        }
    }
    
}
