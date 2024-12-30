/*
 *  RadioPlayer.swift
 *
 *  Created by Ilia Chirkunov <xc@yar.net> on 10.01.2021.
 */

import MediaPlayer
import AVKit

class RadioPlayer: NSObject, AVPlayerItemMetadataOutputPushDelegate {
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    var defaultArtwork: UIImage?
    var metadataArtwork: UIImage?
    var currentMetadata: Array<String> = []
    var streamTitle: String?
    var streamUrl: String?
    var ignoreIcy: Bool = false
    var itunesArtworkParser: Bool = false
    var interruptionObserverAdded: Bool = false

    func setMediaItem() {
        guard let streamTitle = streamTitle else {
            print("Error: Stream title is nil")
            return
        }

        guard let streamUrl = streamUrl, let url = URL(string: streamUrl) else {
            print("Error: Invalid or nil stream URL")
            return
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: streamTitle]
        defaultArtwork = nil
        metadataArtwork = nil
        playerItem = AVPlayerItem(url: url)

        if player == nil {
            // Create an AVPlayer
            player = AVPlayer(playerItem: playerItem)
            player.automaticallyWaitsToMinimizeStalling = true
            player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
            runInBackground()
        } else {
            player.replaceCurrentItem(with: playerItem)
        }

        // Set interruption handler
        if !interruptionObserverAdded {
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlay), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            interruptionObserverAdded = true
        }

        // Set metadata handler
        let metaOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metaOutput.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(metaOutput)
    }

    func setMetadata(_ newMetadata: Array<String>) {
        // Check for duplicate metadata
        if currentMetadata == newMetadata { return }
        currentMetadata = newMetadata

        // Prepare metadata string for display
        var metadata = newMetadata.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        // Parse artwork from iTunes
        if itunesArtworkParser, metadata.count > 2, metadata[2].isEmpty {
            metadata[2] = parseArtworkFromItunes(metadata[0], metadata[1])
        }

        // Update the now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: metadata[safe: 0] ?? "",
            MPMediaItemPropertyTitle: metadata[safe: 1] ?? ""
        ]

        // Download and set album cover
        metadataArtwork = downloadImage(metadata[safe: 2] ?? "")
        setArtwork(metadataArtwork ?? defaultArtwork)

        // Send metadata to client
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "metadata"), object: nil, userInfo: ["metadata": metadata])
    }

    @objc func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Handle interruption start
            print("Audio interruption began")
        } else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                play()
            }
        }
    }

    @objc func playerItemFailedToPlay(_ notification: Notification) {
        print("Error: Player item failed to play")
        // TODO: Attempt to reconnect or provide feedback to the user
    }

    func setArtwork(_ image: UIImage?) {
        guard let image = image else { return }

        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        MPNowPlayingInfoCenter.default().nowPlayingInfo?.updateValue(artwork, forKey: MPMediaItemPropertyArtwork)
    }

    func play() {
        if player.currentItem == nil {
            player.replaceCurrentItem(with: playerItem)
        } else if player.currentItem?.isPlaybackBufferEmpty == true || player.currentItem?.status == .failed {
            setMediaItem()
        }

        player.play()
    }

    func stop() {
        guard let player = player else {
            print("Warning: Attempted to stop playback, but player is nil.")
            return
        }
        
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    func pause() {
        player.pause()
    }

    func runInBackground() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Error: Failed to configure AVAudioSession - \(error.localizedDescription)")
        }

        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play button
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.play()
            return .success
        }

        // Pause button
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return .success
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let observedKeyPath = keyPath, object is AVPlayer, observedKeyPath == #keyPath(AVPlayer.timeControlStatus) else {
            return
        }

        if let statusAsNumber = change?[.newKey] as? NSNumber {
            let status = AVPlayer.TimeControlStatus(rawValue: statusAsNumber.intValue)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "state"), object: nil, userInfo: ["state": status != .paused])
        }
    }

    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        if ignoreIcy { return }

        guard let rawMetadata = groups.first?.items,
              let title = rawMetadata.first?.stringValue else { return }

        var result = title.components(separatedBy: " - ")
        if result.count == 1 { result.append("") }

        if rawMetadata.count > 1, let artworkUrl = rawMetadata[1].stringValue {
            result.append(artworkUrl)
        } else {
            result.append("")
        }

        setMetadata(result)
    }

    func downloadImage(_ value: String) -> UIImage? {
        guard let url = URL(string: value) else { return nil }

        var result: UIImage?
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                result = UIImage(data: data)
            }
            semaphore.signal()
        }
        task.resume()

        semaphore.wait()
        return result
    }

    func parseArtworkFromItunes(_ artist: String, _ track: String) -> String {
        var artwork = ""

        guard let term = "\(artist) - \(track)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(term)&limit=1") else { return artwork }

        var jsonData: Data?
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            jsonData = data
            semaphore.signal()
        }
        task.resume()

        semaphore.wait()

        guard let data = jsonData,
              let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let results = dict["results"] as? [[String: Any]],
              let artworkUrl = results.first?["artworkUrl30"] as? String else { return artwork }

        artwork = artworkUrl.replacingOccurrences(of: "30x30bb", with: "500x500bb")
        return artwork
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
