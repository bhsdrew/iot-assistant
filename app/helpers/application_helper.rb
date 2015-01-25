
module ApplicationHelper
  # Private: Cross-platform `which` command.
  # Source: http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
  #
  # Example -
  #   which('ruby') #=> /usr/bin/ruby
  #
  # Returns the path of the executable.
  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = "#{path}/#{cmd}#{ext}"
        return exe if File.executable? exe
      }
    end
    return nil
  end

  def fortune
    if f = which("fortune")
      ascii(%x[#{f} -n 100 -s]).gsub("\t", "")
    end
  end

  def greeting
    @greetings ||= ['Aloha', 'Bonjour', 'Guten-Tag', 'Hello', 'Oh Hai', 'Hallo', 'Hola', 'Hej', 'Hey', 'Hi', 'Salut', 'Zdravstvuyte']
    @greetings[Random.rand(@greetings.length)]
  end

  def ascii(str)
    # See String#encode
    encoding_options = {
      :invalid           => :replace,  # Replace invalid byte sequences
      :undef             => :replace,  # Replace anything not defined in ASCII
      :replace           => '',        # Replace above with this
      :universal_newline => true       # Always break lines with \n
    }
    str.encode Encoding.find('ASCII'), encoding_options
  end

  def wrap(format, str)
    format + " " + word_wrap(str, :line_width => 32).split("\n").join("\n#{format} ")
  end

  # Public: Fetch recent stories from The Times
  def recent_stories(count=3)
    response = Typhoeus::Request.get("http://www.thetimes.co.uk/tto/news/rss")
    if response.success?
      doc = Nokogiri::XML.parse(response.body)
      doc.css("item").map{|story| story.at_css("title").text}.slice(0,count)
    else
      []
    end
  end

  # Pass in a string and it sortens it to the desired number of words with the possibility to define custom ending.
  def truncate_words(text, length = 3, end_string = ' ...')
    return if text == nil
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end


  def image
    Base64.encode64(File.binread("image.png"))
  end

  def base64_image
    img = rvg.draw
    bits = []
    width = img.columns
    height = img.rows
    img.each_pixel { |pixel, _, _| bits << (pixel.red > 0 ? 0 : 1) }
    bytes = []; bits.each_slice(8) { |s| bytes << ("0" + s.join).to_i(2) }
    str = [width,height].pack("SS")
    str += bytes.pack("C*")
    Base64.encode64(str)
  end

  def full_width_image(&block)
    RVG::dpi = 100
    RVG.new(3.84.in, 3.84.in).viewbox(0,0,384,384, &block)
  end

  def rvg
    x = full_width_image do |c|
      c.background_fill = 'white'

      c.use(gfr_logo)

      #c.text(380, 380, Time.now.to_s).styles(text_anchor: "end", font_family: "times", font_size: 18)
    end
    flip(x)
  end

  def flip(img)
    img.rotate(180).translate(-384, -384)
  end

  def gfr_logo
    RVG::Group.new do |c|
      c.g.translate(215, 142) do |body|
        body.ellipse(140, 140).styles(fill: 'white', stroke: 'black', stroke_width: 3)
        # body.text(10, 30) do |title|
        #   title.tspan("free").styles(font_size: 120, text_anchor: 'middle',
        #                              font_family: 'times', font_style: 'italic', fill: 'black')
        # end
        # body.text(50, 65) do |title|
        #   title.tspan("RANGE").styles(font_size: 40, text_anchor: 'middle',
        #                               font_family: 'times', font_style: 'italic', fill: 'black')
        # end
      end

      c.g.translate(57, 120) do |body|
        body.ellipse(55, 55).styles(fill: 'white', stroke: 'black', stroke_width: 3)
        # body.text(0, 18) do |title|
        #   title.tspan("Go").styles(font_size: 52, text_anchor: 'middle',
        #                            font_family: 'times', font_style: 'italic', fill: 'black')
        # end
      end
    end
  end
end
