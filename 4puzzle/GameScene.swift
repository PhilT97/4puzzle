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
    
    
    
    var gameplayManager : GameplayManager!
    
    
    var IterationCount = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    let touchArea = UIView(frame: CGRect(x: 0, y: -200, width: 300, height: 200))
    let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let reloadButton = UIButton(type: .system)
    var Empty: SKNode?
    var image: UIImage?
    var sprites: [SKSpriteNode] = []
    let globalBlockSize = Int(4)
    lazy var maxNumberOfBlocks = self.globalBlockSize * self.globalBlockSize
    lazy var tileOrder = [Int](1...self.maxNumberOfBlocks)
    var sKView: SKView!
    
    
    
    
    override func didMove(to view: SKView) {
        
        self.gameplayManager = GameplayManager(scene: self, blockSize: globalBlockSize)
        
        // Check if the user has authorized access to their photo library
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            image = gameplayManager.fetchRandomImageFromGallery()
            sprites = gameplayManager.splitImageIntoSprites(image: image, blockSize: globalBlockSize)
            for sprite in sprites {
                self.addChild(sprite)
            }
            
        case .denied, .restricted:
            // Handle denied or restricted authorization status
            break
        case .notDetermined:
            break
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
        default:
            break
        }
        
        // Reload Button
        buttonContainerView.backgroundColor = .systemBlue
        buttonContainerView.layer.cornerRadius = 10 // Optional, um abgerundete Ecken hinzuzufügen
        buttonContainerView.clipsToBounds = true
        buttonContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
        touchArea.center = CGPoint(x: self.frame.width, y: self.frame.height)
        touchArea.backgroundColor = .systemRed
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
        
        touchArea.center = CGPoint(x: view.frame.midX, y: 620)
        buttonContainerView.center = CGPoint(x:view.frame.midX / 4, y:view.frame.midY * 1.2)
        
        Empty = self.childNode(withName: "emptyCell")
        
        gameplayManager.shuffle()
           
        
        let imageSize = CGSize(width:150, height:150)
        let xCenter = UIScreen.main.bounds.width / 2 - (imageSize.width / 2)
        let yCenter = UIScreen.main.bounds.height / 2
        let imagePos = CGPoint(x: xCenter, y: yCenter)
        
        gameplayManager.displayImage(image: image!, inView: self.view!, atPosition: imagePos, withSize: imageSize)
        
        
        // Erstellen und konfigurieren Sie den UIButton
        reloadButton.setTitle("Neu laden", for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        
        // Positionieren Sie den Button innerhalb der UIView
        reloadButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        // Fügen Sie den Button zur UIView hinzu
        buttonContainerView.addSubview(reloadButton)

        // Positionieren Sie die UIView am unteren linken Rand der Szene
        view.addSubview(buttonContainerView)
        
    }
    @objc func reloadButtonTapped() {
        // Code zum Neuladen der GameScene hier
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
    
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
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
    
    


    

    
}
