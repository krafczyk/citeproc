Feature: name
  As a CSL cite processor hacker
  I want the test name_Asian to pass

  @citation @name
  Scenario: Asian
    Given the following style:
    """
    <style 
          xmlns="http://purl.org/net/xbiblio/csl"
          class="note"
          version="1.0">
      <info>
        <id />
        <title />
        <updated>2009-08-10T04:49:00+09:00</updated>
      </info>
      <citation>
        <layout>
          <names variable="author">
            <name />
          </names>
        </layout>
      </citation>
    </style>
    """
    And the following input:
    """
    [{"author":[{"family":"Miyamoto","given":"Musashi","static-ordering":true}],"id":"simple-sticky-name-1","issued":{"date-parts":[["1645","12","27"]]},"title":"A Book of Five Rings","type":"book"}]
    """
    When I cite all items
    Then the result should be:
    """
    Miyamoto Musashi
    """
