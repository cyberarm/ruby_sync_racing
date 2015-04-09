# Makes code nice and small
# BROKEN

class Minify
  # @
  def initialize(files = [])
    raise "Did not receive an Array!" unless files.is_a?(Array)

    @end_string = ""
    @files = files
    @mini_files = {}

    files.each do |file|
      if file.end_with?(".rb")
        file_contents = File.open(file)
        file_contents.each_line do |line|
          if line.start_with?("#") or line.strip.length == 0
            # Skip!
          else
            @end_string << "#{line.strip}; " unless file_contents.eof
            @end_string << "#{line.strip} " if file_contents.eof
          end
        end

        @mini_files["#{file}"] = @end_string
        @end_string = ""
      end
    end

    write_mini_files
  end

  def write_mini_files
    if @mini_files.count >= 1
      unless File.exist?("mini") && File.directory?("mini")
        Dir.mkdir "mini"
      else
        puts "Directoy 'mini' in #{Dir.pwd} exists!".upcase
        puts "PRESS ANY KEY TO WRITE TO DIRECTORY\nOR PRESS CTRL-C TO CANCEL"
        $stdin.gets
      end

      @mini_files.each do |key, value|
        directories = key.split("/")
        directories.delete(directories.last)
        File.open("mini/#{key}", "w") {|f| f.write value.to_s} unless directories
        p directories
        next unless directories

        directories.each_with_index do |dir, i|
          unless File.exist?("mini/#{directories[0..i].join('/')}") && File.directory?("mini/#{directories[0..i].join('/')}")
            Dir.mkdir "mini/#{directories[0..i].join('/')}"
          end
        end

        File.open("mini/#{key}", "w") {|f| f.write value.to_s} # Write file
      end
    end
  end
end
