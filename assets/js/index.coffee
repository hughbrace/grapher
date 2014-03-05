jQuery ->
  #Sets up animations to transition between page sections
  do $('div#about').hide

  $('a#graph').click ->
    $('div#about').fadeOut 'fast', ->
      $('div#graph').fadeIn 'fast'

  $('a#about').click ->
    $('div#graph').fadeOut 'fast', ->
      $('div#about').fadeIn 'fast'

  class Graph
    
    constructor: (@width, @height) ->

      @svg = d3.select '#svg'
        .append 'svg'
        .attr 'width', @width
        .attr 'height', @height

      @node = @svg.selectAll '.node'

      @link = @svg.selectAll '.link'

      @force = d3.layout.force()
        .size [@width, @height]
        .linkDistance 30
        .charge -150
        .on 'tick', @tick.bind @

      @nodes = @force.nodes()
      @links = @force.links()
    
      @svg.append 'rect'
        .attr 'width', @width
        .attr 'height', @height

    addNode: (new_node) ->
      if not ((n for n in @nodes when n.name is new_node.name)[0])?
        new_node.x = @_generateX()
        new_node.y = @_generateY()
        @nodes.push new_node
        @_draw()

    clearGraph: ->
      @force.nodes []
      @force.links []
      @nodes = @force.nodes()
      @links = @force.links()
      @_draw()

    tick: ->
      @link.attr 'x1', (d) -> d.source.x
      @link.attr 'y1', (d) -> d.source.y
      @link.attr 'x2', (d) -> d.source.x
      @link.attr 'y2', (d) -> d.source.y
      
      @node.attr 'cx', (d) -> d.x # Error
      @node.attr 'cy', (d) -> d.y

    _draw: ->
      @link = @link.data @links

      @link.enter().insert 'line', '.node'
        .attr 'class', 'link'

      @node = @node.data @nodes

      @node.enter().insert 'circle'
        .attr 'class', 'node unselected'
        .attr 'r', 15
        .call @force.drag
        .on 'click', (d) ->
          if not d3.event.defaultPrevented # Ignore drag
            previous_selection = 'selection-' + Selecter.select d
            console.log previous_selection
            d3.select '.' + previous_selection
              .attr 'class', 'node unselected'
            d3.select @
              .attr 'class', previous_selection

      @node.exit().remove()

      @force.start()

    _generateX: ->
      Math.random() * 800

    _generateY: ->
      Math.random() * 500

  # Search functionality
  #AJAX search for nodes on keydown by name and populate search results element.
  class Searcher

    search: (search_term) ->
      console.log @name
      if @last_term != search_term
        @clearResults()
        #loading
        if search_term != ''
          self = @
          $.get "/nodes/name/#{search_term}", (data) ->
            self.addResults(data)
        @last_term = search_term


    clearResults: ->
      $('#results ul').empty()

    addResults: (data) ->
      self = @
      do @clearResults
      addResult = (id, name) ->
        $('#results ul').append(
          $(document.createElement 'li')
          .append($(document.createElement 'a')
            .attr 'href', '#!'
            .html name
            .click () ->
              self.graph.addNode new Node(id, name)
            .prepend($(document.createElement 'span')
              .attr('class', 'glyphicon glyphicon-user')
            )
          )
        )
      
      if data.meta.number_of_people == 0
        $('#results ul').append(
          $(document.createElement 'li')
            .html 'No results'
        )
      else
        addResult person.id, person.name for person in data.people

    constructor: (@graph) ->
      self = @
      $('#name-search').keyup ->
        self.search($(@).val())

      $('#clear').click ->
        do Graph.clearGraph
  
  Selecter =
    _selected: 2

    select: (node) ->
      @_selected = if @_selected is 2 then 1 else 2
      console.log 'Select ' + node.id + ': ' + node.name + @selected
      #Add node details to display
      @_selected


  class Node
    constructor: (@id, @name) ->

  graph = new Graph 800, 500
  searcher = new Searcher graph




