//
//  PlaylistsController.swift
//  Muse
//
//  Created by Marco Albera on 26/07/2018.
//  Copyright © 2018 Edge Apps. All rights reserved.
//

import Cocoa

// MARK: NSTableViewDelegate

extension ViewController {
    
    /**
     Table cell generation
     1 field: result (playlist) name
     */
    func playlistsTableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else { return nil }
        
        if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ResultsTableCellView {
            // First table cell field: playlist name
            cell.textField?.stringValue = playlistsResults[row].name
            cell.textField?.textColor   = colors?.primary
            
            // Second table cell field: playlists item count
            cell.secondTextField?.stringValue = String(playlistsResults[row].count)
            cell.secondTextField?.textColor   = colors?.designatedSecondary
            
            return cell
        }
        
        return nil
    }
    
    func playlistsTableViewDoubleClicked(tableView: NSTableView) {
        guard   let helper = helper as? PlaylistablePlayerHelper,
                tableView.selectedRow >= 0 else { return }
        
        // Play the requested playlist using the specific player feature
        if helper is SpotifyHelper {
            helper.play(playlist: playlistsResults[tableView.selectedRow].id)
        } else if helper is iTunesHelper {
            helper.play(playlist: playlistsResults[tableView.selectedRow].name)
        }
        
        endSearch()
    }
}

// MARK: NSTableViewDataSource

extension ViewController {
    
    func playlistsNumberOfRows(in tableView: NSTableView) -> Int {
        return playlistsResults.count
    }
}

// MARK: Playlist related functions

extension ViewController {
    
    func searchPlaylist(_ text: String) {
        loadPlaylists(filtered: text)
    }
    
    func loadPlaylists(filtered byQuery: String = "") {
        if let helper = helper as? PlaylistablePlayerHelper {
            helper.playlists { [weak self] in
                if !byQuery.isEmpty {
                    self?.playlistsResults = $0.filter {
                        $0.name.localizedCaseInsensitiveContains(byQuery)
                    }
                } else {
                    self?.playlistsResults = $0
                }
                
                self?.resultsTableView?.reloadData(selectingFirst: true)
            }
        }
    }
    
    func startPlaylistsSearch() {
        guard helper is PlaylistablePlayerHelper else { return }
        
        // Switch results mode first
        resultsMode = .playlists
        
        // Reload data keeping selection
        resultsTableView?.reloadData(keepingSelection: true)
        
        // Preload the playlists
        loadPlaylists()
        
        startSearch()
    }
}
