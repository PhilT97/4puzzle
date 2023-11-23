//
//  GameplayManager.swift
//  4puzzle
//
//  Created by Philipp Tschan on 23.11.23.
//
import SpriteKit
import GameplayKit
import UIKit
import Photos
import Foundation

class GameplayManager{
    
    unowned var scene : GameScene
    var globalBlockSize : Int
    var shuffleMoves : Bool = false
    
    init(scene : GameScene, blockSize: Int){
        self.scene = scene
        self.globalBlockSize = blockSize
    }

    
    var IterationCount = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var image: UIImage?
    var sprites: [SKSpriteNode] = []
    
    lazy var maxNumberOfBlocks = self.globalBlockSize * self.globalBlockSize
    lazy var tileOrder = [Int](1...self.maxNumberOfBlocks)
    var sKView: SKView!
    
    
    func fetchRandomImageFromGallery() -> UIImage? {
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard fetchResult.count > 0 else { return nil }
        let randomIndex = Int.random(in: 0..<fetchResult.count)
        let randomAsset = fetchResult.object(at: randomIndex)
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        var image: UIImage?
        imageManager.requestImage(for: randomAsset, targetSize: CGSize(width: 600, height: 600), contentMode: .aspectFill, options: requestOptions) { result, _ in
            image = result
        }
        
        // Crop the image to a square
        let size = min(image!.size.width, image!.size.height)
        let rect = CGRect(x: (image!.size.width - size) / 2, y: (image!.size.height - size) / 2, width: size, height: size)
        if let croppedCGImage = image!.cgImage!.cropping(to: rect) {
            let croppedImage = UIImage(cgImage: croppedCGImage)
            return croppedImage
        } else {
            return nil // oder ein Standard-UIImage, falls das Zuschneiden fehlschlägt
        }
    }
    
    
    func splitImageIntoSprites(image: UIImage!, blockSize: Int) -> [SKSpriteNode]{
            
    //        // Crop the image to a square
            let size = min(image.size.width, image.size.height)
    //        let rect = CGRect(x: (image.size.width - size) / 2, y: (image.size.height - size) / 2, width: size, height: size)
    //        let croppedImage = image.cgImage!.cropping(to: rect)!
            let croppedImage = image.cgImage!
            
            
            // Split the square image into 16 equal parts
            let spriteWidth = size / CGFloat(blockSize)
            var sprites: [SKSpriteNode] = []
            for row in 0..<blockSize {
                for col in 0..<blockSize {
                    let x = CGFloat(col) * spriteWidth
                    let y = CGFloat(blockSize-1 - row) * spriteWidth
                    let spriteRect = CGRect(x: x, y: y, width: spriteWidth, height: spriteWidth)
                    let spriteCGImage = croppedImage.cropping(to: spriteRect)!
                    let spriteImage = UIImage(cgImage: spriteCGImage)
                    let spriteTexture = SKTexture(image: spriteImage)
                    let sprite = SKSpriteNode(texture: spriteTexture)
                    sprites.append(sprite)
                }
            }
            
            // Set the last sprite to be black
            let lastSprite = sprites.popLast()!
            lastSprite.color = .black
            lastSprite.colorBlendFactor = 1.0
            lastSprite.name = ("emptyCell")
            sprites.append(lastSprite)
                    
            // set position counter
            var positionCounter = 0
            
            // Calculate Offset in X-Axis
            let containerSize = scene.size
            
            let totalGridWidth = CGFloat(blockSize) * spriteWidth
            let GridOffset = (containerSize.width - totalGridWidth) / 2
            let xOffset = (totalGridWidth / 2) - GridOffset
            
            // Position the sprites in a 4x4 grid
            let spriteMargin: CGFloat = 0.1
            let spriteSize = CGSize(width: spriteWidth - spriteMargin, height: spriteWidth - spriteMargin)
            for row in 0..<blockSize {
                for col in 0..<blockSize {
                    let index = row * blockSize + col
                    let sprite = sprites[index]
                    sprite.size = spriteSize
                    sprite.position = CGPoint(x: CGFloat(col) * spriteWidth -  xOffset, y: CGFloat(row) * spriteWidth + 100)
                    
                    // Fügen Sie eine 'positionValue' zu 'userData' hinzu, um die Originalposition zu speichern
                    sprite.userData = NSMutableDictionary()
                    sprite.userData?.setValue(positionCounter, forKey: "positionValue")
                    
                    positionCounter += 1
                    
                    sprite.removeFromParent()
                }
            }
            return sprites
            
        }
        
        // swap empty node with the node
        func swapNodes(node: SKNode?, emptyCell: SKNode) {
            if node != nil {
                let tempPos = emptyCell.position
                let emptyCellPos = emptyCell.userData?.value(forKey: "positionValue") as? Int
                let CellPos = node?.userData?.value(forKey: "positionValue") as? Int
                tileOrder.swapAt(emptyCellPos!, CellPos!)
                emptyCell.position = node!.position
                node!.position = tempPos
                if checkIfPuzzleIsSolved() {
                    print("PUZZLE IS SOLVED!")
                }
            }
            
        }
        
        // Swipe Mechanics
        func moveRight() {
            let parentNode = scene.Empty?.parent
            let emptyLeftPosition = scene.Empty!.position.x - scene.Empty!.frame.width / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: emptyLeftPosition - 10, y: scene.Empty!.position.y))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
                print("SWIPE RIGHT")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
        }
        
        func moveLeft() {
            let parentNode = scene.Empty?.parent
            let emptyRightPosition = scene.Empty!.position.x + scene.Empty!.frame.width / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: emptyRightPosition + 10, y: scene.Empty!.position.y))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
                print("SWIPE UP")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            
        }
        
        func moveUp() {
            let parentNode = scene.Empty?.parent
            let emptyBottomPosition = scene.Empty!.position.y - scene.Empty!.frame.height / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: scene.Empty!.position.x, y: emptyBottomPosition - 10))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
                print("SWIPE UP")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            
        }
        
        func moveDown() {
            let parentNode = scene.Empty?.parent
            let emptyTopPosition = scene.Empty!.position.y + scene.Empty!.frame.height / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: scene.Empty!.position.x, y: emptyTopPosition + 10))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
                print("SWIPE DOWN")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            
            
            
        }
        
    func checkIfPuzzleIsSolved() -> Bool {
            let solved = tileOrder == (1...maxNumberOfBlocks).map {$0}
            if(solved && !shuffleMoves) {
                let alert = UIAlertController(title: "Siegesbenachrichtigung", message: "GEWONNEN!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.scene.view?.window?.rootViewController?.present(alert, animated: true)
                
            }
            return solved
        
        }

        @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                switch gestureRecognizer.direction {
                case .right:
                    moveRight()
                case .left:
                    moveLeft()
                case .up:
                    moveUp()
                case .down:
                    moveDown()
                default:
                    break
                }
            }
        }
        
        func shuffle() {
            // Definieren Sie ein Array von Closures, die Ihre Funktionen repräsentieren
            let functions: [() -> Void] = [
                self.moveUp,
                self.moveDown,
                self.moveLeft,
                self.moveRight
            ]
            
            // Wählen Sie eine zufällige Closure aus dem Array aus und führen Sie sie aus
            var tempIndex = 0
            for _ in 1...100 {
                shuffleMoves = true
                var randomIndex = Int.random(in: 0..<functions.count)
                while(tempIndex == ((randomIndex % 3) + 1) && !isValidMove()) {
                    randomIndex = Int.random(in: 0..<functions.count)
                }
                tempIndex = randomIndex
                let randomFunction = functions[randomIndex]
                randomFunction()
            }
            shuffleMoves = false
            
        }
        
        func displayImage(image: UIImage, inView parentView: UIView, atPosition position: CGPoint, withSize size: CGSize) {
            // Erstellen Sie eine UIImageView mit dem Bild
            let imageView = UIImageView(image: image)
            
            // Stellen Sie den Frame der ImageView ein, um die Größe und Position zu bestimmen
            imageView.frame = CGRect(origin: position, size: size)
            
            // Fügen Sie die ImageView zur übergeordneten Ansicht hinzu
            parentView.addSubview(imageView)
        }
    
    func isValidMove() -> Bool {
        let parentNode = scene.Empty?.parent
        let emptyRightPosition = scene.Empty!.position.x + scene.Empty!.frame.width / 2
        let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: emptyRightPosition + 10, y: scene.Empty!.position.y))
        let Neighbour = Nodes?.first
        return Neighbour != nil
    }
        
    
}
