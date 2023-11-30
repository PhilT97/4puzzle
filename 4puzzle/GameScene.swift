//
//  GameScene.swift
//  4puzzle
//
//  Created by Philipp Tschan on 25.03.23.
//

import SpriteKit
import GameplayKit
import UIKit
import Photos

class GameScene: SKScene, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var globalBlockSize = Int()
    
    var gameplayManager : GameplayManager!
    var inShuffle : Bool = true
    
    var IterationCount = Int()
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    let touchArea = UIView()
    let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let reloadButton = UIButton(type: .system)
    
    let menuButtonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let menuButton = UIButton(type: .system)
    
    var Empty: SKNode?
    var image: UIImage?
    var sprites: [SKSpriteNode] = []
    lazy var maxNumberOfBlocks = self.globalBlockSize * self.globalBlockSize
    lazy var tileOrder = [Int](1...self.maxNumberOfBlocks)
    var sKView: SKView!
    
    var imageSize = CGSize()
    var tileBackground = SKSpriteNode()
    
    var gridCenter = CGPoint()
    var gridSize = CGSize()
    
    
    
    
    
    override func didMove(to view: SKView) {
        
        // Check if the user has authorized access to their photo library
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        self.gameplayManager = GameplayManager(scene: self, blockSize: globalBlockSize)
        
        
        switch authorizationStatus {
        case .authorized:
            image = gameplayManager.fetchRandomImageFromGallery()
            let out = gameplayManager.splitImageIntoSprites(image: image, blockSize: globalBlockSize)
            sprites = out.spritesOut
            gridCenter = out.gridCenter
            gridSize = out.gridSize
            for sprite in sprites {
                sprite.zPosition = 1
                self.addChild(sprite)
            }
        case .denied, .restricted:
            // Handle denied or restricted authorization status
            break
        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
//                DispatchQueue.main.async {
//                    switch authorizationStatus {
//                    case .authorized:
//                        break
//                    case .denied, .restricted:
//                        // Handle denied or restricted authorization status
//                        break
//                    case .notDetermined:
//                        // Handle not determined authorization status
//                        break
//                    default:
//                        break
//                    }
//                }
//            }
            break
        default:
            break
        }
        
        
        
        touchArea.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.25)
        
        // tile Background
        tileBackground.size = gridSize
        tileBackground.color = .black
        tileBackground.position = gridCenter
        tileBackground.alpha = 1
        tileBackground.zPosition = -2
        self.addChild(tileBackground)
        
        
        // Reload Button
        buttonContainerView.backgroundColor = .systemBlue
        buttonContainerView.layer.cornerRadius = 10 // Optional, um abgerundete Ecken hinzuzufügen
        buttonContainerView.clipsToBounds = true
        buttonContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Menu Button
        menuButtonContainerView.backgroundColor = .systemRed
        menuButtonContainerView.layer.cornerRadius = 10
        menuButtonContainerView.clipsToBounds = true
        menuButtonContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuButtonContainerView.center = CGPoint(x: view.frame.midX * 1.75, y: view.frame.midY * 1.2)
        
        menuButton.setTitle("Menu", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: #selector(backToMenu), for: .touchUpInside)
        menuButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
    
        touchArea.center = CGPoint(x: self.frame.width, y: self.frame.height)
        touchArea.backgroundColor = .clear
        touchArea.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(touchArea)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        touchArea.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        touchArea.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        touchArea.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        touchArea.addGestureRecognizer(swipeDown)
        
        touchArea.center = CGPoint(x: view.frame.midX, y: view.frame.height * 0.8)
        buttonContainerView.center = CGPoint(x:view.frame.midX / 4, y:view.frame.midY * 1.2)
        
        Empty = self.childNode(withName: "emptyCell")
        
//        gameplayManager.shuffle()
           
        
        let imageSize = CGSize(width:300, height:300)
        let xCenter = 0
        let yCenter = -125
        let imagePos = CGPoint(x: xCenter, y: yCenter)
        
        let hintImage = gameplayManager.displayImage(image: image!, inView: self.view!, atPosition: imagePos, withSize: imageSize)
        hintImage.zPosition = 1
        self.addChild(hintImage)
        
        
        // Erstellen und konfigurieren Sie den UIButton
        reloadButton.setTitle("New", for: .normal)
        reloadButton.setTitleColor(.white, for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        
        // Positionieren Sie den Button innerhalb der UIView
        reloadButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        // Fügen Sie den Button zur UIView hinzu
        buttonContainerView.addSubview(reloadButton)

        // Positionieren Sie die UIView am unteren linken Rand der Szene
        view.addSubview(buttonContainerView)
        
        menuButtonContainerView.addSubview(menuButton)
        view.addSubview(menuButtonContainerView)
        
        let wait = SKAction.wait(forDuration: 0.8)
        self.run(wait){
            self.gameplayManager.shuffleWithDelay(count: self.IterationCount)
        }
        
        
//        performShuffle()
        
        
        
        
        
    }
    @objc func reloadButtonTapped() {
        // Code zum Neuladen der GameScene hier
        if let currentScene = self.scene {
            currentScene.removeAllActions()
            currentScene.removeAllChildren()
            if let view = self.view {
                if let scene = GameScene(fileNamed: "GameScene") {
                    scene.globalBlockSize = self.globalBlockSize
                    scene.IterationCount = self.IterationCount
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
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Entfernen aller Subviews vom SKView
        view.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    @objc func backToMenu() {
        if let currentScene = self.scene {
            currentScene.removeAllActions()
            currentScene.removeAllChildren()
            if let view = self.view {
                if let scene = GameScene(fileNamed: "GameMenu") {
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
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            gameplayManager.shuffleMoves = false
            switch gestureRecognizer.direction {
            case .right:
                gameplayManager.moveRight()
            case .left:
                gameplayManager.moveLeft()
            case .up:
                gameplayManager.moveUp()
            case .down:
                gameplayManager.moveDown()
            default:
                break
            }
        }
    }
    
    func setGlobalBlockSize(blockSize: Int){
        self.globalBlockSize = blockSize
    }
    
    


    

    
}
