Feature: magic
  As a CSL cite processor hacker
  I want the test magic_SecondFieldAlign to pass

  @bibliography @magic @non-standard
  Scenario: Second Field Align
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
          <text value="hello" />
        </layout>
      </citation>
      <bibliography 
             second-field-align="flush">
        <layout>
          <text prefix="[" suffix="]" variable="citation-number" />
          <group delimiter=" ">
            <group delimiter=", ">
              <names variable="author">
                <name />
              </names>
              <text variable="title" />
            </group>
            <date prefix="(" suffix=")" variable="issued">
              <date-part name="year" />
            </date>
          </group>
        </layout>
      </bibliography>
    </style>
    """
    And the following input:
    """
    [{"author":[{"family":"Smith","given":"John","static-ordering":false}],"id":"ITEM-1","issued":{"date-parts":[["2000"]]},"title":"Book A","type":"book"},{"author":[{"family":"Jones","given":"Robert","static-ordering":false}],"id":"ITEM-2","issued":{"date-parts":[["2001"]]},"title":"Book B","type":"book"}]
    """
    When I render the entire bibliography
    Then the bibliography should be:
    """
    <div class="csl-bib-body">
      <div class="csl-entry">
        <div class="csl-left-margin">[1]</div><div class="csl-right-inline">John Smith, Book A (2000)</div>
      </div>
      <div class="csl-entry">
        <div class="csl-left-margin">[2]</div><div class="csl-right-inline">Robert Jones, Book B (2001)</div>
      </div>
    </div>
    """
