// Sports API Handler
// This file handles fetching data from sports APIs

.pragma library

// API configuration
var API_BASE_URL = "https://site.api.espn.com/apis/site/v2/sports"
var STANDINGS_BASE_URL = "https://site.api.espn.com/apis/v2/sports"

// Fetch scores for a league
function fetchScores(league, callback) {
    var url = getScoresUrl(league)
    
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    var formattedData = parseScores(data, league)
                    callback(formattedData)
                } catch (e) {
                    callback({error: "Failed to parse scores data: " + e})
                }
            } else {
                callback({error: "Failed to fetch scores: HTTP " + xhr.status})
            }
        }
    }
    
    xhr.open("GET", url)
    xhr.send()
}

// Fetch schedule for a league
function fetchSchedule(league, callback) {
    var url = getScheduleUrl(league)
    
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    var formattedData = parseSchedule(data, league)
                    callback(formattedData)
                } catch (e) {
                    callback({error: "Failed to parse schedule data: " + e})
                }
            } else {
                callback({error: "Failed to fetch schedule: HTTP " + xhr.status})
            }
        }
    }
    
    xhr.open("GET", url)
    xhr.send()
}

// Fetch standings for a league
function fetchStandings(league, callback) {
    var url = getStandingsUrl(league)
    
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    var formattedData = parseStandings(data, league)
                    callback(formattedData)
                } catch (e) {
                    callback({error: "Failed to parse standings data: " + e})
                }
            } else {
                callback({error: "Failed to fetch standings: HTTP " + xhr.status})
            }
        }
    }
    
    xhr.open("GET", url)
    xhr.send()
}

// Get scores URL for a league
function getScoresUrl(league) {
    var sport = getSportPath(league)
    return API_BASE_URL + "/" + sport + "/scoreboard"
}

// Get schedule URL for a league
function getScheduleUrl(league) {
    var sport = getSportPath(league)
    return API_BASE_URL + "/" + sport + "/scoreboard"
}

// Get standings URL for a league
function getStandingsUrl(league) {
    var sport = getSportPath(league)
    return STANDINGS_BASE_URL + "/" + sport + "/standings"
}

// Get sport path for API
function getSportPath(league) {
    switch(league) {
        case "nhl": return "hockey/nhl"
        case "nba": return "basketball/nba"
        case "nfl": return "football/nfl"
        case "mlb": return "baseball/mlb"
        default: return "hockey/nhl"
    }
}

// Parse scores data
function parseScores(data, league) {
    var games = []
    
    if (!data.events) {
        return {games: games}
    }
    
    for (var i = 0; i < data.events.length; i++) {
        var event = data.events[i]
        var competition = event.competitions[0]
        var competitors = competition.competitors
        
        var homeTeam = null
        var awayTeam = null
        var homeScore = null
        var awayScore = null
        
        var homeLogo = null
        var awayLogo = null

        for (var j = 0; j < competitors.length; j++) {
            if (competitors[j].homeAway === "home") {
                homeTeam = competitors[j].team.shortDisplayName || competitors[j].team.displayName
                homeScore = competitors[j].score
                homeLogo = competitors[j].team.logo || null
            } else {
                awayTeam = competitors[j].team.shortDisplayName || competitors[j].team.displayName
                awayScore = competitors[j].score
                awayLogo = competitors[j].team.logo || null
            }
        }
        
        var status = event.status.type.shortDetail || event.status.type.detail
        var isLive = event.status.type.state === "in"
        
        games.push({
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            homeScore: homeScore,
            awayScore: awayScore,
            homeLogo: homeLogo,
            awayLogo: awayLogo,
            status: status,
            isLive: isLive
        })
    }
    
    return {games: games}
}

// Parse schedule data
function parseSchedule(data, league) {
    var games = []
    
    if (!data.events) {
        return {games: games}
    }
    
    for (var i = 0; i < data.events.length; i++) {
        var event = data.events[i]
        var competition = event.competitions[0]
        var competitors = competition.competitors
        
        var homeTeam = null
        var awayTeam = null
        
        for (var j = 0; j < competitors.length; j++) {
            if (competitors[j].homeAway === "home") {
                homeTeam = competitors[j].team.shortDisplayName || competitors[j].team.displayName
            } else {
                awayTeam = competitors[j].team.shortDisplayName || competitors[j].team.displayName
            }
        }
        
        var dateStr = event.date
        var date = new Date(dateStr)
        var dateFormatted = date.toLocaleDateString()
        var timeFormatted = date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
        
        games.push({
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            date: dateFormatted,
            time: timeFormatted
        })
    }
    
    return {games: games}
}

// Parse standings data
// ESPN v2 standings structure:
//   data.children[] = conferences
//     .children[] = divisions  (some leagues skip this level)
//     .standings.entries[] = teams
function parseStandings(data, league) {
    var teams = []

    if (!data.children || data.children.length === 0) {
        return {teams: teams}
    }

    // Collect all entries from all conferences (and divisions within them)
    var allEntries = []

    for (var c = 0; c < data.children.length; c++) {
        var conference = data.children[c]

        // Some leagues nest divisions inside conferences
        if (conference.children && conference.children.length > 0) {
            for (var d = 0; d < conference.children.length; d++) {
                var division = conference.children[d]
                if (division.standings && division.standings.entries) {
                    for (var e = 0; e < division.standings.entries.length; e++) {
                        allEntries.push(division.standings.entries[e])
                    }
                }
            }
        } else if (conference.standings && conference.standings.entries) {
            for (var e = 0; e < conference.standings.entries.length; e++) {
                allEntries.push(conference.standings.entries[e])
            }
        }
    }

    // Sort by points (NHL) or wins descending
    var isNHL = league === "nhl"

    allEntries.sort(function(a, b) {
        if (isNHL) {
            var aPts = 0, bPts = 0
            for (var i = 0; i < a.stats.length; i++) {
                if (a.stats[i].name === "points" || a.stats[i].abbreviation === "PTS" || a.stats[i].abbreviation === "P") aPts = a.stats[i].value
            }
            for (var i = 0; i < b.stats.length; i++) {
                if (b.stats[i].name === "points" || b.stats[i].abbreviation === "PTS" || b.stats[i].abbreviation === "P") bPts = b.stats[i].value
            }
            return bPts - aPts
        } else {
            var aWins = 0, bWins = 0
            for (var i = 0; i < a.stats.length; i++) {
                if (a.stats[i].name === "wins" || a.stats[i].abbreviation === "W") aWins = a.stats[i].value
            }
            for (var i = 0; i < b.stats.length; i++) {
                if (b.stats[i].name === "wins" || b.stats[i].abbreviation === "W") bWins = b.stats[i].value
            }
            return bWins - aWins
        }
    })

    for (var i = 0; i < allEntries.length; i++) {
        var entry = allEntries[i]
        var team = entry.team.shortDisplayName || entry.team.displayName
        var logo = entry.team.logos && entry.team.logos.length > 0 ? entry.team.logos[0].href : null
        if (!logo && entry.team.logo) logo = entry.team.logo

        var stats = entry.stats
        var wins = 0
        var losses = 0
        var otLosses = 0
        var points = 0

        for (var j = 0; j < stats.length; j++) {
            var s = stats[j]
            if (s.name === "wins" || s.abbreviation === "W") wins = s.value
            if (s.name === "losses" || s.abbreviation === "L") losses = s.value
            if (s.name === "otLosses" || s.abbreviation === "OTL" || s.abbreviation === "OT") otLosses = s.value
            if (s.name === "points" || s.abbreviation === "PTS" || s.abbreviation === "P") points = s.value
        }

        teams.push({
            rank: i + 1,
            team: team,
            logo: logo,
            wins: wins,
            losses: losses,
            otLosses: otLosses,
            points: points
        })
    }

    return {teams: teams, league: league}
}
