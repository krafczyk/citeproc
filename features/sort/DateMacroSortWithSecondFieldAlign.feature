Feature: sort
  As a CSL cite processor hacker
  I want the test sort_DateMacroSortWithSecondFieldAlign to pass

  @bibliography @sort
  Scenario: Date Macro Sort With Second Field Align
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
      <macro name="issued">
        <date variable="issued" form="text" date-parts="year" prefix="(" suffix=")"/>
      </macro>
      <citation>
        <layout>
          <names variable="author">
            <name/>
          </names>
        </layout>
      </citation>
      <bibliography et-al-min="7" et-al-use-first="1" entry-spacing="0" second-field-align="flush">
        <sort>
          <key macro="issued"/>
        </sort> 
        <layout suffix=".">
          <names variable="author"/>
          <group delimiter=" ">
            <group delimiter=", ">
              <text variable="title"/>
            </group>
            <text macro="issued"/>
          </group>
        </layout>
      </bibliography>
    </style>
    """
    And the following input:
    """
    [{"author":[{"family":"Doe","given":"John"}],"id":"ITEM-1","issued":{"date-parts":[["1965","6","1"]]},"title":"His Anonymous Life","type":"book"}]
    """
    When I render the entire bibliography
    Then the bibliography should be:
    """
    <div class="csl-bib-body">
      <div class="csl-entry">
        <div class="csl-left-margin">John Doe</div><div class="csl-right-inline">His Anonymous Life (1965).</div>
      </div>
    </div>
    """