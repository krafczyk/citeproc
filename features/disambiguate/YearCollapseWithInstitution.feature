Feature: disambiguate
  As a CSL cite processor hacker
  I want the test disambiguate_YearCollapseWithInstitution to pass

  @citation @disambiguate @citation-items
  Scenario: Year Collapse With Institution
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
      <citation 
             et-al-min="3"
             et-al-use-first="1"
             et-al-subsequent-min="3"
             et-al-subsequent-use-first="1"
             disambiguate-add-names="true"
    		 disambiguate-add-year-suffix="true"
    		 collapse="year">
    
        <layout delimiter="; " prefix="(" suffix=")">
          <group delimiter=" ">
            <names delimiter=", " variable="author">
              <name and="symbol" form="short"/>
            </names>
            <date variable="issued">
              <date-part name="year"/>
            </date>
          </group>
        </layout>
      </citation>
    </style>
    """
    And the following input:
    """
    [{"author":[{"family":"Smith Co"}],"id":"ITEM-1","issued":{"date-parts":[[2000]]},"title":"Book A","type":"book"},{"author":[{"family":"Smith Co"}],"id":"ITEM-2","issued":{"date-parts":[[2000]]},"title":"Book B","type":"book"},{"author":[{"family":"Smith Co"}],"id":"ITEM-3","issued":{"date-parts":[[2000]]},"title":"Book C","type":"book"}]
    """
    When I cite the following items:
    """
    [[{"id":"ITEM-1"},{"id":"ITEM-2"},{"id":"ITEM-3"}],[{"id":"ITEM-2"}],[{"id":"ITEM-3"}]]
    """
    Then the results should be:
      | (Smith Co 2000a; 2000b; 2000c) |
      | (Smith Co 2000b) |
      | (Smith Co 2000c) |
