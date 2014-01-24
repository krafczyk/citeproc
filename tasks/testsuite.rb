require 'rake'
require 'json'

module CSL
  module TestSuite

    NON_STANDARD = %{
      quotes_PunctuationWithInnerQuote
      substitute_SuppressOrdinaryVariable
    }

    module_function

    def load(file)
      JSON.parse(File.open(file, 'r:UTF-8').read)
    end

    def tags_for(json, feature, name)
      tags = []

      tags << "@#{json['mode']}"
      tags << "@#{feature}"

      if NON_STANDARD.include? "#{feature}_#{name}"
        tags << '@non-standard'
      end

      tags
    end

  end
end

namespace :test do

  desc 'Fetch the citeproc-test repository and generate the JSON test files'
  task :init => [:clean] do
    system "hg clone https://bitbucket.org/bdarcus/citeproc-test test"
    system "cd test && python2.7 processor.py --grind"
  end

  desc 'Remove the citeproc-test repository'
  task :clean do
    system "rm -rf test"
  end

  desc 'Delete all generated CSL feature tests'
  task :clear do
    Dir['features/**/*'].sort.reverse.each do |path|
      unless path =~ /features\/(support|step_definitions)/
        if File.directory?(path)
          system "rmdir #{path}"
        else
          system "rm #{path}"
        end
      end
    end
  end

  task :convert => [:clear] do
    features = Dir['test/processor-tests/machines/*.json'].group_by { |path|
      File.basename(path).split(/_/, 2)[0]
    }

    features.each_key do |feature|
      system "mkdir features/#{feature}"

      features[feature].each do |file|
        json, name = CSL::TestSuite.load(file), File.basename(file, '.json').split(/_/, 2)[-1]

        tags = CSL::TestSuite.tags_for(json, feature, name)

        # apply some filters
        json['result'].gsub!('&#38;', '&amp;')

        if json['mode'] == 'bibliography' && !json['bibsection'] && !json['bibentries']
          File.open("features/#{feature}/#{name}.feature", 'w:UTF-8') do |out|
            out << "Feature: #{feature}\n"
            out << "  As a CSL cite processor hacker\n"
            out << "  I want the test #{File.basename(file, '.json')} to pass\n\n"
            out << "  " << tags.join(' ') << "\n"
            out << "  Scenario: #{name.gsub(/([[:lower:]])([[:upper:]])/, '\1 \2')}\n"

            out << "    Given the following style:\n"
            out << "    \"\"\"\n"

            json['csl'].each_line do |line|
              out << '    ' << line
            end
            out << "\n    \"\"\"\n"

            out << "    And the following input:\n"
            out << "    \"\"\"\n"
            out << "    " << JSON.dump(json['input']) << "\n"
            out << "    \"\"\"\n"

            out << "    When I render the bibliography\n"

            out << "    Then the result should be:\n"
            out << "    \"\"\"\n"
            json['result'].each_line do |line|
              out << '    ' << line
            end
            out << "\n    \"\"\"\n"
          end
        end
      end
    end
  end


end
