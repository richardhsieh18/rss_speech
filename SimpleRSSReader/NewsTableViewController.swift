//
//  NewsTableViewController.swift
//  SimpleRSSReader
//
//  Created by Simon Ng on 26/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class NewsTableViewController: UITableViewController {

    enum CellState {
        case expanded
        case collapsed
    }
    
    private var rssItems:[(title: String, description: String, pubDate: String)]?
    private var cellStates: [CellState]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 155.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do{
                try AVAudioSession.sharedInstance().setActive(true)
            }catch{
                
            }
        }catch{
            
        }

        let feedParser = FeedParser()
        feedParser.parseFeed(feedUrl: "http://www.chinatimes.com/rss/realtimenews.xml", completionHandler: {
            (rssItems: [(title: String, description: String, pubDate: String)]) -> Void in
            
            self.rssItems = rssItems
            self.cellStates = [CellState](repeating: .collapsed, count: rssItems.count)
            
            OperationQueue.main.addOperation({ () -> Void in
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        guard let rssItems = rssItems else {
            return 0
        }
        
        return rssItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        // Configure the cell...
        if let item = rssItems?[indexPath.row] {
            cell.titleLabel.text = item.title
            cell.dateLabel.text = item.pubDate
            //一定要加在這才OK..很奇怪
            cell.descriptionLabel.text = item.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            
            if let cellStates = cellStates {
                cell.descriptionLabel.numberOfLines = (cellStates[indexPath.row] == .expanded) ? 0 : 4
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! NewsTableViewCell
        tableView.beginUpdates()
        cell.descriptionLabel.numberOfLines = (cell.descriptionLabel.numberOfLines == 0) ? 4 : 0
        cellStates?[indexPath.row] = (cell.descriptionLabel.numberOfLines == 0) ? .expanded : .collapsed
        tableView.endUpdates()
    }
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var index:IndexPath!
    
    @IBAction func textToSpeechButton(_ sender: UIButton) {
        //這個方法太讚了
        if let cell = sender.superview?.superview?.superview as? NewsTableViewCell {
            //let indexPath = tableView.indexPath(for: cell)
            myUtterance = AVSpeechUtterance(string: cell.titleLabel.text! + cell.descriptionLabel.text!)
        }
        
        myUtterance.rate = 0.4
        myUtterance.pitchMultiplier = 1.2
        myUtterance.postUtteranceDelay = 0.1
        myUtterance.volume = 1
        myUtterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        synth.speak(myUtterance)
    }
    
    
}
