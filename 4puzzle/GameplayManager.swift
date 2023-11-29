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
    
    var rng = SystemRandomNumberGenerator()
    // 0.041, 0.365
    unowned var scene : GameScene
    var globalBlockSize : Int
    var shuffleMoves : Bool = true
    var lastMove : Int = 0
    var shuffleDuration : Double = 0.045
    var shuffleFuncDur : Double = 0.365
    
    
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
    
    
    func splitImageIntoSprites(image: UIImage!, blockSize: Int) -> (spritesOut: [SKSpriteNode], gridCenter: CGPoint, gridSize: CGSize){
            
//        // Crop the image to a square
//        let size = min(image.size.width, image.size.height)
        let size = scene.size.width * 0.8
//        let rect = CGRect(x: (image.size.width - size) / 2, y: (image.size.height - size) / 2, width: size, height: size)
//        let croppedImage = image.cgImage!.cropping(to: rect)!
        let croppedImage = image.cgImage!
        var gridCenter = CGPoint()
        var gridSize = CGSize()
        
        
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
        let topMargin = 20.0
        let halfSpriteWidth = spriteWidth / 2
        let leftCorner = -(scene.size.width / 2)
        let leftEdge = leftCorner + halfSpriteWidth
        let xOffset = (scene.size.width - size) / 2
        let topEdge = scene.size.height / 2 - halfSpriteWidth
        let yOffset = spriteWidth * CGFloat(blockSize - 1) + topMargin
        
        // Position the sprites in a 4x4 grid
        let spriteMargin: CGFloat = 0.1
        let spriteSize = CGSize(width: spriteWidth - spriteMargin, height: spriteWidth - spriteMargin)
        for row in 0..<blockSize {
            for col in 0..<blockSize {
                let index = row * blockSize + col
                let sprite = sprites[index]
                sprite.size = spriteSize
                sprite.position = CGPoint(x: leftEdge + CGFloat(col) * spriteWidth + xOffset, y: topEdge + CGFloat(row) * spriteWidth - yOffset)
                
                // Fügen Sie eine 'positionValue' zu 'userData' hinzu, um die Originalposition zu speichern
                sprite.userData = NSMutableDictionary()
                sprite.userData?.setValue(positionCounter, forKey: "positionValue")
                
                positionCounter += 1
                
                sprite.removeFromParent()
            }
        }
        
        
        // Calculate the center of the Tile Background
        var yCenter : CGFloat
        let middleRowIndex = Int(sprites.count / 2) - 1
        // if uneven take the center Point y of the middle tile
        if(sprites.count % 2 != 0) {
            yCenter = sprites[middleRowIndex].position.y
        }
        // else take the bottom edge of the middle row
        else {
            let spriteY = sprites[middleRowIndex].position.y
            let spriteHeight = sprites[middleRowIndex].size.height
            let anchorPointY = sprites[middleRowIndex].anchorPoint.y
            yCenter = spriteY - (spriteHeight * anchorPointY)
        }
        gridSize = CGSize(width: size, height: size)
        gridCenter = CGPoint(x: 0, y: yCenter)
        return (sprites, gridCenter, gridSize)
            
    }

    // swap empty node with the node
    func swapNodes(node: SKNode?, emptyCell: SKNode) {
        if node != nil {
            //images
            let tempPos = emptyCell.position
            let emptyCellPos = emptyCell.userData?.value(forKey: "positionValue") as? Int
            let nodePos = node!.position
            
            let movePic = SKAction.move(to: tempPos, duration: shuffleDuration)
            let moveEmpty = SKAction.move(to: nodePos, duration: shuffleDuration)
            // array
            let CellPos = node?.userData?.value(forKey: "positionValue") as? Int
            tileOrder.swapAt(emptyCellPos!, CellPos!)
            // moving nodes
            emptyCell.zPosition = -1
            emptyCell.run(moveEmpty)
            node!.run(movePic)
            if checkIfPuzzleIsSolved() {
                print("PUZZLE IS SOLVED!")
            }
        }
        
    }
    
        // Check if one Neighbour is null
    func checkNullNeigbour() -> [Int] {
        var excludeMoves : [Int] = []
        let parentNode = scene.Empty?.parent
        let emptyLeftPosition = scene.Empty!.position.x - scene.Empty!.frame.width / 2
        let Right = parentNode?.scene!.nodes(at: CGPoint(x: emptyLeftPosition - 10, y: scene.Empty!.position.y)).first
        let emptyRightPosition = scene.Empty!.position.x + scene.Empty!.frame.width / 2
        let Left = parentNode?.scene!.nodes(at: CGPoint(x: emptyRightPosition + 10, y: scene.Empty!.position.y)).first
        let emptyBottomPosition = scene.Empty!.position.y - scene.Empty!.frame.height / 2
        let Up = parentNode?.scene!.nodes(at: CGPoint(x: scene.Empty!.position.x, y: emptyBottomPosition - 10)).first
        let emptyTopPosition = scene.Empty!.position.y + scene.Empty!.frame.height / 2
        let Down = parentNode?.scene!.nodes(at: CGPoint(x: scene.Empty!.position.x, y: emptyTopPosition + 10)).first
        let Neighbours = [Up, Down, Left, Right]
        for i in 0...3{
            if Neighbours[i] == nil {
                excludeMoves.append(i)
            }
                
        }
        return excludeMoves
    
    }
        
        // Swipe Mechanics
        func moveRight() {
            let parentNode = scene.Empty?.parent
            let emptyLeftPosition = scene.Empty!.position.x - scene.Empty!.frame.width / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: emptyLeftPosition - 10, y: scene.Empty!.position.y))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
//                print("SWIPE RIGHT")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            else {
                print("SWIPE RIGHT")
            }
        }
        
        func moveLeft() {
            let parentNode = scene.Empty?.parent
            let emptyRightPosition = scene.Empty!.position.x + scene.Empty!.frame.width / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: emptyRightPosition + 10, y: scene.Empty!.position.y))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
//                print("SWIPE UP")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            else {
                print("SWIPE Left")
            }
            
        }
        
        func moveUp() {
            let parentNode = scene.Empty?.parent
            let emptyBottomPosition = scene.Empty!.position.y - scene.Empty!.frame.height / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: scene.Empty!.position.x, y: emptyBottomPosition - 10))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
//                print("SWIPE UP")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            else {
                print("SWIPE UP")
            }
            
        }
        
        func moveDown() {
            let parentNode = scene.Empty?.parent
            let emptyTopPosition = scene.Empty!.position.y + scene.Empty!.frame.height / 2
            let Nodes = parentNode?.scene!.nodes(at: CGPoint(x: scene.Empty!.position.x, y: emptyTopPosition + 10))
            let Neighbour = Nodes?.first
            if Neighbour != nil {
//                print("SWIPE DOWN")
                swapNodes(node: Neighbour, emptyCell: scene.Empty!)
            }
            else {
                print("SWIPE DOWN")
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
//            self.shuffleMoves = true
//            var randomIndex = Int.random(in: 0..<functions.count)
//            // check if it is the inverse move
//            while(self.lastMove == ((randomIndex + 1) % 3)) {
//                randomIndex = Int.random(in: 0..<functions.count)
//            }
//            self.lastMove = randomIndex
            let randomIndex = generateMove(excluding: inverseOf(lastMove), and: checkNullNeigbour())
            lastMove = randomIndex
            let randomFunction = functions[randomIndex]
        let wait = SKAction.wait(forDuration: 0.3)
            self.scene.run(wait){
                randomFunction()
            }
        }
        
        func displayImage(image: UIImage, inView parentView: UIView, atPosition position: CGPoint, withSize size: CGSize) {
            // Erstellen Sie eine UIImageView mit dem Bild
            let imageView = UIImageView(image: image)
            
            // Stellen Sie den Frame der ImageView ein, um die Größe und Position zu bestimmen
            imageView.frame = CGRect(origin: position, size: size)
            
            // Fügen Sie die ImageView zur übergeordneten Ansicht hinzu
            parentView.addSubview(imageView)
        }
    
    func twoValueRandomicer(value1:Int, value2:Int) -> Int{
        return Bool.random() ? value1: value2
        
    }
    
    func shuffleWithDelay(count: Int) {
        var actions: [SKAction] = []

        for _ in 0..<count {
            let waitAction = SKAction.wait(forDuration: shuffleFuncDur) // Wartezeit von 1 Sekunde
            let performAction = SKAction.run(shuffle)
            let sequence = SKAction.sequence([waitAction, performAction])
            actions.append(sequence)
        }

        let totalAction = SKAction.sequence(actions)
        scene.run(totalAction)
    }
    
    func inverseOf(_ move: Int) -> Int {
        switch move {
        case 0: return 1
        case 1: return 0
        case 2: return 3
        case 3: return 2
        default: return move
        }
    }

    func generateMove(excluding inverseOfLastMove: Int, and invalidMoves: [Int]) -> Int {
        var possibleMoves = [0, 1, 2, 3]
        possibleMoves.removeAll {invalidMoves.contains($0)}
        possibleMoves.removeAll { $0 == inverseOfLastMove }

        return possibleMoves.randomElement(using: &rng) ?? 1
    }
        
    
}
