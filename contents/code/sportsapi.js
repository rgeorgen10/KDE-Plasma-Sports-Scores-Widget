// Sports API Handler
// This file handles fetching data from sports APIs

.pragma library

var API_BASE_URL = "https://site.api.espn.com/apis/site/v2/sports"
var STANDINGS_BASE_URL = "https://site.api.espn.com/apis/v2/sports"

// Fetch scores for a league on a specific date (yyyymmdd string)
function fetchScoresForDate(league, dateStr, callback) {
    var sport = getSportPath(league)
    var url = API_BASE_URL + "/" + sport + "/scoreboard?dates=" + dateStr

    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    callback(parseScores(data, league))
                } catch (e) {
                    callback({error: "Failed to parse data: " + e})
                }
            } else {
                callback({error: "HTTP " + xhr.status})
            }
        }
    }
    xhr.open("GET", url)
    xhr.send()
}

// Legacy wrapper kept for any callers that still use it
function fetchScores(league, callback) {
    var sport = getSportPath(league)
    var url = API_BASE_URL + "/" + sport + "/scoreboard"

    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    callback(parseScores(data, league))
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

// Fetch standings for a league
function fetchStandings(league, callback) {
    var sport = getSportPath(league)
    var url = STANDINGS_BASE_URL + "/" + sport + "/standings"

    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    callback(parseStandings(data, league))
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

// Get sport path for API
function getSportPath(league) {
    switch(league) {
        case "nhl": return "hockey/nhl"
        case "nba": return "basketball/nba"
        case "nfl": return "football/nfl"
        case "mlb": return "baseball/mlb"
        default:    return "hockey/nhl"
    }
}

// Parse scores/schedule data (same ESPN endpoint covers both)
function parseScores(data, league) {
    var games = []

    if (!data.events) return {games: games}

    for (var i = 0; i < data.events.length; i++) {
        var event = data.events[i]
        var competition = event.competitions[0]
        var competitors = competition.competitors

        var homeTeam = null, awayTeam = null
        var homeScore = null, awayScore = null
        var homeLogo = null, awayLogo = null

        for (var j = 0; j < competitors.length; j++) {
            var c = competitors[j]
            if (c.homeAway === "home") {
                homeTeam  = c.team.shortDisplayName || c.team.displayName
                homeScore = c.score
                homeLogo  = c.team.logo || null
            } else {
                awayTeam  = c.team.shortDisplayName || c.team.displayName
                awayScore = c.score
                awayLogo  = c.team.logo || null
            }
        }

        var status = event.status.type.shortDetail || event.status.type.detail
        var isLive  = event.status.type.state === "in"

        var dateStr = event.date
        var dateObj = new Date(dateStr)
        var dateFormatted = dateObj.toLocaleDateString()
        var timeFormatted = dateObj.toLocaleTimeString([], {hour: "2-digit", minute: "2-digit"})
        var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var dayOfWeek = days[dateObj.getDay()]

        games.push({
            homeTeam:  homeTeam,
            awayTeam:  awayTeam,
            homeScore: homeScore,
            awayScore: awayScore,
            homeLogo:  homeLogo,
            awayLogo:  awayLogo,
            status:    status,
            isLive:    isLive,
            date:      dateFormatted,
            time:      timeFormatted,
            dayOfWeek: dayOfWeek
        })
    }

    return {games: games}
}

// Parse standings data
function parseStandings(data, league) {
    var teams = []

    if (!data.children || data.children.length === 0) return {teams: teams}

    var allEntries = []

    for (var c = 0; c < data.children.length; c++) {
        var conference = data.children[c]
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
            for (var e2 = 0; e2 < conference.standings.entries.length; e2++) {
                allEntries.push(conference.standings.entries[e2])
            }
        }
    }

    var isNHL = league === "nhl"

    allEntries.sort(function(a, b) {
        if (isNHL) {
            var aPts = 0, bPts = 0
            for (var i = 0; i < a.stats.length; i++) {
                if (a.stats[i].name === "points" || a.stats[i].abbreviation === "PTS" || a.stats[i].abbreviation === "P") aPts = a.stats[i].value
            }
            for (var i2 = 0; i2 < b.stats.length; i2++) {
                if (b.stats[i2].name === "points" || b.stats[i2].abbreviation === "PTS" || b.stats[i2].abbreviation === "P") bPts = b.stats[i2].value
            }
            return bPts - aPts
        } else {
            var aWins = 0, bWins = 0
            for (var i3 = 0; i3 < a.stats.length; i3++) {
                if (a.stats[i3].name === "wins" || a.stats[i3].abbreviation === "W") aWins = a.stats[i3].value
            }
            for (var i4 = 0; i4 < b.stats.length; i4++) {
                if (b.stats[i4].name === "wins" || b.stats[i4].abbreviation === "W") bWins = b.stats[i4].value
            }
            return bWins - aWins
        }
    })

    for (var i = 0; i < allEntries.length; i++) {
        var entry = allEntries[i]
        var team  = entry.team.shortDisplayName || entry.team.displayName
        var logo  = entry.team.logos && entry.team.logos.length > 0
                        ? entry.team.logos[0].href
                        : (entry.team.logo || null)

        var stats = entry.stats
        var wins = 0, losses = 0, otLosses = 0, points = 0

        for (var j = 0; j < stats.length; j++) {
            var s = stats[j]
            if (s.name === "wins"     || s.abbreviation === "W")                          wins     = s.value
            if (s.name === "losses"   || s.abbreviation === "L")                          losses   = s.value
            if (s.name === "otLosses" || s.abbreviation === "OTL" || s.abbreviation === "OT") otLosses = s.value
            if (s.name === "points"   || s.abbreviation === "PTS" || s.abbreviation === "P")  points   = s.value
        }

        teams.push({
            rank:     i + 1,
            team:     team,
            logo:     logo,
            wins:     wins,
            losses:   losses,
            otLosses: otLosses,
            points:   points
        })
    }

    return {teams: teams, league: league}
}
