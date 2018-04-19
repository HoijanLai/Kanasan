//
//  ViewController.swift
//  KANA
//
//  Created by Hoijan Lai on 29/01/2018.
//  Copyright © 2018 Hoijan Lai. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

extension UIImage {
    convenience init(view: DrawView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


class ViewController: UIViewController {
    
    /*
     these are the data we gonna use
    */
    
    
    
    
    
    let hiraganas = ["あ", "い", "う", "え", "お",
                     "か", "き", "く", "け", "こ",
                     "さ", "し", "す", "せ", "そ",
                     "た", "ち", "つ", "て", "と",
                     "な", "に", "ぬ", "ね", "の",
                     "は", "ひ", "ふ", "へ", "ほ",
                     "ま", "み", "む", "め", "も",
                     "や", "ゆ", "よ",
                     "ら", "り", "る", "れ", "ろ",
                     "わ", "を", "ん"]
    
    
//    let kataganas = ["ア", "イ", "ウ", "エ", "オ",
//                     "カ", "キ", "ク", "ケ", "コ",
//                     "サ", "シ", "ス", "セ", "ソ",
//                     "タ", "チ", "ツ", "テ", "ト",
//                     "ナ", "ニ", "ヌ", "ネ", "ノ",
//                     "ハ", "ヒ", "フ", "ヘ", "ホ",
//                     "マ", "ミ", "ム", "メ", "モ",
//                     "ヤ", "ユ", "ヨ",
//                     "ラ", "リ", "ル", "レ", "ロ",
//                     "ワ", "ヲ", "ン"]
    
    /*
     these will define a question
    */
    var kanaIdx: Int = 0
    var userWritting: String = ""
    
    
    /*
     TODO: change this to something more reliable
    */
    // var kanaSounds = [Sound]()
    
    
    
    /*
     interface stuff
    */
    @IBOutlet weak var drawView: DrawView!
    var audioPlayer: AVAudioPlayer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // loadSounds()
    }
    
    
    

    
    
    /*
     this will pass data to popup
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCheckerPopupSegue" {
            let popup = segue.destination as! PopupViewController
            popup.targetLabel = hiraganas[kanaIdx]
            popup.userWritting = userWritting
        }
    }
    
    
    


    
    /*
     Button Events
    */
    
    @IBAction func nextOne(_ sender: Any) {
        // TODO : slow response while pressing really quick
        let thisButton = sender as? UIButton
        let buttonTitle = thisButton!.currentTitle
        setButton(button: thisButton, isActive: false, showText: "PLAYING..")
        
        // play the selected kana
        kanaIdx = Int(arc4random_uniform(46))
        playKana(kanaId: kanaIdx)

        // this is a delay in time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.setButton(button: thisButton, isActive: true, showText: buttonTitle!)
        })
        
        drawView.erase()
    }
    
    @IBAction func checkAnswer(_ sender: Any) {
        let userImage = UIImage(view: drawView)
        let resizedImage = userImage.resizeImage(targetSize: CGSize(width: 64, height: 64))
        updateClassifications(for: resizedImage)
    }

    @IBAction func erase(_ sender: Any) {
        drawView.erase()
    }
    
    @IBAction func Undo(_ sender: Any) {
        drawView.undo()
    }
    
    
    
    
    
    /*
     Helper Functions
     */
    func setButton(button: UIButton!, isActive: Bool, showText: String) {
        button!.setTitle(showText, for: .normal)
        button!.isEnabled = isActive
        if isActive {
            button!.alpha = 1.0
        } else {
            button!.alpha = 0.5
        }
        
    }
    
    func playKana(kanaId: Int) {
        let kanaURL = Bundle.main.url(forResource: "./kana_sound/kana_\(kanaId)", withExtension: "mp3")
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: kanaURL!)
        } catch {
            print(error)
        }
        audioPlayer.play()
    }
    
    

    
    
    /*
     coreml
     */
    func updateClassifications(for image: UIImage) {
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([self.classificationRequest])
        } catch {
            print("Failed to perform classification.\n\(error.localizedDescription)")
        }
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: kana_model().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("Unable to classify image.\n\(error!.localizedDescription)")
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        let classifications = results as! [VNClassificationObservation]
        
        if classifications.isEmpty {
            print("Nothing recognized.")
        } else {
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
            }
            print("Classification:\n" + descriptions.joined(separator: "\n"))
            self.userWritting = classifications.prefix(1)[0].identifier
        }
    }
    
    
    
    
    
//    TODO : fix the bug
//    func speakItLoud(word: String) {
//        let utterance = AVSpeechUtterance(string: word)
//        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
//        let synthesizer = AVSpeechSynthesizer()
//        synthesizer.speak(utterance)
//    }
    
    
//    func loadSounds() {
//        for idx in 0...45 {
//            kanaSounds.append(Sound(name: "./kana_sound/kana_\(idx)"))
//        }
//    }
    

}











