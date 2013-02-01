require 'isis/plugins/base'
require 'httparty'

class Isis::Plugin::Isepta < Isis::Plugin::Base
  # TODO:
  # always return the "now" schedule

  REGEX = /^\W*\@isepta\b/i
  def respond_to_msg?(msg, speaker)
    @msg = msg
    REGEX =~ @msg
  end

  def response
    @msg = @msg.downcase
    @msg = @msg.gsub(REGEX, '')
    from, to = @msg.split(' to ').map{|s| find_station(s)}
    response = HTTParty.get("http://isepta-api-v2.herokuapp.com/trains.json?to=#{to}&from=#{from}&day=#{ScheduleType.current_type}")

    if response.to_a.size > 0
      train_view = HTTParty.get('http://www3.septa.org/hackathon/TrainView/', :options => { :headers => { 'ContentType' => 'application/json' } })
      trains = response.map{|t| {departs_at: Time.strptime(t['departs_at'],"%H:%M:%S"), number: t['number']} rescue nil}.compact
      trains = trains.select{|t| t[:departs_at] > (Time.now)}[0..2]

      times = trains.map do |train|
        tv_train = train_view.select{|t| t['trainno'] == train[:number]}.first
        minutes_late = tv_train && tv_train['late']
        minutes_late = " (#{minutes_late})" if minutes_late
        train[:departs_at].strftime("%-I:%M%P#{minutes_late}")
      end.join(", ")
      "#{STATION_NAMES.invert[from]} to #{STATION_NAMES.invert[to]} departing at: #{times}"
    else
      "Whoops! Couldn't find trains for '#{@msg}'"
    end
  end

  def find_station(param)
    param = param.strip.upcase
    return param if STATION_NAMES.values.include?(param)
    station_name = STATION_NAMES.keys.select{|name| name.match(/#{param}/i)}.first
    return STATION_NAMES[station_name] rescue 'none'
  end
end

module ScheduleType
  def self.current_type
    date = Time.now.to_date
    [0, 6].include?(date.wday) ? date.strftime("%a").downcase : "wk"
  end
end

STATION_NAMES = {
"Eastwick" => "EWCK",
"Trenton" => "TR",
"Levittown" => "LVTN",
"Cynwyd" => "CY",
"Sharon Hill" => "SHAR",
"Elkins Park" => "ELPK",
"Wissahickon T. C." => "WSHN",
"Colmar" => "COLM",
"Exton" => "EXTN",
"Warminster" => "WM",
"Oreland" => "ORLD",
"Hatboro" => "HATB",
"Fort Washington" => "FTWA",
"Meadowbrook" => "MDBK",
"Willow Grove" => "WLGR",
"Crestmont" => "CRST",
"Roslyn" => "ROSL",
"Ardsley" => "ARDS",
"Noble" => "NOBL",
"Rydal" => "RYDL",
"Whitford" => "WHIT",
"North Hills" => "NOHL",
"Folcroft" => "FOLC",
"Glenolden" => "GLNO",
"Norwood" => "NORW",
"Prospect Park-Moore" => "PROS",
"Ridley Park" => "RDLY",
"Crum Lynne" => "CRML",
"Eddystone" => "EDST",
"Chester" => "CHTC",
"Highland Avenue" => "HIAV",
"North Broad" => "NBRD",
"Darby" => "DARB",
"Curtis Park" => "CRTS",
"Newark" => "NK",
"Fern Rock T.C." => "FRTC",
"Berwyn" => "BERW",
"Ardmore" => "ARTC",
"Bethayres" => "BTHR",
"Philmont" => "PHLM",
"Forest Hills" => "FORH",
"Somerton" => "SOMT",
"Trevose" => "TREV",
"Neshaminy Falls" => "NESHAMINY",
"Langhorne" => "LANG",
"Woodbourne" => "WDBR",
"Yardley" => "YDLY",
"Elwyn" => "EL",
"Media" => "ME",
"Primos" => "PRIM",
"Clifton-Aldan" => "CFTN",
"Gladstone" => "GLAD",
"Lansdowne" => "LNSD",
"Fernwood-Yeadon" => "FERN",
"Downingtown" => "DOWN",
"Fortuna" => "FRTU",
"Melrose Park" => "MLPK",
"Jenkintown-Wyncote" => "KI",
"Ambler" => "AMBL",
"Penllyn" => "PNLN",
"Gwynedd Valley" => "GWVL",
"North Wales" => "NWST",
"Pennbrook" => "PBST",
"Doylestown" => "DY",
"Devon" => "DEVN",
"Wynnewood" => "WYNW",
"Airport Terminal A East/West" => "A",
"Thorndale" => "TN",
"Link Belt" => "LINK",
"Chalfont" => "CHAL",
"New Britain" => "NWBT",
"Del Val College" => "DLVL",
"Marcus Hook" => "MH",
"Claymont" => "CLAY",
"Daylesford" => "DALF",
"Paoli" => "PA",
"Haverford" => "HAVE",
"Strafford" => "STFD",
"Wayne" => "WAYN",
"St. Davids" => "STDA",
"Radnor" => "RADN",
"Churchmans Crossing" => "CHCR",
"Villanova" => "VILA",
"Rosemont" => "ROSE",
"Bryn Mawr" => "BM",
"Lansdale" => "LA",
"Narberth" => "NRST",
"Merion" => "MERI",
"Overbrook" => "OVBK",
"Allegheny" => "ALGY",
"East Falls" => "EFLS",
"Manayunk" => "MANY",
"Ivy Ridge" => "IVYR",
"Miquon" => "MIQN",
"Spring Mill" => "SPGM",
"Conshohocken" => "CONS",
"Norristown T. C." => "NTC",
"Main Street" => "MNST",
"Elm Street, Norristown" => "NT",
"Wayne Junction" => "WJ",
"Bristol" => "BRST",
"Croydon" => "CROY",
"Eddington" => "EDGT",
"Airport Terminal B" => "AIRB",
"Secane" => "SECA",
"Bala" => "BALA",
"Wynnefield Avenue" => "WYNF",
"Airport Terminal C and D" => "AIRC",
"Tacony" => "TCNY",
"Bridesburg" => "BRDB",
"Wister" => "WIST",
"Germantown" => "GERM",
"Washington Lane" => "WALA",
"Stenton" => "STNT",
"Sedgwick" => "SGWK",
"Mount Airy" => "MTAI",
"Wyndmoor" => "WYND",
"Gravers" => "GRAV",
"Airport Terminal E" => "AIRE",
"Chestnut Hill East" => "CE",
"Chestnut Hill West" => "CW",
"Highland" => "HIGH",
"St. Martins" => "STMR",
"Allen Lane" => "ALLA",
"Carpenter" => "CARP",
"Upsal" => "UPSL",
"Tulpehocken" => "TULP",
"Chelten Avenue" => "CHEL",
"Queen Lane" => "QUEN",
"North Philadelphia" => "NPHR7",
"30th Street Station" => "30ST",
"Moylan-Rose Valley" => "MOYL",
"Wallingford" => "WALF",
"Swarthmore" => "SWAR",
"Morton-Rutledge" => "MORT",
"Angora" => "AGRA",
"49th Street" => "49TH",
"Suburban Station" => "SS",
"Market East Station" => "EM",
"Temple University" => "TU",
"Olney" => "OLNY",
"Lawndale" => "LAWN",
"West Trenton, NJ" => "WT",
"Cheltenham" => "CHHM",
"Ryers" => "RYER",
"Fox Chase" => "FC",
"Glenside" => "GS",
"Malvern" => "MALV",
"Wilmington" => "WG",
"University City" => "UC",
"Cornwells Heights" => "CORN",
"Torresdale" => "TORR",
"Holmesburg Junction" => "HOLM"}

