//
//  SoundViewController.swift
//  AndradeSoundBoard
//
//  Created by MaryC on 31/10/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoG: UILabel!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL: URL?
    var timer:Timer?
    var tiempoTranscurrido: TimeInterval = 0

    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            timer?.invalidate()
            grabarButton.setTitle("GRABAR", for: .normal)
            agregarButton.isEnabled = true
        }else{
            grabarAudio?.record()
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleEverySecond), userInfo: nil, repeats: true)
            grabarButton.setTitle("DETENER", for: .normal)
            agregarButton.isEnabled = false
        }
    }

    @objc func updateDuracionLabel() {
        tiempoTranscurrido += 1
        tiempoG.text = tiempoFormateado(tiempoTranscurrido)
    }

    func tiempoFormateado(_ segundos: TimeInterval) -> String {
        let minutos = Int(segundos) / 60
        let segundosRestantes = Int(segundos) % 60
        return String(format: "%02d:%02d", minutos, segundosRestantes)
    }

    @objc func handleEverySecond(){
        //tiempoG.text = "Tiempo: \(String(format: "%.f", grabarAudio!.currentTime))s"
        updateDuracionLabel()
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData (contentsOf: audioURL!)! as Data
    
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController (animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = true
        volumeSlider.value = 0.5
        volumeSlider.addTarget(self, action: #selector(cambiarVolumen(_:)), for: .valueChanged)
    }
    @objc func cambiarVolumen(_ sender: UISlider) {
        if let reproducirAudio = reproducirAudio {
            reproducirAudio.volume = sender.value
        }
    }
    func configurarGrabacion(){
            do{
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default,options: [])
                try session.overrideOutputAudioPort(.speaker)
                try session.setActive(true)
                
                let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let pathComponents = [basePath,"audio.m4a"]
                audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
                
                print("***************")
                print(audioURL!)
                print("***************")
                
                var settings:[String:AnyObject] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
                settings[AVSampleRateKey] = 44100.0 as AnyObject?
                settings[AVNumberOfChannelsKey] = 2 as AnyObject?
                
                grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
                grabarAudio!.prepareToRecord()
            }catch let error as NSError{
                print(error)
            }
        }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
